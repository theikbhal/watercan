// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Watercan",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(name: "Watercan", path: "Sources/Watercan")
    ]
)
