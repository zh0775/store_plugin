#include "include/store_plugin/store_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "store_plugin.h"

void StorePluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  store_plugin::StorePlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
