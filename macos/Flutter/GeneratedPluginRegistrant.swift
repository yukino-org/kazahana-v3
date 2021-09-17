//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import dart_vlc
import package_info_plus_macos
import path_provider_macos
import url_launcher_macos
import wakelock_macos
import window_manager

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  DartVlcPlugin.register(with: registry.registrar(forPlugin: "DartVlcPlugin"))
  FLTPackageInfoPlusPlugin.register(with: registry.registrar(forPlugin: "FLTPackageInfoPlusPlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  UrlLauncherPlugin.register(with: registry.registrar(forPlugin: "UrlLauncherPlugin"))
  WakelockMacosPlugin.register(with: registry.registrar(forPlugin: "WakelockMacosPlugin"))
  WindowManagerPlugin.register(with: registry.registrar(forPlugin: "WindowManagerPlugin"))
}
