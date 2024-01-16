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
    dependencies: [
        .package(url: "https://github.com/allaboutapps/Toolbox.git", from: "5.0.0"),
    ],
    targets: [
        .target(
            name: "ForceUpdate",
            dependencies: [
                "Toolbox",
            ],
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
