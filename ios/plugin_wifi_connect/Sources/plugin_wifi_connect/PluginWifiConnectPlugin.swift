#if SWIFT_PACKAGE
import Flutter

// Keep the pluginClass declared in pubspec.yaml and delegate registration to
// the same implementation used by the CocoaPods Objective-C bridge.
public class PluginWifiConnectPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        SwiftPluginWifiConnectPlugin.register(with: registrar)
    }
}
#endif
