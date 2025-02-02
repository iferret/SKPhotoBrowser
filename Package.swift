// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SKPhotoBrowser",
    platforms: [.iOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "SKPhotoBrowser", targets: ["SKPhotoBrowser"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "SKPhotoBrowser", dependencies: ["SKPhotoBrowserObjC"], path: "SKPhotoBrowser", exclude: ["Info.plist", "Extends/ObjC"], resources: [.copy("SKPhotoBrowser.bundle")]),
        .target(name: "SKPhotoBrowserObjC", path: "SKPhotoBrowser/Extends/ObjC", publicHeadersPath: "."),
        .testTarget(name: "SKPhotoBrowserTests", dependencies: ["SKPhotoBrowser"]),
    ]
)
