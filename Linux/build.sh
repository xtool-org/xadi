#!/bin/bash

# Build a self-contained native Linux static library.

set -euo pipefail

cd "$(dirname "$0")/.."

command -v dub >/dev/null || { echo "dub not found in PATH" >&2; exit 1; }
command -v ldc2 >/dev/null || { echo "ldc2 not found in PATH" >&2; exit 1; }
command -v ar >/dev/null || { echo "ar not found in PATH" >&2; exit 1; }

case "$(uname -m)" in
    x86_64) dub_arch=x86_64 ;;
    aarch64 | arm64) dub_arch=aarch64 ;;
    *) echo "Unsupported Linux architecture: $(uname -m)" >&2; exit 1 ;;
esac

triple="$dub_arch-unknown-linux-gnu"
bundle="out/XADIBinary.artifactbundle"

rm -rf tmp/linux-stage \
    "$bundle/$triple" \
    out/Linux \
    out/XADILinux.artifactbundle
mkdir -p tmp/linux-stage "$bundle/$triple" "$bundle/include"

find_runtime_libraries() {
    local probe_dir probe_source runtime_paths

    probe_dir="$(mktemp -d "${TMPDIR:-/tmp}/xadi-ldc-probe.XXXXXX")"
    probe_source="$probe_dir/probe.d"
    runtime_paths="$probe_dir/runtime-libraries"
    touch "$probe_source"

    # Trace an ordinary static-default-library link so LDC resolves the
    # runtime through its active target configuration and PATH entry.
    if ! ldc2 \
        -main \
        --link-defaultlib-shared=false \
        -L-t \
        "$probe_source" \
        -of="$probe_dir/probe" 2>&1 | awk '
            match($0, /lib(phobos2|druntime)-ldc\.a/) {
                path = substr($0, 1, RSTART + RLENGTH - 1)
                sub(/\(.*/, "", path)
                if (!seen[path]++) print path
            }
        ' > "$runtime_paths"
    then
        echo "Failed to query LDC runtime libraries" >&2
        rm -rf "$probe_dir"
        exit 1
    fi

    phobos="$(awk '/\/libphobos2-ldc\.a$/ { print; exit }' "$runtime_paths")"
    druntime="$(awk '/\/libdruntime-ldc\.a$/ { print; exit }' "$runtime_paths")"
    rm -rf "$probe_dir"

    if [[ ! -f "$phobos" || ! -f "$druntime" ]]; then
        echo "LDC did not resolve static Phobos and Druntime" >&2
        exit 1
    fi
}

dub build \
    --arch="$dub_arch" \
    --build=release \
    --combined \
    --force

find_runtime_libraries

output="tmp/linux-stage/libxadibase.a"
ar -M <<EOF
CREATE $output
ADDLIB bin/libxadibase.a
ADDLIB $phobos
ADDLIB $druntime
SAVE
END
EOF
ar -s "$output"

cp "$output" bin/libxadibase.a
cp "$output" "$bundle/$triple/libxadibase.a"
cp Sources/XADI/include/XADI.h "$bundle/include/XADI.h"
cp ArtifactBundle/module.modulemap "$bundle/include/module.modulemap"
./ArtifactBundle/update-info.sh "$bundle"

rm -rf tmp/linux-stage
