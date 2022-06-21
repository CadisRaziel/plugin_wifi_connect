# plugin_wifi_connect

This package is a continuation of the package below:

https://pub.dev/packages/flutter_wifi_connect

We will take care, so that the necessary maintenance can always occur, as well as new features,

we thank weplenish for allowing us to continue the project, which we need to use, due to our work.

## summary:

A low dependency flutter plugin to allow simple connection to wifi devices with the provided ssid or ssid prefix. Built for Android 10+ (API 29) and iOS 11+.

This plugin is made with the latest / greatest direct connect to wifi options. It's intent is to make it easy to programmatically connect to devices that broadcast unique SSIDs. Items like IOT devices.

This should connect to an explicit SSID on iOS 11+ and Android 1+. To connect to an SSID matching a prefix it should work on iOS 13+ and Android 1+. On Android 1-29 it will scan nearby wifi networks and attempt to connect to the one matching the prefix (requiring ACCESS_FINE_LOCATIONS).

## Getting Started

Ensure you have the permissions set up and request them appropriately for each platform. This plugin's goal isn't to force permissions. This means if you have a different target, you don't need more permissions than you would otherwise be forced to require.

Permissions 

# iOS

These must be added in xcode

- Access WiFi Information Entitlement (to request ssid and ensure connection to the correct network)
- Hotspot Configuration Entitlement (to connect to a network)

# Android

Make sure you verify permissions during runtime (using a permission plugin). In Android it looks like this

29+ (Android Q+)
- ACCESS_FINE_LOCATION (only if using get ssid)

Older than 29 (P and older)

- ACCESS_WIFI_STATE
- CHANGE_WIFI_STATE
- CHANGE_NETWORK_STATE
- ACCESS_FINE_LOCATION (only if using prefix Connect)

