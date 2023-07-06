// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:decibel_sdk/src/decibel_config.dart';
import 'package:decibel_sdk/src/features/autoMasking/auto_masking_class.dart';
import 'package:decibel_sdk/src/features/frame_tracking.dart';
import 'package:decibel_sdk/src/features/tracking/screen_visited.dart';
import 'package:decibel_sdk/src/features/tracking/tracking.dart';
import 'package:decibel_sdk/src/messages.dart';
import 'package:decibel_sdk/src/utility/completer_wrappers.dart';
import 'package:decibel_sdk/src/utility/dependency_injector.dart';
import 'package:decibel_sdk/src/utility/extensions.dart';
import 'package:decibel_sdk/src/utility/logger_sdk.dart';
import 'package:decibel_sdk/src/utility/placeholder_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:logger/logger.dart';

class SessionReplay {
  SessionReplay(
    this._medalliaDxaConfig,
    this._logger,
    this._frameTracking,
    this.autoMasking,
    this._placeholderImageConfig,
    this.widgetsBindingInstance,
    this.schedulerBindingInstance,
    this.screenshotTaker,
    this._nativeApiInstance,
  ) {
    timer = Timer.periodic(const Duration(milliseconds: 250), (_) async {
      await tryToTakeScreenshotIfUiHasChanged();
    });
    _frameTracking.newFrameStreamController.stream.listen((timeStamp) {
      didUiChangeValue = true;
    });
  }

  final MedalliaDxaConfig _medalliaDxaConfig;
  final LoggerSDK _logger;
  Logger get logger => _logger.sessionReplayLogger;
  final FrameTracking _frameTracking;
  final AutoMasking autoMasking;
  final PlaceholderImageConfig _placeholderImageConfig;
  final MedalliaDxaNativeApi _nativeApiInstance;
  final ScreenshotTaker screenshotTaker;
  final WidgetsBinding widgetsBindingInstance;
  final SchedulerBinding schedulerBindingInstance;
  late final Tracking _tracking = DependencyInjector.instance.tracking;
  @visibleForTesting
  late Timer timer;
  @visibleForTesting
  ScreenshotMessage? lastScreenshotSent;
  bool _alreadyWaitingForPostFrameCallback = false;
  bool _waitingForEndOfFrame = false;
  bool get _currentlyTracking => _tracking.visitedUnfinishedScreen != null;

  ///Don't use this variable across asynchronous gaps, it could change
  ScreenVisited get _currentTrackedScreen {
    return _tracking.visitedUnfinishedScreen!;
  }

  @visibleForTesting
  bool didUiChangeValue = false;
  @visibleForTesting
  bool get didUiChange => didUiChangeValue;
  set didUiChange(bool change) {
    didUiChangeValue = change;
    if (!change) {
      _frameTracking.waitForNextFrame();
    }
  }

  void _forceScreenshotNextFrame() {
    if (_alreadyWaitingForPostFrameCallback) return;
    _alreadyWaitingForPostFrameCallback = true;
    widgetsBindingInstance.addPostFrameCallback((_) async {
      _alreadyWaitingForPostFrameCallback = false;
      await _tryToTakeScreenshot();
    });
  }

  Future<void> newScreen() async {
    didUiChange = true;
    final bool isNotTabbar = _tracking.visitedScreensList.isEmpty ||
        !_tracking.visitedScreensList.last.isTabBar;
    if (isNotTabbar) {
      await tryToTakeScreenshotIfUiHasChanged();
    }
  }

  void startPeriodicTimer() {
    if (timer.isActive) return;
    timer = Timer.periodic(const Duration(milliseconds: 250), (_) async {
      await tryToTakeScreenshotIfUiHasChanged();
    });
  }

  void stopPeriodicTimer() {
    timer.cancel();
  }

  void clearMasks() {
    autoMasking.clear();
  }

  Future<void> tryToTakeScreenshotIfUiHasChanged() async {
    if (!didUiChange) return;
    return _tryToTakeScreenshot();
  }

  Future<void> _tryToTakeScreenshot() async {
    if (!_medalliaDxaConfig.recordingAllowed) return;
    if (!_currentlyTracking) return;
    final ScreenVisited currentTrackedScreen = _currentTrackedScreen;
    if (currentTrackedScreen.isCurrentScreenOverMaxDuration) return;
    if (!currentTrackedScreen.recordingAllowed) {
      return _sendOnePlaceholderImageForThisScreen(
        screenVisited: currentTrackedScreen,
      );
    }

    if (_tracking.areThereOngoingAnimations ||
        !currentTrackedScreen.widgetInTheTree) {
      return _forceScreenshotNextFrame();
    }
    if (_waitingForEndOfFrame) return;

    ///No need to wait for the endOfFrame when we are in other phases.
    ///Also ensures this is not called in other phases where a frame may not
    ///be scheduled
    if (schedulerBindingInstance.schedulerPhase == SchedulerPhase.idle) {
      _waitingForEndOfFrame = true;
      await widgetsBindingInstance.endOfFrame;
      _waitingForEndOfFrame = false;
      if (!_currentlyTracking) return;
      if (_tracking.areThereOngoingAnimations ||
          !currentTrackedScreen.widgetInTheTree) {
        return _forceScreenshotNextFrame();
      }
    }
    if (!isFrameTimeWindowSafe) {
      _forceScreenshotNextFrame();
      return;
    }
    final int screenShotId = currentTrackedScreen.uniqueId;
    final String screenShotName = currentTrackedScreen.name;
    final int startFocusTime = DateTime.now().millisecondsSinceEpoch;
    final ByteData? resultImageData = await screenshotTaker.captureImage(
      screenVisited: currentTrackedScreen,
      uiChangedReset: () => didUiChange = false,
      forceScreeshotNextFrame: _forceScreenshotNextFrame,
    );
    if (resultImageData == null) return;
    await _sendScreenshot(
      resultImageData.buffer.asUint8List(),
      screenShotId,
      screenShotName,
      startFocusTime,
      currentTrackedScreen,
    );
  }

  Future<void> _sendScreenshot(
    Uint8List screenshotData,
    int screenId,
    String screenName,
    int startFocusTime,
    ScreenVisited screenVisited,
  ) async {
    final ScreenshotMessage screenshotMessage = ScreenshotMessage(
      screenshotData: screenshotData,
      screenId: screenId,
      screenName: screenName,
      startFocusTime: startFocusTime,
    );

    lastScreenshotSent = screenshotMessage;
    screenVisited.screenshotTakenList.add(
      ScreenShotTaken(startFocusTime: startFocusTime),
    );
    logger.d(
      'Save screenshot - screenName: $screenName - screenId: $screenId - startFocusTime: $startFocusTime',
    );
    await _nativeApiInstance.saveScreenshot(screenshotMessage);
  }

  ///Resends the last screenshot to native (with a new focusTime) only
  ///if there's been a second or more without any new screenshots
  Future<void> closeScreenVideo(ScreenVisited screenVisited) async {
    if (lastScreenshotSent != null &&
        DateTime.now().millisecondsSinceEpoch -
                lastScreenshotSent!.startFocusTime >
            1000) {
      late int startFocusTime;
      if (screenVisited.isCurrentScreenOverMaxDuration) {
        startFocusTime = screenVisited.maximumDurationForLastScreenshot;
      } else {
        startFocusTime = screenVisited.endTimestamp! - 500;
      }

      final ScreenshotMessage screenShotMessage = lastScreenshotSent!;
      lastScreenshotSent = null;
      await _sendScreenshot(
        screenShotMessage.screenshotData,
        screenShotMessage.screenId,
        screenShotMessage.screenName,
        startFocusTime,
        screenVisited,
      );
    }
  }

  Future<void> _sendOnePlaceholderImageForThisScreen({
    required ScreenVisited screenVisited,
  }) async {
    if (screenVisited.screenshotTakenList.isNotEmpty) return;
    final ByteData byteData = await _placeholderImageConfig.getPlaceholderImage(
      screenVisited.getCurrentContext!,
      PlaceholderType(placeholderTypeEnum: PlaceholderTypeEnum.replayDisabled),
    );
    final int startFocusTime = DateTime.now().millisecondsSinceEpoch;

    logger.v(
      '''
      _sendOnePlaceholderImageForThisScreen - 
      screenName: ${screenVisited.name} - 
      screenId: ${screenVisited.uniqueId}
      ''',
    );

    await _sendScreenshot(
      byteData.buffer.asUint8List(),
      screenVisited.uniqueId,
      screenVisited.name,
      startFocusTime,
      screenVisited,
    );
  }

  bool get isFrameTimeWindowSafe {
    bool safeZone = true;
    try {
      schedulerBindingInstance.currentFrameTimeStamp;
    } catch (e) {
      if (schedulerBindingInstance.hasScheduledFrame) {
        safeZone = false;
      }
    }
    return safeZone;
  }
}

@visibleForTesting
class ScreenshotTaker with TrackingCompleter {
  final AutoMasking autoMasking;
  final _maskColor = Paint()..color = Colors.grey;

  ScreenshotTaker({
    required this.autoMasking,
  });

  Future<ByteData?> captureImage({
    required ScreenVisited screenVisited,
    required VoidCallback uiChangedReset,
    required VoidCallback forceScreeshotNextFrame,
  }) async {
    final context = screenVisited.getCurrentContext;
    if (context == null) {
      return null;
    }
    final Size size = MediaQuery.of(context).size;
    final double width = size.width;
    final double height = size.height;
    final recorder = ui.PictureRecorder();

    final renderObject = context.findRenderObject();

    late Set<RectAndRotation> manualMaskCoordinates;
    if (renderObject != null) {
      final Rect frame = renderObject.globalPaintBounds;
      final Offset offset = Offset(frame.left, frame.top);

      late ui.Image image;
      if (screenVisited.enableAutomaticMasking) {
        autoMasking.setAutoMasking(context);
      }
      manualMaskCoordinates =
          _saveMaskPosition(screenVisited.listOfMasks, renderObject, offset);

      return endScreenTasksCompleterWrapper<ByteData?>(() async {
        try {
          uiChangedReset();

          image = await (renderObject as RenderRepaintBoundary).toImage();
        } catch (_) {
          forceScreeshotNextFrame();
          return null;
        }
        final canvas = Canvas(
          recorder,
        );
        canvas.drawImage(image, offset, Paint());
        _paintMaskWithCoordinates(canvas, manualMaskCoordinates);

        final resultImage = await recorder.endRecording().toImage(
              width.toInt(),
              height.toInt(),
            );
        final resultImageData =
            await resultImage.toByteData(format: ui.ImageByteFormat.png);

        return resultImageData;
      });
    }
    return null;
  }

  Set<RectAndRotation> _saveMaskPosition(
    List<GlobalKey> widgetsToMaskList,
    RenderObject ancestor,
    Offset offset,
  ) {
    final Set<RectAndRotation> coordinates = {};

    for (final globalKey in widgetsToMaskList) {
      final RenderObject? renderObject = globalKey.renderObject;
      //TODO: this is used for tabbars because they share masks references,
      //research how to avoid this
      if (renderObject == null) continue;
      coordinates.addAll(_getMaskCoordinates(renderObject, ancestor, offset));
    }
    autoMasking.renderObjectsToMask
        .removeWhere((element) => element.attached == false);
    for (final renderObject in autoMasking.renderObjectsToMask) {
      coordinates.addAll(_getMaskCoordinates(renderObject, ancestor, offset));
    }
    return coordinates;
  }

  Set<RectAndRotation> _getMaskCoordinates(
    RenderObject renderObject,
    RenderObject ancestor,
    Offset offset,
  ) {
    final Set<RectAndRotation> coordinates = {};
    renderObject.globalPaintBoundsWithAncestor(ancestor).let((it) {
      coordinates
          .add(RectAndRotation(it.rect.shift(offset), it.cosine, it.sine));
    });
    return coordinates;
  }

  void _paintMaskWithCoordinates(
      Canvas canvas, Set<RectAndRotation> coordinates) {
    for (final coordinate in coordinates) {
      final path = Path();
      final rect = coordinate.rect;
      final width = rect.right - rect.left;
      final height = rect.bottom - rect.top;

      final xcosine = width * coordinate.cosine;
      final xsine = width * coordinate.sine;
      final ysine = height * coordinate.sine;
      final ycosine = height * coordinate.cosine;

      //Point1
      path.moveTo(rect.left, rect.top);
      //Point2
      path.lineTo(rect.left + xcosine, rect.top + xsine);
      //Point3
      path.lineTo(
        rect.left + xcosine - ysine,
        rect.top + xsine + ycosine,
      );
      //Point4
      path.lineTo(rect.left - ysine, rect.top + ycosine);
      //
      path.close();
      canvas.drawPath(path, _maskColor);
    }
  }
}
