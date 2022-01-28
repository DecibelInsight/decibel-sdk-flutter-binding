import 'package:pigeon/pigeon.dart';

// TODO: Enum supported on Pigeon, but not List<Enum>. Waiting to talk about consents change.
// enum DecibelCustomerConsentType {
//   all,
//   recordingAndTracking,
//   tracking,
//   none,
// }

enum DecibelCurrency {
  AED,
  AFN,
  ALL,
  AMD,
  ANG,
  AOA,
  ARS,
  AUD,
  AWG,
  AZN,
  BAM,
  BBD,
  BDT,
  BGN,
  BHD,
  BIF,
  BMD,
  BND,
  BOB,
  BOV,
  BRL,
  BSD,
  BTN,
  BWP,
  BYN,
  BZD,
  CAD,
  CDF,
  CHE,
  CHF,
  CHW,
  CLF,
  CLP,
  CNY,
  COP,
  COU,
  CRC,
  CUC,
  CUP,
  CVE,
  CZK,
  DJF,
  DKK,
  DOP,
  DZD,
  EGP,
  ERN,
  ETB,
  EUR,
  FJD,
  FKP,
  GBP,
  GEL,
  GHS,
  GIP,
  GMD,
  GNF,
  GTQ,
  GYD,
  HKD,
  HNL,
  HRK,
  HTG,
  HUF,
  IDR,
  ILS,
  INR,
  IQD,
  IRR,
  ISK,
  JMD,
  JOD,
  JPY,
  KES,
  KGS,
  KHR,
  KMF,
  KPW,
  KRW,
  KWD,
  KYD,
  KZT,
  LAK,
  LBP,
  LKR,
  LRD,
  LSL,
  LYD,
  MAD,
  MDL,
  MGA,
  MKD,
  MMK,
  MNT,
  MOP,
  MRU,
  MUR,
  MVR,
  MWK,
  MXN,
  MXV,
  MYR,
  MZN,
  NAD,
  NGN,
  NIO,
  NOK,
  NPR,
  NZD,
  OMR,
  PAB,
  PEN,
  PGK,
  PHP,
  PKR,
  PLN,
  PYG,
  QAR,
  RON,
  RSD,
  RUB,
  RWF,
  SAR,
  SBD,
  SCR,
  SDG,
  SEK,
  SGD,
  SHP,
  SLL,
  SOS,
  SRD,
  SSP,
  STN,
  SVC,
  SYP,
  SZL,
  THB,
  TJS,
  TMT,
  TND,
  TOP,
  TRY,
  TTD,
  TWD,
  TZS,
  UAH,
  UGX,
  USD,
  USN,
  UYI,
  UYU,
  UYW,
  UZS,
  VES,
  VND,
  VUV,
  WST,
  XAF,
  XAG,
  XAU,
  XCD,
  XDR,
  XOF,
  XPD,
  XPF,
  XPT,
  XSU,
  XTS,
  XUA,
  XXX,
  YER,
  ZAR,
  ZMW,
  ZWL
}

class StartScreenMessage {
  String? screenName;
  int? screenId;
  int? startTime;
}

class EndScreenMessage {
  String? screenName;
  int? screenId;
  int? endTime;
}

class SessionMessage {
  String? account;
  String? property;
  List<int?>? consents;
}

class ConsentsMessage {
  List<int?>? consents;
}

class ScreenshotMessage {
  Uint8List? screenshotData;
  int? screenId;
  String? screenName;
  int? startFocusTime;
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
  void startScreen(StartScreenMessage msg);
  void endScreen(EndScreenMessage msg);
  void setEnableConsents(ConsentsMessage msg);
  void setDisableConsents(ConsentsMessage msg);
  void saveScreenshot(ScreenshotMessage msg);
  void sendDimensionWithString(DimensionStringMessage msg);
  void sendDimensionWithNumber(DimensionNumberMessage msg);
  void sendDimensionWithBool(DimensionBoolMessage msg);
  void sendGoal(GoalMessage msg);
}