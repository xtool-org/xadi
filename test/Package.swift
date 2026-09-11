// swift-tools-version:6.2

import PackageDescription

let package = Package(
    name: "XADITests",
    dependencies: [
        .package(name: "xadi", path: ".."),
    ],
    targets: [
        .testTarget(
            name: "XADITests",
            dependencies: [
                .product(name: "XADI", package: "xadi"),
            ],
        ),
    ]
)
