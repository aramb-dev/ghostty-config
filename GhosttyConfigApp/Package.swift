// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "GhosttyConfigApp",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "GhosttyConfigApp", targets: ["GhosttyConfigApp"])
    ],
    targets: [
        .executableTarget(
            name: "GhosttyConfigApp",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
