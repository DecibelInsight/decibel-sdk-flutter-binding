import 'package:decibel_sdk/decibel_sdk.dart';
import 'package:decibel_sdk/features/session_replay.dart';
import 'package:flutter/widgets.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ScreenWidget extends StatefulWidget {
  ScreenWidget({required this.child, required this.screenName});

  final Widget child;
  final String screenName;

  @override
  State<StatefulWidget> createState() => _ScreenWidgetState();
}

class _ScreenWidgetState extends State<ScreenWidget> {
  GlobalKey _globalKey = GlobalKey();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    SessionReplay.instance.widgetsToMaskList.clear();
  }

  @override
  Widget build(BuildContext context) {
    var route = ModalRoute.of(context);

    // Defining an internal function to be able to remove the listener
    void handler(status) {
      if (status == AnimationStatus.completed) {
        DecibelSdk.isPageTransitioning = false;
        route?.animation?.removeStatusListener(handler);
      } else {
        DecibelSdk.isPageTransitioning = true;
      }
    }
    route?.animation?.addStatusListener(handler);

    return VisibilityDetector(
      key: UniqueKey(),
      onVisibilityChanged: (VisibilityInfo info) {
        if (info.visibleFraction == 0.0) {
          SessionReplay.instance.widgetsToMaskList.clear();
        } else {
          DecibelSdk.captureKey = _globalKey;
          DecibelSdk.setScreen(widget.screenName);
        }
      },
      child: RepaintBoundary(
        key: _globalKey,
        child: widget.child,
      ),
    );
  }
}
