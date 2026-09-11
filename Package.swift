// swift-tools-version:6.2

import PackageDescription

let package = Package(
    name: "xadi",
    products: [
        .library(name: "XADI", targets: ["XADI"])
    ],
    targets: [
        .target(
            name: "XADI",
            dependencies: [
                .byName(name: "XADILinux", condition: .when(platforms: [.linux])),
                .byName(name: "XADIMac", condition: .when(platforms: [.macOS]))
            ],
        ),
        .systemLibrary(name: "XADILinux"),
        .binaryTarget(
            name: "XADIMac",
            path: "out/XADIMac.xcframework.zip"
        ),
        .testTarget(
            name: "XADITests",
            dependencies: ["XADI"],
        )
    ]
)
