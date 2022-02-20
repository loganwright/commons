// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Commons",
    platforms: [
        .macOS(.v11),
        .iOS(.v14),
    ],
    products: [
        .library(name: "Commons", targets: ["Commons"]),
        .library(name: "Endpoints", targets: ["Endpoints"]),
        .library(name: "UICommons", targets: ["UICommons"]),
        .library(name: "AnimationKit", targets: ["AnimationKit"]),
        .library(name: "YouEye", targets: ["YouEye"]),
    ],
    targets: [
        .target(
            name: "Commons",
            dependencies: []),
        .target(
            name: "Endpoints",
            dependencies: ["Commons"]),
        
        // uikit
        .target(
            name: "UICommons",
            dependencies: ["Commons", "AnimationKit"]),
        .target(
            name: "AnimationKit",
            dependencies: ["Commons"]),
        
        // swiftui
        .target(
            name: "YouEye",
            dependencies: []),
        
        // testing
        .testTarget(
            name: "mishmashTests",
            dependencies: [
                "Commons",
                "Endpoints",
                "UICommons",
                "AnimationKit",
                "YouEye",
            ])
    ]
)
