import 'package:decibel_sdk/decibel_sdk.dart';
import 'package:decibel_sdk/features/session_replay.dart';
import 'package:decibel_sdk/utility/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ScreenWidget extends StatefulWidget {
  ScreenWidget({required this.child, required this.screenName});

  final Widget child;
  final String screenName;

  @override
  State<StatefulWidget> createState() => _ScreenWidgetState();
}

class _ScreenWidgetState extends State<ScreenWidget> with WidgetsBindingObserver {
  final GlobalKey _globalKey = GlobalKey();
  ModalRoute<Object?>? route;

  // Defining an internal function to be able to remove the listener
  void animationListener(status) {
    if (status == AnimationStatus.completed) {
      DecibelSdk.isPageTransitioning = false;
    } else {
      DecibelSdk.isPageTransitioning = true;
    }
  }
  
  @override
  void initState() {
    super.initState();
    SessionReplay.instance.widgetsToMaskList.clear();
    WidgetsBinding.instance!
      ..addObserver(this)
      ..addPostFrameCallback((_) async {
        route = ModalRoute.of(context);
        route?.animation?.addStatusListener(animationListener);
      });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch(state) {
      case AppLifecycleState.resumed:
        print('AppLifecycleState resumed');
        break;
      case AppLifecycleState.paused:
        print('AppLifecycleState paused');
        break;
      default:
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    route?.animation?.removeStatusListener(animationListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: UniqueKey(),
      onVisibilityChanged: (VisibilityInfo info) {
        if (info.visibleFraction == VisibilityConst.notVisible) {
          // SessionReplay.instance.widgetsToMaskList.clear();
          // print('${widget.screenName} NOT visible');
        } else {
          if(widget.screenName != DecibelSdk.lastVisitedScreen){
            print('${widget.screenName} visible');
            DecibelSdk.captureKey = _globalKey;
            DecibelSdk.setScreen(widget.screenName);
            DecibelSdk.lastVisitedScreen = widget.screenName;
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
