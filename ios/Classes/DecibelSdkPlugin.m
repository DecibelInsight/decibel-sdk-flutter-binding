#import "DecibelSdkPlugin.h"
#if __has_include(<decibel_sdk/decibel_sdk-Swift.h>)
#import <decibel_sdk/decibel_sdk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "decibel_sdk-Swift.h"
#endif

@implementation DecibelSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftDecibelSdkPlugin registerWithRegistrar:registrar];
}
@end
