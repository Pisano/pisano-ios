// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Pisano",
    products: [
        .library(
            name: "Pisano",
            targets: ["Pisano"]),
    ],
    targets: [
        .binaryTarget(
            name: "Pisano",
            path: "Feedback.xcframework"
        ),
    ]
)
