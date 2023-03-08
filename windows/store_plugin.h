#ifndef FLUTTER_PLUGIN_STORE_PLUGIN_H_
#define FLUTTER_PLUGIN_STORE_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace store_plugin {

class StorePlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  StorePlugin();

  virtual ~StorePlugin();

  // Disallow copy and assign.
  StorePlugin(const StorePlugin&) = delete;
  StorePlugin& operator=(const StorePlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace store_plugin

#endif  // FLUTTER_PLUGIN_STORE_PLUGIN_H_
