#!/bin/bash

# Build XADIMac.xcframework

set -euo pipefail

cd "$(dirname "$0")/.."

rm -rf bin/libxadi.dylib tmp/stage out
mkdir -p tmp/stage out

dub build --arch=x86_64 --build=release
mv bin/libxadi.dylib tmp/stage/libxadi-x86_64.dylib

dub build --arch=aarch64 --build=release
mv bin/libxadi.dylib tmp/stage/libxadi-arm64.dylib

lipo -create tmp/stage/libxadi-x86_64.dylib tmp/stage/libxadi-arm64.dylib \
    -output tmp/stage/libxadi.dylib

xcodebuild -create-xcframework -library tmp/stage/libxadi.dylib -output tmp/stage/XADIMac.xcframework

zip -yqr out/XADIMac.xcframework.zip tmp/stage/XADIMac.xcframework

rm -rf tmp/stage
