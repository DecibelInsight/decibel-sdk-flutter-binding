import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../decibel_sdk.dart';
import '../messages.dart';

class SessionReplay {
  final oldWidgets = List.empty(growable: true);
  final newWidgets = List.empty(growable: true);

  bool _didUiChange() {
    bool didUiChange = false;
    void findChildren(List<Element> list) {
      list.forEach((element) {
        newWidgets.add(element.widget);
        findChildren(element.children);
      });
    }
    findChildren(WidgetsBinding.instance!.renderViewElement!.children);
    didUiChange = !listEquals(oldWidgets, newWidgets);
    oldWidgets.clear();
    oldWidgets.addAll(newWidgets);
    newWidgets.clear();
    return didUiChange;
  }

  void checkUiChanges(DecibelSdkApi _api) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      print("++++++++++++++++POSTFRAME++++++++++++++++++++++++");
      Timer.periodic(Duration(milliseconds: 500), (timer) async {
        if (_didUiChange()) {
          // Triggers screenshot in native iOS
          await _api.uiChanged();
          print("uiChanged()");
        }
      });
    });
  }
}

extension _ElementExt on Element {
  List<Element> get children {
    List<Element> _children = <Element>[];
    visitChildElements((Element element) => _children.add(element));
    return _children;
  }
}
