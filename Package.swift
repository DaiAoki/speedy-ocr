// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "speedy-ocr",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "speedy-ocr", targets: ["speedy-ocr"]),
        .library(name: "SpeedyOCRCore", targets: ["SpeedyOCRCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
    ],
    targets: [
        .executableTarget(
            name: "speedy-ocr",
            dependencies: [
                "SpeedyOCRCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(
            name: "SpeedyOCRCore"
        ),
        .testTarget(
            name: "SpeedyOCRCoreTests",
            dependencies: ["SpeedyOCRCore"],
            resources: [
                .copy("Fixtures"),
            ]
        ),
    ]
)
