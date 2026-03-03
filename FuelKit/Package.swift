// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "FuelKit",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "FuelKit",
            targets: ["FuelKit"]
        )
    ],
    targets: [
        .target(
            name: "FuelKit",
            resources: [
                .copy("Resources/usda_foods.sqlite")
            ]
        ),
        .testTarget(
            name: "FuelKitTests",
            dependencies: ["FuelKit"]
        )
    ]
)
