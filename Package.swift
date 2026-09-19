// swift-tools-version:6.2

import PackageDescription

let package = Package(
    name: "xadi",
    products: [
        // has to be dynamic because LGPL
        .library(
            name: "XADI",
            type: .dynamic,
            targets: ["XADI"]
        )
    ],
    targets: [
        .target(
            name: "XADI",
            dependencies: ["XADIBinary"]
        ),
        .binaryTarget(
            name: "XADIBinary",
            url: "https://github.com/xtool-org/xadi/releases/download/source-0.4.1/XADIBinary.artifactbundle.zip",
            checksum: "2fc1aeb058f6067d23e2f2217a2ea0ec843057e1d82c13db37e30b8219d8d469"
        )
    ]
)
