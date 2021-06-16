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
    }
    
    public func setScreen(_ input: FLTScreenMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        if let screenName = input.screenName {
            DecibelSDK.shared.set(screen: screenName)
        }
    }
    
    public func uiChanged(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        DecibelSDK.shared.uiChanged()
    }
    
    public func setEnableConsents(_ input: FLTConsentsMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        if let consents = input.consents as? [Int] {
            print(consents)
            DecibelSDK.shared.setEnableConsents(consents)
        }
    }
    
    public func setDisableConsents(_ input: FLTConsentsMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        if let consents = input.consents as? [Int] {
            print(consents)
            DecibelSDK.shared.setDisableConsents(consents)
        }
    }
}
