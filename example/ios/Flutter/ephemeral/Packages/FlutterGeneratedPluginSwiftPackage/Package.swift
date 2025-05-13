// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
//  Generated file. Do not edit.
//

import PackageDescription

let package = Package(
    name: "FlutterGeneratedPluginSwiftPackage",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(name: "FlutterGeneratedPluginSwiftPackage", type: .static, targets: ["FlutterGeneratedPluginSwiftPackage"])
    ],
    dependencies: [
        .package(name: "file_picker", path: "/Users/sosualfred/.pub-cache/hosted/pub.dev/file_picker-8.3.7/ios/file_picker"),
        .package(name: "image_picker_ios", path: "/Users/sosualfred/.pub-cache/hosted/pub.dev/image_picker_ios-0.8.12+2/ios/image_picker_ios"),
        .package(name: "webview_flutter_wkwebview", path: "/Users/sosualfred/.pub-cache/hosted/pub.dev/webview_flutter_wkwebview-3.20.0/darwin/webview_flutter_wkwebview")
    ],
    targets: [
        .target(
            name: "FlutterGeneratedPluginSwiftPackage",
            dependencies: [
                .product(name: "file-picker", package: "file_picker"),
                .product(name: "image-picker-ios", package: "image_picker_ios"),
                .product(name: "webview-flutter-wkwebview", package: "webview_flutter_wkwebview")
            ]
        )
    ]
)
