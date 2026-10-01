import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_wifi_connect/plugin_wifi_connect.dart';

void main() {
  const MethodChannel channel = MethodChannel('plugin_wifi_connect');

  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();
  final List<MethodCall> calls = <MethodCall>[];
  Object? response;

  setUp(() {
    calls.clear();
    response = true;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel,
        (MethodCall methodCall) async {
      calls.add(methodCall);
      return response;
    });
  });

  tearDown(() {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('ssid invokes getSSID and returns the network name', () async {
    response = 'Device_WiFi';
    expect(await PluginWifiConnect.ssid, 'Device_WiFi');
    expect(calls.single.method, 'getSSID');
    expect(calls.single.arguments, isNull);
  });

  test('ssid preserves a null native response', () async {
    response = null;
    expect(await PluginWifiConnect.ssid, isNull);
  });

  test('connect sends the SSID and default saveNetwork', () async {
    expect(await PluginWifiConnect.connect('Device_WiFi'), isTrue);
    expect(calls.single.method, 'connect');
    expect(calls.single.arguments,
        <String, dynamic>{'ssid': 'Device_WiFi', 'saveNetwork': false});
  });

  test('connectByPrefix forwards saveNetwork and native failure', () async {
    response = false;
    expect(
        await PluginWifiConnect.connectByPrefix('Device_', saveNetwork: true),
        isFalse);
    expect(calls.single.method, 'prefixConnect');
    expect(calls.single.arguments,
        <String, dynamic>{'ssid': 'Device_', 'saveNetwork': true});
  });

  test('secure connection forwards all options', () async {
    expect(
      await PluginWifiConnect.connectToSecureNetwork('Device_WiFi', 'password',
          isWep: true, isWpa3: true, saveNetwork: true, isHidden: true),
      isTrue,
    );
    expect(calls.single.method, 'secureConnect');
    expect(calls.single.arguments, <String, dynamic>{
      'ssid': 'Device_WiFi',
      'password': 'password',
      'saveNetwork': true,
      'isWep': true,
      'isWpa3': true,
      'isHidden': true,
    });
  });

  test('secure prefix connection forwards default options', () async {
    expect(
      await PluginWifiConnect.connectToSecureNetworkByPrefix(
          'Device_', 'password'),
      isTrue,
    );
    expect(calls.single.method, 'securePrefixConnect');
    expect(calls.single.arguments, <String, dynamic>{
      'ssid': 'Device_',
      'password': 'password',
      'saveNetwork': false,
      'isWep': false,
      'isWpa3': false,
    });
  });

  test('disconnect invokes the native method without arguments', () async {
    expect(await PluginWifiConnect.disconnect(), isTrue);
    expect(calls.single.method, 'disconnect');
    expect(calls.single.arguments, isNull);
  });

  test('connection preserves a null native response', () async {
    response = null;
    expect(await PluginWifiConnect.connect('Device_WiFi'), isNull);
  });

  test('native errors reach the caller', () async {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel,
        (MethodCall call) async {
      throw PlatformException(code: 'missingArgs', message: 'Missing args');
    });
    await expectLater(
      PluginWifiConnect.connect('Device_WiFi'),
      throwsA(isA<PlatformException>().having(
          (PlatformException error) => error.code, 'code', 'missingArgs')),
    );
  });
}
