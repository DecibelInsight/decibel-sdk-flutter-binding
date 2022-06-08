import 'package:decibel_sdk/features/session_replay.dart';
import 'package:decibel_sdk/utility/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:visibility_detector/visibility_detector.dart';

class MaskWidget extends StatefulWidget {
  const MaskWidget({required this.child});

  final Widget child;

  @override
  State<StatefulWidget> createState() => _MaskWidgetState();
}

class _MaskWidgetState extends State<MaskWidget> {
  late GlobalKey globalKey;
  late UniqueKey uniqueKey;

  @override
  void initState() {
    globalKey = GlobalKey();
    uniqueKey = UniqueKey();
    addMask(globalKey);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    removeMask(globalKey);
  }

  void addMask(GlobalKey globalKey) {
    if (!SessionReplay.instance.widgetsToMaskList.contains(globalKey)) {
      SessionReplay.instance.widgetsToMaskList.add(globalKey);
    }
  }

  void removeMask(GlobalKey globalKey) {
    if (SessionReplay.instance.widgetsToMaskList.contains(globalKey)) {
      SessionReplay.instance.widgetsToMaskList.remove(globalKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: globalKey,
      child: VisibilityDetector(
        key: uniqueKey,
        onVisibilityChanged: (VisibilityInfo info) {
          if (info.visibleFraction == VisibilityConst.notVisible) {
            removeMask(globalKey);
          } else {
            addMask(globalKey);
          }
        },
        child: widget.child,
      ),
    );
  }
}
