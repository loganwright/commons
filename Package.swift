// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// MARK:
import Foundation

//private class CurrentBundleFinder {}
//extension Foundation.Bundle {
//    static var myModule: Bundle = {
//
//        /* The name of your local package, prepended by "LocalPackages_" for iOS and "PackageName_" for macOS. You may have same PackageName and TargetName*/
//        let bundleNameIOS = "LocalPackages_TargetName"
//        let bundleNameMacOs = "PackageName_TargetName"
//
//        let candidates = [
//            /* Bundle should be present here when the package is linked into an App. */
//            Bundle.main.resourceURL,
//            /* Bundle should be present here when the package is linked into a framework. */
//            Bundle(for: CurrentBundleFinder.self).resourceURL,
//            /* For command-line tools. */
//            Bundle.main.bundleURL,
//            /* Bundle should be present here when running previews from a different package (this is the path to "…/Debug-iphonesimulator/"). */
//            Bundle(for: CurrentBundleFinder.self).resourceURL?.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent(),
//            Bundle(for: CurrentBundleFinder.self).resourceURL?.deletingLastPathComponent().deletingLastPathComponent(),
//
//        ]
//
//        for candidate in candidates {
//            let bundlePathiOS = candidate?.appendingPathComponent(bundleNameIOS + ".bundle")
//            let bundlePathMacOS = candidate?.appendingPathComponent(bundleNameMacOs + ".bundle")
//            if let bundle = bundlePathiOS.flatMap(Bundle.init(url:)) {
//                return bundle
//            } else if let bundle = bundlePathMacOS.flatMap(Bundle.init(url:)) {
//                return bundle
//
//            }
//
//        }
//
//        fatalError("unable to find bundle")
//    }()
//}
// MARK: 

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
            dependencies: ["Commons"]),
//            dependencies: []),
        
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
