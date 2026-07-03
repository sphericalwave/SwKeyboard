// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwKeyboard",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "SwKeyboard", targets: ["SwKeyboard"]),
    ],
    targets: [
        .target(name: "SwKeyboard"),
        .testTarget(name: "SwKeyboardTests", dependencies: ["SwKeyboard"]),
    ]
)
