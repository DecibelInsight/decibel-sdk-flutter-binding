import 'dart:async';

import 'package:decibel_sdk/features/session_replay.dart';
import 'package:decibel_sdk/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'messages.dart';
import 'utility/enums.dart' as enums;

/// DecibelSdk main class
class DecibelSdk {
  static DecibelSdkApi? _apiInstance;

  static DecibelSdkApi get _api {
    return _apiInstance ??= DecibelSdkApi();
  }

  /// Initializes DecibelSdk
  static Future<void> initialize(int account, int property,
      [List<enums.DecibelCustomerConsentType>? consents]) async {
    final sessionMessage = SessionMessage()
      ..account = account
      ..property = property
      ..consents = consents?.toIndexList();
    await _api.initialize(sessionMessage);
    if (consents != null) {
      if (consents.contains(enums.DecibelCustomerConsentType.all) ||
          consents.contains(enums.DecibelCustomerConsentType.recordingAndTracking)) {
        SessionReplay.instance.start();
      }
    } else {
      SessionReplay.instance.start();
    }
  }

  /// Enable the Customer Consents list passed as parameter
  static Future<void> setEnableConsents(
      List<enums.DecibelCustomerConsentType> consents) async {
    await _api.setEnableConsents(
        ConsentsMessage()..consents = consents.toIndexList());
    if (consents.contains(enums.DecibelCustomerConsentType.all) ||
        consents.contains(enums.DecibelCustomerConsentType.recordingAndTracking)) {
      SessionReplay.instance.start();
    }
  }

  /// Disable the Customer Consents list passed as parameter
  static Future<void> setDisableConsents(
      List<enums.DecibelCustomerConsentType> consents) async {
    await _api.setDisableConsents(
        ConsentsMessage()..consents = consents.toIndexList());
    if (consents.contains(enums.DecibelCustomerConsentType.all) ||
        consents.contains(enums.DecibelCustomerConsentType.recordingAndTracking)) {
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
  static Future<void> sendGoal(String goalName, double? value) async {
    final goal = GoalMessage()
      ..goal = goalName
      ..value = value;
    await _api.sendGoal(goal);
  }

  ///Listener for tabBar change of tab
  static void tabControllerListener(TabController tabController) {
    SessionReplay.instance.isPageTransitioning = tabController.indexIsChanging;
  }
}
