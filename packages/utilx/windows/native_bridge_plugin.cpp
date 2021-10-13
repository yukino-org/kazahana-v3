#include "include/utilx/utilx_plugin.h"

#include <windows.h>

#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <map>
#include <memory>
#include <sstream>

HWND GetRootWindow(flutter::FlutterView *view) {
  return ::GetAncestor(view->GetNativeWindow(), GA_ROOT);
}

namespace {

class UtilXPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  UtilXPlugin(flutter::PluginRegistrarWindows* registrar);

  virtual ~UtilXPlugin();

 private:
  flutter::PluginRegistrarWindows *registrar;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

// static
void UtilXPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "utilx_native_bridge",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<UtilXPlugin>(registrar);

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

UtilXPlugin::UtilXPlugin(flutter::PluginRegistrarWindows* registrar): registrar(registrar) {}

UtilXPlugin::~UtilXPlugin() {}

void UtilXPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("focusWindow") == 0) {
    HWND hWnd = GetRootWindow(registrar->GetView());
    ::ShowWindow(hWnd, SW_SHOW);
    ::SetForegroundWindow(hWnd);
    ::BringWindowToTop(hWnd);
    result->Success();
  } else {
    result->NotImplemented();
  }
}

}  // namespace

void UtilXPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  UtilXPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
