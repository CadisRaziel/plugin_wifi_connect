import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_wifi_connect_example/main.dart';

void main() {
  const MethodChannel channel = MethodChannel('plugin_wifi_connect');
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  testWidgets('displays the SSID returned by the plugin',
      (WidgetTester tester) async {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel,
        (MethodCall call) async {
      expect(call.method, 'getSSID');
      return 'Device_WiFi';
    });
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text('Network SSID: Device_WiFi\n'), findsOneWidget);
  });

  testWidgets('displays the error state when the platform call fails',
      (WidgetTester tester) async {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel,
        (MethodCall call) async {
      throw PlatformException(code: 'unavailable');
    });
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text('Network SSID: Failed to get ssid\n'), findsOneWidget);
  });
}
