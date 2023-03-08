import 'package:flutter_test/flutter_test.dart';
import 'package:store_plugin/store_plugin.dart';
import 'package:store_plugin/store_plugin_platform_interface.dart';
import 'package:store_plugin/store_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockStorePluginPlatform
    with MockPlatformInterfaceMixin
    implements StorePluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final StorePluginPlatform initialPlatform = StorePluginPlatform.instance;

  test('$MethodChannelStorePlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelStorePlugin>());
  });

  test('getPlatformVersion', () async {
    StorePlugin storePlugin = StorePlugin();
    MockStorePluginPlatform fakePlatform = MockStorePluginPlatform();
    StorePluginPlatform.instance = fakePlatform;

    expect(await storePlugin.getPlatformVersion(), '42');
  });
}
