import Flutter
import UIKit
import DecibelCore

public class SwiftDecibelSdkPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "decibel_sdk", binaryMessenger: registrar.messenger())
    let instance = SwiftDecibelSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initialize":
        DecibelSDK.shared.initialize(account: "10010", property: "250441")
    case "setScreen":
        if let args = call.arguments as? Dictionary<String, Any>,
            let screenName = args["screenName"] as? String {
            DecibelSDK.shared.set(screen: screenName)
          } else {
            result(FlutterError.init(code: "setScreen", message: "argument error", details: nil))
          }
    default:
        result(FlutterMethodNotImplemented)
    }
    return
  }
}
