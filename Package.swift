// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Mataki",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        .library(name: "Mataki", targets: ["Mataki"]),
    ],
    targets: [
        .target(
            name: "Mataki",
            path: "Sources/Mataki"
        ),
        .testTarget(
            name: "MatakiTests",
            dependencies: ["Mataki"],
            path: "Tests/MatakiTests"
        ),
    ]
)
