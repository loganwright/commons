// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Commons",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v9)
    ],
    products: [
        /// rename this to base
        .library(name: "Commons", targets: ["Commons"]),
        /// rename base?
        .library(name: "Endpoints", targets: ["Endpoints"]),
        .library(name: "UICommons", targets: ["UICommons"]),
        .library(name: "AnimationKit", targets: ["AnimationKit"])
    ],
    targets: [
        .target(
            name: "Commons",
            dependencies: []),
        .target(
            name: "UICommons",
            dependencies: ["Commons", "AnimationKit"]),
        .target(
            name: "Endpoints",
            dependencies: ["Commons"]),
        .target(
            name: "AnimationKit",
            dependencies: ["Commons"]),
        .testTarget(
            name: "mishmashTests",
            dependencies: ["Commons", "Endpoints", "UICommons", "AnimationKit"])
    ]
)
