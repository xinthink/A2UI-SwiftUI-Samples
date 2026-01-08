// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "A2UIExample",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "A2UIExample",
            targets: ["A2UIExample"]
        ),
        .executable(
            name: "A2UIExampleApp",
            targets: ["A2UIExampleApp"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "A2UIExample",
            dependencies: [],
            path: "A2UIExample"
        ),
        .executableTarget(
            name: "A2UIExampleApp",
            dependencies: ["A2UIExample"],
            path: "A2UIExampleApp"
        )
    ]
)