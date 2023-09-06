// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PisanoFeedback",
    products: [
        .library(
            name: "PisanoFeedback",
            targets: ["PisanoFeedback"]),
    ],
    targets: [
        .binaryTarget(
            name: "PisanoFeedback",
            path: "PisanoFeedback.xcframework"
        ),
    ]
)
