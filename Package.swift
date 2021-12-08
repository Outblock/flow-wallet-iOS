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
            targets: ["FlowWalletKit", "WalletCore", "SwiftProtobuf2"]
        ),
    ],
    dependencies: [
        .package(name: "Flow", url: "https://github.com/outblock/flow-swift.git", from: "0.1.3-beta"),
//        .package(name: "WalletCore", url: "https://github.com/Outblock/wallet-core", .revision("8ca0f092a7f39dc7cbeabd1013ec5d413449eec8")),
    ],
    targets: [
        .target(
            name: "FlowWalletKit",
            dependencies: ["Flow"]
        ),
        .binaryTarget(name: "WalletCore", path: "Library/WalletCore.xcframework"),
        .binaryTarget(name: "SwiftProtobuf2", path: "Library/SwiftProtobuf.xcframework"),
        .testTarget(
            name: "FlowWalletKitTests",
            dependencies: ["FlowWalletKit"],
            path: "Tests"
        ),
    ]
)
