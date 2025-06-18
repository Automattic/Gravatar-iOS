// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OAuth",
    platforms: [
        .iOS(.v16), .macOS(.v12), .visionOS(.v1),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "OAuth",
            targets: ["OAuth"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Automattic/Gravatar-SDK-iOS", from: "3.3.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "OAuth",
            dependencies: [
                .product(name: "Gravatar", package: "Gravatar-SDK-iOS"),
            ]
        ),
        .testTarget(
            name: "OAuthTests",
            dependencies: ["OAuth"]
        ),
    ]
)
