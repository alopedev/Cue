// swift-tools-version: 6.2
import PackageDescription

// Strict settings shared by every target: Swift 6 language mode
// (complete concurrency checking) and every warning treated as an error.
let strictSettings: [SwiftSetting] = [
    .treatAllWarnings(as: .error)
]

let package = Package(
    name: "CueKit",
    platforms: [
        .iOS("27.0"),
        .macOS("27.0"),
    ],
    products: [
        .library(name: "CueKit", targets: ["CueKit"]),
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
    ],
    targets: [
        .target(name: "CueKit", swiftSettings: strictSettings),
        .target(
            name: "DesignSystem",
            resources: [.process("Resources")],
            swiftSettings: strictSettings
        ),
        .testTarget(
            name: "CueKitTests",
            dependencies: ["CueKit"],
            swiftSettings: strictSettings
        ),
        .testTarget(
            name: "DesignSystemTests",
            dependencies: ["DesignSystem"],
            swiftSettings: strictSettings
        ),
    ],
    swiftLanguageModes: [.v6]
)
