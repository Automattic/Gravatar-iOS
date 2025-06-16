// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Analytics",
    platforms: [
        .iOS(.v16), .macOS(.v12), .visionOS(.v1),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Analytics",
            targets: ["Analytics"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Automattic/Automattic-Tracks-iOS", from: "3.5.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Analytics",
            dependencies: [
                .product(name: "AutomatticTracks", package: "Automattic-Tracks-iOS"),
            ]
        ),
        .testTarget(
            name: "AnalyticsTests",
            dependencies: ["Analytics"]
        ),
    ]
)
