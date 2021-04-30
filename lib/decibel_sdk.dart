
import 'dart:async';

import 'package:flutter/services.dart';

class DecibelSdk {
  static const MethodChannel _channel =
      const MethodChannel('decibel_sdk');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> initialize() async {
    await _channel.invokeMethod('initialize');
  }

  static Future<void> setScreen (String screenName) async {
    await _channel.invokeMethod('setScreen', {"screenName":screenName});
  }
}
