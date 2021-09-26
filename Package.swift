// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FlowWalletKit",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "FlowWalletKit",
            targets: ["FlowWalletKit"]
        ),
    ],
    dependencies: [
        .package(name: "Flow", url: "https://github.com/zed-io/flow-swift.git", from: "0.0.3-beta"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMajor(from: "1.4.1")),
        .package(name: "secp256k1", url: "https://github.com/GigaBitcoin/secp256k1.swift.git", from: "0.3.0"),
    ],
    targets: [
        .target(
            name: "FlowWalletKit",
            dependencies: ["Flow", "CryptoSwift", "secp256k1"]
        ),
        .testTarget(
            name: "FlowWalletKitTests",
            dependencies: ["FlowWalletKit"],
            path: "Tests"
        ),
    ]
)
