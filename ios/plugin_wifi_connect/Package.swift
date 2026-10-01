// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "plugin_wifi_connect",
    platforms: [.iOS("11.0")],
    products: [
        .library(name: "plugin-wifi-connect", targets: ["plugin_wifi_connect"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "plugin_wifi_connect",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            // CocoaPods retains the Objective-C registration bridge. SwiftPM
            // uses the Swift registration class to avoid a mixed-language target.
            exclude: ["PluginWifiConnectPlugin.h", "PluginWifiConnectPlugin.m"]
        )
    ],
    swiftLanguageVersions: [.v5]
)
