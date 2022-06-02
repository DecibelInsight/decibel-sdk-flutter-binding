import 'package:decibel_sdk/decibel_sdk.dart';
import 'package:decibel_sdk/features/session_replay.dart';
import 'package:decibel_sdk/features/tracking.dart';
import 'package:decibel_sdk/utility/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ScreenWidget extends StatefulWidget {
  const ScreenWidget({
    required this.child,
    required this.screenName,
    this.tabController,
    this.tabNames,
  });

  final Widget child;
  final String screenName;
  final TabController? tabController;
  final List<String>? tabNames;

  @override
  State<StatefulWidget> createState() => _ScreenWidgetState();
}

class _ScreenWidgetState extends State<ScreenWidget>
    with WidgetsBindingObserver {
  final GlobalKey _globalKey = GlobalKey();
  ModalRoute<Object?>? route;

  // Defining an internal function to be able to remove the listener
  void _animationListener(status) {
    SessionReplay.instance.isPageTransitioning =
        status != AnimationStatus.completed;
  }

  @override
  void initState() {
    super.initState();

    SessionReplay.instance.stop();
    SessionReplay.instance.widgetsToMaskList.clear();
    SessionReplay.instance.unableToTakeScreenshotCallback = () {};
    WidgetsBinding.instance!
      ..addObserver(this)
      ..addPostFrameCallback((_) async {
        route = ModalRoute.of(context);
        route?.animation?.addStatusListener(_animationListener);
      });
    widget.tabController?.addListener(() => DecibelSdk.tabControllerListener(
        widget.tabController!, widget.tabNames!));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        //debugPrint('AppLifecycleState resumed');
        break;
      case AppLifecycleState.paused:
        //debugPrint('AppLifecycleState paused');
        break;
      default:
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    route?.animation?.removeStatusListener(_animationListener);
    widget.tabController?.removeListener(() => DecibelSdk.tabControllerListener(
        widget.tabController!, widget.tabNames!));

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: UniqueKey(),
      onVisibilityChanged: (VisibilityInfo info) {
        if (info.visibleFraction != VisibilityConst.notVisible) {
          if (Tracking.instance.visitedScreensList.isEmpty ||
              widget.screenName !=
                  Tracking.instance.visitedScreensList.last.name) {
            SessionReplay.instance.start();
            SessionReplay.instance.captureKey = _globalKey;
            if (Tracking.instance.visitedScreensList.isNotEmpty) {
              Tracking.instance
                  .endScreen(Tracking.instance.visitedScreensList.last);
            }
            Tracking.instance.startScreen(widget.screenName);
          }
        }
      },
      child: RepaintBoundary(
        key: _globalKey,
        child: widget.child,
      ),
    );
  }
}
