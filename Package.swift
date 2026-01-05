// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PromptIDE",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "PromptIDE_Domain", targets: ["PromptIDE_Domain"]),
        .library(name: "PromptIDE_Data", targets: ["PromptIDE_Data"]),
        .library(name: "PromptIDE_App", targets: ["PromptIDE_App"]),
    ],
    targets: [
        // MARK: - Domain Layer
        // Pure Swift entities. No dependencies.
        .target(
            name: "PromptIDE_Domain",
            dependencies: [],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "PromptIDE_DomainTests",
            dependencies: ["PromptIDE_Domain"]
        ),

        // MARK: - Data Layer
        // Persistence, Repositories, Encryption. Depends on Domain.
        .target(
            name: "PromptIDE_Data",
            dependencies: ["PromptIDE_Domain"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "PromptIDE_DataTests",
            dependencies: ["PromptIDE_Data", "PromptIDE_Domain"]
        ),

        // MARK: - App Layer (Composition Root)
        // Networking, DI Container, Entry Point. Depends on Domain and Data.
        .target(
            name: "PromptIDE_App",
            dependencies: ["PromptIDE_Domain", "PromptIDE_Data"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "PromptIDE_AppTests",
            dependencies: ["PromptIDE_App", "PromptIDE_Domain", "PromptIDE_Data"]
        ),
    ]
)
