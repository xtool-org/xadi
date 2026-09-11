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
            url: "https://github.com/xtool-org/xadi/releases/download/source-0.4.0/XADIBinary.artifactbundle.zip",
            checksum: "238740ef93c7ee22aaba7dc75006e1336d241dc20348830679b34bd910acd9fb"
        )
    ]
)
