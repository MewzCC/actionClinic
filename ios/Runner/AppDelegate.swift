import Flutter
import UIKit
import WidgetKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "actionClinic/android",
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { call, result in
        let args = call.arguments as? [String: Any] ?? [:]
        switch call.method {
        case "syncWidget", "scheduleReminders":
          self.saveWidgetState(args)
          if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
          }
          result(nil)
        case "cancelReminders", "startStrictFocus", "stopStrictFocus", "openOverlayPermission":
          result(nil)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  private func saveWidgetState(_ args: [String: Any]) {
    let defaults = UserDefaults(suiteName: "group.actionClinic.widget") ?? .standard
    defaults.set(args["title"] as? String ?? "行动任务", forKey: "title")
    defaults.set(args["description"] as? String ?? "现在就去行动", forKey: "description")
    defaults.set(args["remainingLabel"] as? String ?? "00:00", forKey: "remainingLabel")
    defaults.set(args["deadlineLabel"] as? String ?? "--:--", forKey: "deadlineLabel")
    defaults.set(args["status"] as? String ?? "waiting", forKey: "status")
    defaults.synchronize()
  }
}
