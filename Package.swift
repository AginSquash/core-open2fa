// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "core-open2fa",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "core-open2fa",
            targets: ["core-open2fa"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift", .upToNextMinor(from: "1.3.1")),
        .package(url: "https://github.com/lachlanbell/SwiftOTP.git", .upToNextMinor(from: "2.0.0"))
        
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "core-open2fa",
            dependencies: ["SwiftOTP", "CryptoSwift"]),
        .testTarget(
            name: "core-open2faTests",
            dependencies: ["core-open2fa"]),
    ]
)
