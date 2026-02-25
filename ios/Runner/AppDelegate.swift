import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        if let controller = window?.rootViewController as? FlutterViewController {
            let channel = FlutterMethodChannel(name: "yv_counter/config", binaryMessenger: controller.binaryMessenger)
            channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
                if call.method == "getServerClientId" {
                    // Try to read SERVER_CLIENT_ID from GoogleService-Info.plist
                    if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
                       let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
                        if let serverId = dict["SERVER_CLIENT_ID"] as? String {
                            result(serverId)
                            return
                        }
                        // Fallback: CLIENT_ID (may be the iOS client, not the web client)
                        if let clientId = dict["CLIENT_ID"] as? String {
                            result(clientId)
                            return
                        }
                    }
                    result("")
                } else {
                    result(FlutterMethodNotImplemented)
                }
            }
        }
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
