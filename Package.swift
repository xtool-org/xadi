// swift-tools-version:6.2

import PackageDescription

let package = Package(
    name: "xadi",
    products: [
        .library(name: "XADI", targets: ["XADIUmbrella"])
    ],
    targets: [
        .target(
            name: "XADIUmbrella",
            dependencies: [
                .byName(name: "XADISystem", condition: .when(platforms: [.linux])),
            ],
        ),
        .systemLibrary(name: "XADISystem"),
    ]
)
