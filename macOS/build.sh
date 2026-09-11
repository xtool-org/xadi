#!/bin/bash

# Build XADIMac.xcframework

set -euo pipefail

cd "$(dirname "$0")/.."

export MACOSX_DEPLOYMENT_TARGET=11.0

command -v dub >/dev/null || { echo "dub not found in PATH" >&2; exit 1; }
command -v ldc2 >/dev/null || { echo "ldc2 not found in PATH" >&2; exit 1; }

rm -rf bin/libxadibase.a tmp/stage out
mkdir -p tmp/stage out

find_runtime_libraries() {
    local target_arch="$1"
    local probe_dir probe_source runtime_paths

    probe_dir="$(mktemp -d "${TMPDIR:-/tmp}/xadi-ldc-probe.XXXXXX")"
    probe_source="$probe_dir/probe.d"
    runtime_paths="$probe_dir/runtime-libraries"
    touch "$probe_source"

    # Ask LDC to perform a static-default-library link for this target. The
    # linker's trace contains the fully resolved paths after LDC has applied
    # its target-specific ldc2.conf, even when ldc2 itself is a trampoline.
    if ! ldc2 \
        -main \
        --mtriple="$target_arch-apple-macos$MACOSX_DEPLOYMENT_TARGET" \
        --link-defaultlib-shared=false \
        -L-t \
        "$probe_source" \
        -of="$probe_dir/probe" 2>&1 | awk '
            match($0, /lib(phobos2|druntime)-ldc\.a/) {
                path = substr($0, 1, RSTART + RLENGTH - 1)
                if (!seen[path]++) print path
            }
        ' > "$runtime_paths"
    then
        echo "Failed to query LDC runtime libraries for $target_arch" >&2
        rm -rf "$probe_dir"
        exit 1
    fi

    phobos="$(awk '/\/libphobos2-ldc\.a$/ { print; exit }' "$runtime_paths")"
    druntime="$(awk '/\/libdruntime-ldc\.a$/ { print; exit }' "$runtime_paths")"
    rm -rf "$probe_dir"

    if [[ ! -f "$phobos" || ! -f "$druntime" ]]; then
        echo "LDC did not resolve static Phobos and Druntime for $target_arch" >&2
        exit 1
    fi

    echo "$phobos" "$druntime"
}

build_arch() {
    local dub_arch="$1"
    local runtime_arch="$2"
    local output="tmp/stage/libxadibase-$runtime_arch.a"

    # A staticLibrary build has no final link step. --combined puts every DUB
    # dependency in libxadi.a, then libtool folds in the matching static D
    # runtime and standard library.
    dub build \
        --arch="$dub_arch" \
        --build=release \
        --combined \
        --force

    /usr/bin/libtool -static -o "$output" \
        bin/libxadibase.a \
        $(find_runtime_libraries "$runtime_arch")
}

build_arch x86_64 x86_64
build_arch aarch64 arm64

lipo -create tmp/stage/libxadibase-x86_64.a tmp/stage/libxadibase-arm64.a \
    -output bin/libxadibase.a

xcodebuild -create-xcframework -library bin/libxadibase.a -output tmp/stage/XADIMac.xcframework

(cd tmp/stage && zip -yqr ../../out/XADIMac.xcframework.zip XADIMac.xcframework)

# rm -rf tmp/stage
