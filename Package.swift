// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

let package = Package(
    name: "swift-testing-revolutionary",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .executable(
            name: "swift-testing-revolutionary",
            targets: ["swift-testing-revolutionary"]
        ),
        .library(
            name: "RevolutionKit",
            targets: ["RevolutionKit"]
        ),
        .plugin(
            name: "RevolutionaryPlugin",
            targets: ["RevolutionaryPlugin"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swiftlang/swift-syntax.git",
            .upToNextMajor(from: "600.0.0-latest")
        ),
        .package(
            url: "https://github.com/apple/swift-testing.git",
            from: "0.10.0"
        ),
        .package(
            url: "https://github.com/apple/swift-argument-parser.git",
            from: "1.2.0"
        ),
    ],
    targets: [
        .target(
            name: "RevolutionKit",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
            ]
        ),
        .plugin(
            name: "RevolutionaryPlugin",
            capability: .command(
                intent: .custom(
                    verb: "swift-testing-revolutionary",
                    description: "Convert XCTest cases to swift-testing"
                ),
                permissions: [
                    .writeToPackageDirectory(reason: "Rewrite implementations"),
                ]
            ),
            dependencies: [
                .target(name: "swift-testing-revolutionary"),
            ]
        ),
        .executableTarget(
            name: "swift-testing-revolutionary",
            dependencies: [
                .target(name: "RevolutionKit"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .testTarget(
            name: "RevolutionKitTests",
            dependencies: [
                .target(name: "RevolutionKit"),
                .product(name: "Testing", package: "swift-testing"),
            ]
        ),
    ],
    swiftLanguageVersions: [.v6]
)

let isDevelopment = ProcessInfo.processInfo.environment["SWIFT_TESTING_REVOLUTIONARY_DEVELOPMENT"] == "1"

if isDevelopment {
    package.dependencies += [
        .package(url: "https://github.com/freddi-kit/ArtifactBundleGen.git", from: "0.0.6"),
    ]
}
