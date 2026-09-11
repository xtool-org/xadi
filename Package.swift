// swift-tools-version:6.2

import PackageDescription

let package = Package(
    name: "xadi",
    products: [
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
        .testTarget(
            name: "XADITests",
            dependencies: ["XADI"],
        ),
        .binaryTarget(
            name: "XADIBinary",
            path: "out/XADIBinary.artifactbundle"
        )
    ]
)
