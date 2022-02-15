import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../decibel_sdk.dart';
import '../utility/extensions.dart';
import '../messages.dart';
import 'tracking.dart';

class SessionReplay {
  SessionReplay._internal();
  static final _instance = SessionReplay._internal();
  static SessionReplay get instance => _instance;

  final DecibelSdkApi _apiInstance = DecibelSdkApi();
  final widgetsToMaskList = List<GlobalKey>.empty(growable: true);
  final _oldWidgetsList = List.empty(growable: true);
  final _newWidgetsList = List.empty(growable: true);
  final _paintBlue = Paint()..color = Colors.blue;
  GlobalKey? captureKey;
  bool isPageTransitioning = false;
  Timer? _timer;

  void start() {
    if (_timer == null) {
      _timer = Timer.periodic(const Duration(milliseconds: 250), (_) async {
        if (!isPageTransitioning && _didUiChange()) {
          if (captureKey != null && captureKey!.currentContext != null) {
            await _captureImage(captureKey!.currentContext!);
          }
        }
      });
      print("DecibelSDK: SessionReplay started");
    }
  }

  void stop() {
    if (_timer != null) {
      _timer = null;
      print("DecibelSDK: SessionReplay stopped");
    }
  }

  Future<void> forceTakeScreenshot() async {
    if (!isPageTransitioning &&
        captureKey != null &&
        captureKey!.currentContext != null) {
      print('forcing screenshot');
      await _captureImage(captureKey!.currentContext!);
    }
  }

  bool _didUiChange() {
    bool didUiChange = false;
    void findChildren(List<Element> list) {
      for (final child in list) {
        _newWidgetsList.add(child.widget);
        findChildren(child.children);
      }
    }

    if (WidgetsBinding.instance?.renderViewElement != null) {
      findChildren(WidgetsBinding.instance!.renderViewElement!.children);
      didUiChange = !listEquals(_oldWidgetsList, _newWidgetsList);
      _oldWidgetsList.clear();
      _oldWidgetsList.addAll(_newWidgetsList);
      _newWidgetsList.clear();
    }
    return didUiChange;
  }

  Future<void> _captureImage(BuildContext context) async {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, width, height),
    );
    try {
      final renderObject = context.findRenderObject();
      if (renderObject != null) {
        final image = await (renderObject as RenderRepaintBoundary).toImage();
        canvas.drawImage(image, Offset.zero, Paint());
        // Paint a rect in the widgets position to be masked
        final _previousCoordsList = List<Rect>.empty(growable: true);
        print('masks to apply ${widgetsToMaskList.length}');
        for (final globalKey in widgetsToMaskList) {
          globalKey.globalPaintBounds?.let((it) {
            _previousCoordsList.add(it);
            canvas.drawRect(it, _paintBlue);
          });
        }
        final resultImage = await recorder
            .endRecording()
            .toImage(width.toInt(), height.toInt());
        final resultImageData =
            await resultImage.toByteData(format: ui.ImageByteFormat.png);

        final _currentCoordsList = List<Rect>.empty(growable: true);
        for (final globalKey in widgetsToMaskList) {
          globalKey.globalPaintBounds?.let((it) {
            _currentCoordsList.add(it);
          });
        }
        // We compare these lists to check that the masks won't be misplaced
        if (resultImageData != null &&
            listEquals(_previousCoordsList, _currentCoordsList)) {
          if (_timer != null && !isPageTransitioning) {
            print('Saving screenshot ${Tracking.instance.lastVisitedScreenId}');
            await _sendScreenshot(
                resultImageData.buffer.asUint8List(),
                Tracking.instance.lastVisitedScreenId,
                Tracking.instance.lastVisitedScreenName,
                DateTime.now().millisecondsSinceEpoch);
          }
        }
      }
    } on Exception catch (_) {
      //TODO: Handle exception
    }
  }

  Future<void> _sendScreenshot(Uint8List screenshotData, int screenId,
      String screenName, int startFocusTime) async {
    await _apiInstance.saveScreenshot(ScreenshotMessage()
      ..screenshotData = screenshotData
      ..screenId = screenId
      ..screenName = screenName
      ..startFocusTime = startFocusTime);
  }
}
