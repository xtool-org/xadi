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
            url: "https://github.com/xtool-org/xadi/releases/download/source-0.3.0/XADIBinary.artifactbundle.zip",
            checksum: "aa7f4cdab5110b65e34ea83f9a7d665b6fd663d844d5a3dc185311ed03af9f60"
        )
    ]
)
