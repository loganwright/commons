// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
func asdf() {
//    Product
}

let package = Package(
    name: "Commons",
    platforms: [
        .macOS(.v11),
        .iOS(.v14)
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
                
                .target(name: "UICommons", condition: .when(platforms: [.iOS])),
                .target(name: "AnimationKit", condition: .when(platforms: [.iOS])),
                
                "YouEye",
            ])
    ]
)
/*
// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
import AppKit
import PackageDescription
//import Darwin

struct Module {
    let name: String
    let depenencies: [String]
    let condition: TargetDependencyCondition?
    
    init(_ name: String, dependencies: [String], condition: TargetDependencyCondition? = nil) {
        self.name = name
        self.depenencies = dependencies
        self.condition = condition
    }
}


//var products: [Product] = [
//    /// standardlibrary and foundation additions
//    .library(name: "Commons", targets: ["Commons"]),
//    /// networking
//    .library(name: "Endpoints", targets: ["Endpoints"]),
//]

var modules: [Module] = [
    /// standardlibrary and foundation additions
    Module("Commons", dependencies: []),
    /// networking
    Module("Endpoints", dependencies: ["Commons"]),
    
    // iOS
    
    /// uikit additions
    Module("UICommons", dependencies: ["Commons", "AnimationKit"], condition: .when(platforms: [.iOS])),
    /// advanced, multipart uikit animations (views, and layers)
    Module("AnimationKit", dependencies: ["Commons"], condition: .when(platforms: [.iOS])),
    
    // SwiftUI
    
    Module("YouEye", dependencies: []),
]

//#if canImport(UIKit)
////products += [
////    /// uikit additions
////    .library(name: "UICommons", targets: ["UICommons"]),
////    /// advanced, multipart uikit animations (views, and layers)
////    .library(name: "AnimationKit", targets: ["AnimationKit"]),
////]
//
//modules += [
//    /// uikit additions
//    Module("UICommons", dependencies: ["Commons", "AnimationKit"]),
//    /// advanced, multipart uikit animations (views, and layers)
//    Module("AnimationKit", dependencies: ["Commons"]),
//]
//#endif
//
//#if canImport(SwiftUI)
////products += [
////    /// swiftui additions
////    .library(name: "YouEye", targets: ["YouEye"]),
////]
//
//modules += [
//    /// swiftui additions
//    Module("YouEye", dependencies: []),
//]
//#endif

extension Module {
    var product: Product {
        .library(name: name, targets: [name])
    }
    var target: Target {
        return .target(name: name, dependencies: depenencies.map(Target.Dependency.init))
    }
}

func asdf() {
//    Product.
}

let targets = modules.map(\.target) + [
    .testTarget(
        name: "mishmashTests",
        dependencies: modules.map(\.name).map(Target.Dependency.init)
    )
]
let package = Package(
    name: "Commons",
    platforms: [
        .macOS(.v11),
        .iOS(.v14),
//        .tvOS(.v14),
//        .watchOS(.v7)
    ],
    products: modules.map(\.product),
    targets: targets
//    targets:
//        modules.map(\.target) + [
//        .testTarget(
//            name: "mishmashTests",
//            dependencies: modules.map(\.name).map(Target.Dependency.init)
//        )
//    ]
//    targets: [
//        .target(
//            name: "Commons",
//            dependencies: []),
//        .target(
//            name: "UICommons",
//            dependencies: ["Commons", "AnimationKit"]),
//        .target(
//            name: "Endpoints",
//            dependencies: ["Commons"]),
//        .target(
//            name: "AnimationKit",
//            dependencies: ["Commons"]),
//        .target(
//            name: "YouEye",
//            dependencies: []),
//        .testTarget(
//            name: "mishmashTests",
//            dependencies: modules.map(\.name).map(Target.Dependency.init))
//    ]
)
*/
