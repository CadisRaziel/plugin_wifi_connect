#import "PluginWifiConnectPlugin.h"
#if __has_include(<plugin_wifi_connect/plugin_wifi_connect-Swift.h>)
#import <plugin_wifi_connect/plugin_wifi_connect-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "plugin_wifi_connect-Swift.h"
#endif

@implementation PluginWifiConnectPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPluginWifiConnectPlugin registerWithRegistrar:registrar];
}
@end
