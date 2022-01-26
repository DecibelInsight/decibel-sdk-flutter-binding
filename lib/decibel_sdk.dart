import 'dart:async';

import 'package:decibel_sdk/features/session_replay.dart';
import 'package:decibel_sdk/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'messages.dart';
import 'utility/enums.dart';

/// DecibelSdk main class
class DecibelSdk {
  static DecibelSdkApi? _apiInstance;
  static GlobalKey? captureKey;
  static bool isPageTransitioning = false;
  static String lastVisitedScreen = '';

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
    print("SetScreen $screenName");
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

  ///Listener for tabBar change of tab
  static void tabControllerListener(TabController tabController) {
    isPageTransitioning = tabController.indexIsChanging;
  }
}
