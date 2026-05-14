// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "UTCMenuBar",
    platforms: [.macOS(.v13)],
    targets: [
        .target(
            name: "UTCMenuBarLib",
            path: "Sources/UTCMenuBarLib"
        ),
        .executableTarget(
            name: "UTCMenuBar",
            dependencies: ["UTCMenuBarLib"],
            path: "Sources",
            exclude: ["UTCMenuBarLib"]
        ),
        .executableTarget(
            name: "UTCMenuBarTests",
            dependencies: ["UTCMenuBarLib"],
            path: "Tests/UTCMenuBarTests"
        )
    ]
)
