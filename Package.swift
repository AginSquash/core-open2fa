// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "core_open2fa",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v10),
        .tvOS(.v10)
    ],
    products: [
        .library(
            name: "core_open2fa",
            targets: ["core_open2fa"]),
    ],
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift", .upToNextMajor(from: "1.8.2")),
        .package(url: "https://github.com/lachlanbell/SwiftOTP.git", .upToNextMinor(from: "2.0.0"))
        
    ],
    targets: [
        .target(
            name: "core_open2fa",
            dependencies: ["SwiftOTP", "CryptoSwift"]),
        .testTarget(
            name: "core_open2faTests",
            dependencies: ["core_open2fa"]),
    ]
)
