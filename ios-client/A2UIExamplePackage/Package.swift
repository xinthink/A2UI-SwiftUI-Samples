// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "A2UIExamplePackage",
    platforms: [.iOS(.v18), .macOS(.v14)],
    products: [
        .library(
            name: "A2UICore",
            targets: ["A2UICore"]
        ),
        .library(
            name: "A2UIServices",
            targets: ["A2UIServices"]
        ),
        .library(
            name: "A2UIViews",
            targets: ["A2UIViews"]
        ),
    ],
    targets: [
        // A2UICore: Protocol types, messages, and component definitions
        .target(
            name: "A2UICore"
        ),

        // A2UIServices: HTTP client, data binding resolver, surface management
        .target(
            name: "A2UIServices",
            dependencies: ["A2UICore"]
        ),

        // A2UIViews: SwiftUI renderer
        .target(
            name: "A2UIViews",
            dependencies: ["A2UICore", "A2UIServices"]
        ),
    ]
)
