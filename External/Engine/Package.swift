// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Engine",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Engine",
            targets: ["Engine"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/malcommac/SwiftDate", from: "6.0.3"),
        .package(url: "https://github.com/Quick/Quick", from: "2.1.0"),
        .package(url: "https://github.com/Quick/Nimble", from: "8.0.2"),
        .package(url: "https://github.com/Alamofire/Alamofire", from: "4.8.1"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Engine",
            dependencies: ["SwiftDate", "Alamofire", "SwiftyJSON"]),
        .testTarget(
            name: "EngineTests",
            dependencies: ["Engine", "Quick", "Nimble"]),
    ]
)
