import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'decibel_sdk.dart';

extension ElementExt on Element {
  List<Element> get children {
    List<Element> _children = <Element>[];
    visitChildElements((Element element) => _children.add(element));
    return _children;
  }
}

extension GlobalKeyExt on GlobalKey {
  Rect? get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    var translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null) {
      return renderObject!.paintBounds
          .shift(Offset(translation.x, translation.y));
    } else {
      return null;
    }
  }
}

extension ListDecibelCustomerConsentTypeExt on List<DecibelCustomerConsentType> {
  List<int> toIndexList() {
    return this.map((consent) => consent.index).toList();
  }
}

extension ObjectExt<T> on T {
  R let<R>(R Function(T it) op) => op(this);
}