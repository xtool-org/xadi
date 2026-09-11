// swift-tools-version:6.2

import PackageDescription

var xadiDependencies: [Target.Dependency] = []
var platformTargets: [Target] = []

#if os(macOS)
xadiDependencies.append("XADIMac")
platformTargets.append(
    .binaryTarget(
        name: "XADIMac",
        path: "out/XADIMac.xcframework.zip"
    )
)
#elseif os(Linux)
xadiDependencies.append("XADILinux")
platformTargets.append(
    .binaryTarget(
        name: "XADILinux",
        path: "out/XADILinux.artifactbundle"
    )
)
#endif

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
            dependencies: xadiDependencies
        ),
        .testTarget(
            name: "XADITests",
            dependencies: ["XADI"],
        )
    ] + platformTargets
)
