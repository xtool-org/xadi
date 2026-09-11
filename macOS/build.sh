#!/bin/bash

# Build XADIMac.xcframework

set -euo pipefail

cd "$(dirname "$0")/.."

rm -rf bin/libxadibase.dylib tmp/stage out
mkdir -p tmp/stage out

dub build --arch=x86_64 --build=release
mv bin/libxadibase.dylib tmp/stage/libxadibase-x86_64.dylib

dub build --arch=aarch64 --build=release
mv bin/libxadibase.dylib tmp/stage/libxadibase-arm64.dylib

lipo -create tmp/stage/libxadibase-x86_64.dylib tmp/stage/libxadibase-arm64.dylib \
    -output tmp/stage/libxadibase.dylib

xcodebuild -create-xcframework -library tmp/stage/libxadibase.dylib -output tmp/stage/XADIMac.xcframework

(cd tmp/stage && zip -yqr ../../out/XADIMac.xcframework.zip XADIMac.xcframework)

rm -rf tmp/stage
