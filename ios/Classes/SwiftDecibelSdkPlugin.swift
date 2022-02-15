import Flutter
import UIKit
import DecibelCoreFlutterSigma

public class SwiftDecibelSdkPlugin: NSObject, FlutterPlugin, FLTDecibelSdkApi {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger : FlutterBinaryMessenger = registrar.messenger()
        let api : FLTDecibelSdkApi & NSObjectProtocol = SwiftDecibelSdkPlugin.init()
        FLTDecibelSdkApiSetup(messenger, api);
      }

    public func initializeMsg(_ msg: FLTSessionMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        if let account = msg.account, let property = msg.property, let consents = msg.consents as? [Int] {
            DecibelSDK.flutter.initialize(account: String(describing: account), property: String(describing: property), consents: consents)
        } else if let account = msg.account, let property = msg.property {
            DecibelSDK.flutter.initialize(account: String(describing: account), property: String(describing: property))
        }
        DecibelSDK.flutter.setLogLevel(.info)
    }

    public func startScreenMsg(_ msg: FLTStartScreenMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        if let screenName = msg.screenName, let screenId = msg.screenId as? Int{
            DecibelSDK.flutter.set(screen: screenName, id: screenId)
        }
    }
    
    public func endScreenMsg(_ msg: FLTEndScreenMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
//        if let screenName = msg.screenName, let screenId = msg.screenId as? Int{
//            DecibelSDK.flutter.set(screen: screenName, id: screenId)
//        }
    }

    public func setEnableConsentsMsg(_ msg: FLTConsentsMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        if let consents = msg.consents as? [Int] {
            DecibelSDK.flutter.setEnableConsents(consents)
        }
    }

    public func setDisableConsentsMsg(_ msg: FLTConsentsMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        if let consents = msg.consents as? [Int] {
            DecibelSDK.flutter.setDisableConsents(consents)
        }
    }

    public func saveScreenshotMsg(_ msg: FLTScreenshotMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        if let screenshotData = msg.screenshotData, let screenId = msg.screenId as? Int, let screenName = msg.screenName,
           let startFocusTime = msg.startFocusTime as? TimeInterval {
            DecibelSDK.flutter.saveScreenShot(screenshot: screenshotData.data, id: screenId, screenName: screenName, startFocusTime: startFocusTime)
        }
    }
    
    public func sendDimension(withStringMsg msg: FLTDimensionStringMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        guard let dimensionName = msg.dimensionName else {
            return
        }
        
        guard let dimensionValue = msg.value else {
            return
        }
        
        DecibelSDK.flutter.send(dimension: dimensionName, withString: dimensionValue)
    }
    
    public func sendDimension(withNumberMsg msg: FLTDimensionNumberMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        guard let dimensionName = msg.dimensionName else {
            return
        }
        
        guard let dimensionValue = msg.value as? Double else {
            return
        }
        
        DecibelSDK.flutter.send(dimension: dimensionName, withNumber: dimensionValue)
    }
    
    public func sendDimension(withBoolMsg msg: FLTDimensionBoolMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        guard let dimensionName = msg.dimensionName else {
            return
        }
        
        guard let dimensionValue = msg.value as? Bool else {
            return
        }
        
        DecibelSDK.flutter.send(dimension: dimensionName, withBool: dimensionValue)
    }
    
    public func sendGoalMsg(_ msg: FLTGoalMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        guard let goalName = msg.goal else {
            return
        }

        guard let goalValue = msg.value as? Float else {
            DecibelSDK.flutter.send(goal: goalName)
            return
        }

        DecibelSDK.flutter.send(goal: goalName, with: goalValue)
    }
}
