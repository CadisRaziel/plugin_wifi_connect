import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_wifi_connect/plugin_wifi_connect.dart';

void main() {
  const MethodChannel channel = MethodChannel('plugin_wifi_connect');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await PluginWifiConnect.ssid, '42');
  });
}
