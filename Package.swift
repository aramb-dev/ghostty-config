// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GhosttyConfigApp",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "GhosttyConfigApp",
            targets: ["GhosttyConfigApp"]
        )
    ],
    targets: [
        .executableTarget(
            name: "GhosttyConfigApp",
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
