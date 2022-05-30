// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:collection';

import 'package:decibel_sdk/features/session_replay.dart';
import 'package:decibel_sdk/messages.dart';
import 'package:flutter/foundation.dart';

class Tracking {
  Tracking._internal();
  static final _instance = Tracking._internal();
  static Tracking get instance => _instance;

  final DecibelSdkApi _apiInstance = DecibelSdkApi();
  // String lastVisitedScreenName = '';
  // int lastVisitedScreenId = 0;
  List<ScreenVisited> visitedScreensList = List.empty(growable: true);

  Future<void> startScreen(String name) async {
    // debugPrint('start Screen $name');
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    final ScreenVisited screenVisited = ScreenVisited(timestamp, name);

    visitedScreensList.add(
      screenVisited,
    );
    //debugPrint('startScreen $name $lastVisitedScreenId');
    await _apiInstance.startScreen(
      StartScreenMessage()
        ..screenName = screenVisited.name
        ..screenId = screenVisited.id
        ..startTime = timestamp,
    );
    Future.delayed(const Duration(milliseconds: 250), () async {
      await SessionReplay.instance.forceTakeScreenshot();
    });
  }

  Future<void> endScreen(ScreenVisited lastVisitedScreen) async {
    // debugPrint('end Screen ${lastVisitedScreen.name}');
    await _apiInstance.endScreen(
      EndScreenMessage()
        ..screenName = lastVisitedScreen.name
        ..screenId = lastVisitedScreen.id
        ..endTime = DateTime.now().millisecondsSinceEpoch,
    );
  }
}

class ScreenVisited {
  final int id;
  final String name;

  ScreenVisited(
    this.id,
    this.name,
  );
}
