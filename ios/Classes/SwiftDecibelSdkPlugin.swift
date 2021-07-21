import Flutter
import UIKit
import DecibelCore

public class SwiftDecibelSdkPlugin: NSObject, FlutterPlugin, FLTDecibelSdkApi {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger : FlutterBinaryMessenger = registrar.messenger()
        let api : FLTDecibelSdkApi = SwiftDecibelSdkPlugin.init()
        FLTDecibelSdkApiSetup(messenger, api);
      }

    public func initialize(_ input: FLTSessionMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        if let account = input.account, let property = input.property, let consents = input.consents as? [Int] {
            DecibelSDK.shared.initialize(account: account, property: property, consents: consents)
        } else if let account = input.account, let property = input.property {
            DecibelSDK.shared.initialize(account: account, property: property)
        }
        DecibelSDK.shared.setLogLevel(.info)
    }

    public func setScreen(_ input: FLTScreenMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        if let screenName = input.screenName {
            DecibelSDK.shared.set(screen: screenName)
        }
    }

    public func setEnableConsents(_ input: FLTConsentsMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        if let consents = input.consents as? [Int] {
            DecibelSDK.shared.setEnableConsents(consents)
        }
    }

    public func setDisableConsents(_ input: FLTConsentsMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        if let consents = input.consents as? [Int] {
            DecibelSDK.shared.setDisableConsents(consents)
        }
    }

    public func sendScreenshot(_ input: FLTScreenshotMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        if let screenshotData = input.screenshotData {
            DecibelSDK.shared.addImageData(screenshotData.data)
        }
    }
    
    public func sendDimension(withString input: FLTDimensionStringMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        guard let dimensionName = input.dimensionName else {
            return
        }
        
        guard let dimensionValue = input.value else {
            return
        }
        
        DecibelSDK.shared.send(dimension: dimensionName, withString: dimensionValue)
    }
    
    public func sendDimension(withNumber input: FLTDimensionNumberMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        guard let dimensionName = input.dimensionName else {
            return
        }
        
        guard let dimensionValue = input.value as? Double else {
            return
        }
        
        DecibelSDK.shared.send(dimension: dimensionName, withNumber: dimensionValue)
    }
    
    public func sendDimension(withBool input: FLTDimensionBoolMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        guard let dimensionName = input.dimensionName else {
            return
        }
        
        guard let dimensionValue = input.value as? Bool else {
            return
        }
        
        DecibelSDK.shared.send(dimension: dimensionName, withBool: dimensionValue)
    }
    
    public func sendGoal(_ input: FLTGoalMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        guard let goalName = input.goal else {
            return
        }
        
        guard let goalValue = input.value as? Float,
              let goalCurrency = input.currency as? Int,
              let currency = DecibelCurrency(rawValue: goalCurrency) else {
            
            guard let goalValue = input.value as? Float else {
                DecibelSDK.shared.send(goal: goalName)
                return
            }
            
            DecibelSDK.shared.send(goal: goalName, with: goalValue)
            return
        }
        
        DecibelSDK.shared.send(goal: goalName, with: goalValue, currency: currency)
    }
}
