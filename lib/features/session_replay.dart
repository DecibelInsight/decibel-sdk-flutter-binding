import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../decibel_sdk.dart';
import '../extensions.dart';
import '../messages.dart';

class SessionReplay {
  final widgetsToMaskList = List<GlobalKey>.empty(growable: true);
  final _oldWidgetsList = List.empty(growable: true);
  final _newWidgetsList = List.empty(growable: true);
  final _paintBlue = Paint()..color = Colors.blue;
  final _paintEmpty = Paint();
  final _offset = Offset(0.0, 0.0);
  late Timer _timer;
  late DecibelSdkApi decibelSdkApi;

  static final _instance = SessionReplay._internal();
  SessionReplay._internal();
  static SessionReplay get instance => _instance;

  void start() {
    print("DecibelSDK: SessionReplay started");
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _timer = Timer.periodic(Duration(milliseconds: 1000), (timer) async {
        if (!DecibelSdk.isPageTransitioning && _didUiChange()) {
          if (DecibelSdk.captureKey != null &&
              DecibelSdk.captureKey!.currentContext != null) {
            _captureImage(DecibelSdk.captureKey!.currentContext!);
          }
        }
      });
    });
  }

  void stop() {
    print("DecibelSDK: SessionReplay stopped");
    if (_timer.isActive) {
      _timer.cancel();
    }
  }

  bool _didUiChange() {
    bool didUiChange = false;
    void findChildren(List<Element> list) {
      list.forEach((element) {
        _newWidgetsList.add(element.widget);
        findChildren(element.children);
      });
    }

    findChildren(WidgetsBinding.instance!.renderViewElement!.children);
    didUiChange = !listEquals(_oldWidgetsList, _newWidgetsList);
    _oldWidgetsList.clear();
    _oldWidgetsList.addAll(_newWidgetsList);
    _newWidgetsList.clear();
    return didUiChange;
  }

  Future<void> _captureImage(BuildContext context) async {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
        recorder, Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()));
    final image =
        await (context.findRenderObject() as RenderRepaintBoundary).toImage();

    canvas.drawImage(image, _offset, _paintEmpty);
    // Paint a rect in the widgets position to be masked
    widgetsToMaskList.forEach((globalKey) {
      if (globalKey.globalPaintBounds != null) {
        canvas.drawRect(globalKey.globalPaintBounds!, _paintBlue);
      }
    });
    final resultImage =
        await recorder.endRecording().toImage(width.toInt(), height.toInt());
    final resultImageData =
        await resultImage.toByteData(format: ui.ImageByteFormat.png);
    if (resultImageData != null) {
      await decibelSdkApi.sendScreenshot(ScreenshotMessage()
        ..screenshotData = resultImageData.buffer.asUint8List());
    }
    print("Screenshot // maskListSize:" + widgetsToMaskList.length.toString());
  }
}
