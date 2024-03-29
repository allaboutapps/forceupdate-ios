// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ForceUpdate",
    defaultLocalization: "en",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "ForceUpdate", targets: ["ForceUpdate"]),
    ],
    targets: [
        .target(
            name: "ForceUpdate",
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "ForceUpdateTests",
            dependencies: ["ForceUpdate"]
        ),
    ]
)
