import 'dart:async';
import 'dart:typed_data';

import 'package:decibel_sdk/features/session_replay.dart';
import 'package:decibel_sdk/extensions.dart';
import 'package:flutter/material.dart';
import 'messages.dart';

/// Types of Customer Consent
enum DecibelCustomerConsentType {
  /// All consents
  all,
  /// Only Session Replay and tracking
  recordingAndTracking,
  /// Only tracking
  tracking,
  /// No consents
  none
}

/// DecibelSdk main class
class DecibelSdk {
  static DecibelSdkApi? _apiInstance;
  static GlobalKey? captureKey;
  static bool isPageTransitioning = false;

  static DecibelSdkApi get _api {
    return _apiInstance ??= DecibelSdkApi();
  }

  /// Initializes DecibelSdk
  static Future<void> initialize(String account, String property,
      [List<DecibelCustomerConsentType>? consents]) async {
    final sessionMessage = SessionMessage()
      ..account = account
      ..property = property
      ..consents = consents?.toIndexList();
    await _api.initialize(sessionMessage);
    SessionReplay.instance.decibelSdkApi = _api;
    if (consents != null) {
      if (consents.contains(DecibelCustomerConsentType.all) ||
          consents.contains(DecibelCustomerConsentType.recordingAndTracking)) {
        SessionReplay.instance.start();
      }
    } else {
      SessionReplay.instance.start();
    }
  }

  /// Set the name of the page to track
  static Future<void> setScreen(String screenName) async {
    await _api.setScreen(ScreenMessage()..screenName = screenName);
  }

  /// Enable the Customer Consents list passed as parameter
  static Future<void> setEnableConsents(
      List<DecibelCustomerConsentType> consents) async {
    await _api.setEnableConsents(
        ConsentsMessage()..consents = consents.toIndexList());
    if (consents.contains(DecibelCustomerConsentType.all) ||
        consents.contains(DecibelCustomerConsentType.recordingAndTracking)) {
      SessionReplay.instance.start();
    }
  }

  /// Disable the Customer Consents list passed as parameter
  static Future<void> setDisableConsents(
      List<DecibelCustomerConsentType> consents) async {
    await _api.setDisableConsents(
        ConsentsMessage()..consents = consents.toIndexList());
    if (consents.contains(DecibelCustomerConsentType.all) ||
        consents.contains(DecibelCustomerConsentType.recordingAndTracking)) {
      SessionReplay.instance.stop();
    }
  }

  ///Set custom dimension with string
  static Future<void> setDimensionWithString(String dimensionName, String value) async {
    final dimension = DimensionStringMessage()
                      ..dimensionName = dimensionName
                      ..value = value;
    await _api.sendDimensionWithString(dimension);
  }

  ///Set custom dimension with number
  static Future<void> setDimensionWithNumber(String dimensionName, double value) async {
    final dimension = DimensionNumberMessage()
      ..dimensionName = dimensionName
      ..value = value;
    await _api.sendDimensionWithNumber(dimension);
  }

  ///Set custom dimension with bool
  static Future<void> setDimensionWithBool(String dimensionName, bool value) async {
    final dimension = DimensionBoolMessage()
      ..dimensionName = dimensionName
      ..value = value;
    await _api.sendDimensionWithBool(dimension);
  }

  ///Send goals
  static Future<void> sendGoal(String goalName, double? value, DecibelCurrency? currency) async {
    final goal = GoalMessage()
      ..goal = goalName
      ..value = value
      ..currency = currency?.index;
    await _api.sendGoal(goal);
  }
}

/// Decibel currency
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
