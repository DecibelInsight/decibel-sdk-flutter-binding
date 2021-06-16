import 'dart:async';

import 'package:decibel_sdk/features/session_replay.dart';

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

  static DecibelSdkApi get _api {
    return _apiInstance ??= DecibelSdkApi();
  }

  /// Initializes DecibelSdk
  static Future<void> initialize(String account, String property,
      [List<DecibelCustomerConsentType>? consents]) async {
    final SessionMessage sessionMessage = SessionMessage()
      ..account = account
      ..property = property
      ..consents = consents?.toIndexList();
    await _api.initialize(sessionMessage);
    if (consents != null &&
        (consents.contains(DecibelCustomerConsentType.all) ||
            consents.contains(DecibelCustomerConsentType.recordingAndTracking))){
      SessionReplay().checkUiChanges(_api);
    }
  }

  /// Set the name of the page to track
  static Future<void> setScreen(String screenName) async {
    await _api.setScreen(ScreenMessage()..screenName = screenName);
  }

  /// Enable the Customer Consents list passed as parameter
  static Future<void> setEnableConsents(List<DecibelCustomerConsentType> consents) async {
    await _api.setEnableConsents(ConsentsMessage()..consents = consents.toIndexList());
  }

  /// Disable the Customer Consents list passed as parameter
  static Future<void> setDisableConsents(List<DecibelCustomerConsentType> consents) async {
    await _api.setDisableConsents(ConsentsMessage()..consents = consents.toIndexList());
  }
}

extension _ListDecibelCustomerConsentTypeExt on List<DecibelCustomerConsentType> {
  List<int> toIndexList() {
    return map((DecibelCustomerConsentType consent) => consent.index).toList();
  }
}