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
            url: "https://github.com/xtool-org/xadi/releases/download/source-0.4.2/XADIBinary.artifactbundle.zip",
            checksum: "ca6bb14b2768998ff726d0bb564d8cda8f946b154604753c296978541d95fe0f"
        )
    ]
)
