import 'package:pigeon/pigeon.dart';

// TODO: Waiting new Pigeon release to support enums
// enum DecibelCustomerConsentType {
//   all,
//   recordingAndTracking,
//   tracking,
//   none,
// }

class ScreenMessage {
  String? screenName;
}

class SessionMessage {
  String? account;
  String? property;
  List<int>? consents;
  // DecibelCustomerConsentType? consents;
}

class ConsentsMessage {
  List<int>? consents;
}

class ScreenshotMessage {
  Uint8List? screenshotData;
}

class DimensionStringMessage {
  String? dimensionName;
  String? value;
}

class DimensionNumberMessage {
  String? dimensionName;
  double? value;
}

class DimensionBoolMessage {
  String? dimensionName;
  bool? value;
}

class GoalMessage {
  String? goal;
  double? value;
  int? currency;
}

@HostApi()
abstract class DecibelSdkApi {
  void initialize(SessionMessage msg);
  void setScreen(ScreenMessage msg);
  void setEnableConsents(ConsentsMessage msg);
  void setDisableConsents(ConsentsMessage msg);
  void sendScreenshot(ScreenshotMessage msg);
  void sendDimensionWithString(DimensionStringMessage msg);
  void sendDimensionWithNumber(DimensionNumberMessage msg);
  void sendDimensionWithBool(DimensionBoolMessage msg);
  void sendGoal(GoalMessage msg);
}

void configurePigeon(PigeonOptions opts) {
  opts.dartOut = 'lib/messages.dart';
  opts.objcHeaderOut = 'ios/Classes/messages.h';
  opts.objcSourceOut = 'ios/Classes/messages.m';
  opts.objcOptions!.prefix = 'FLT';
  opts.javaOut =
  'android/src/main/kotlin/com/decibel/decibel_sdk/Messages.java';
  opts.javaOptions!.package = 'com.decibel.decibel_sdk';
}