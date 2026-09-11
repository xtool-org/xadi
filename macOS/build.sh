#!/bin/bash

# Build XADIBinary.xcframework. Contains only macOS (fat arm64+x86_64).

set -euo pipefail

cd "$(dirname "$0")/.."

rm -rf bin/libxadi.dylib tmp/stage
mkdir -p tmp/stage

dub build --arch=x86_64 --build=release
mv bin/libxadi.dylib tmp/stage/libxadi-x86_64.dylib

dub build --arch=aarch64 --build=release
mv bin/libxadi.dylib tmp/stage/libxadi-arm64.dylib

lipo -create tmp/stage/libxadi-x86_64.dylib tmp/stage/libxadi-arm64.dylib \
    -output tmp/stage/libxadi.dylib

xcodebuild -create-xcframework -library tmp/stage/libxadi.dylib -output tmp/stage/XADIBinary.xcframework

rm -f tmp/stage/libxadi{,-x86_64,-arm64}.dylib
