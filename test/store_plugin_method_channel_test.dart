import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_plugin/store_plugin_method_channel.dart';

void main() {
  MethodChannelStorePlugin platform = MethodChannelStorePlugin();
  const MethodChannel channel = MethodChannel('store_plugin');

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
    expect(await platform.getPlatformVersion(), '42');
  });
}
