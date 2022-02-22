import 'package:decibel_sdk/features/session_replay.dart';
import 'package:decibel_sdk/messages.dart';

class Tracking {
  Tracking._internal();
  static final _instance = Tracking._internal();
  static Tracking get instance => _instance;

  final DecibelSdkApi _apiInstance = DecibelSdkApi();
  String lastVisitedScreenName = '';
  int lastVisitedScreenId = 0;

  Future<void> startScreen(String name) async {
    lastVisitedScreenId++;
    //debugPrint('startScreen $name $lastVisitedScreenId');
    await _apiInstance.startScreen(
      StartScreenMessage()
        ..screenName = name
        ..screenId = lastVisitedScreenId
        ..startTime = DateTime.now().millisecondsSinceEpoch,
    );
    Future.delayed(const Duration(milliseconds: 250), () async {
      await SessionReplay.instance.forceTakeScreenshot();
    });
    lastVisitedScreenName = name;
  }

  Future<void> endScreen(String name) async {
    await _apiInstance.endScreen(
      EndScreenMessage()
        ..screenName = name
        ..screenId = lastVisitedScreenId
        ..endTime = DateTime.now().millisecondsSinceEpoch,
    );
  }
}
