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
            url: "https://github.com/xtool-org/xadi/releases/download/source-0.2.0/XADIBinary.artifactbundle.zip",
            checksum: "602be8ef1411d42eb8caaa23cb0f27449680ea124130e90d36117c4ed8bdb4ca"
        )
    ]
)
