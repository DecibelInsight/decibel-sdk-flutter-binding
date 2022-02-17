import 'package:decibel_sdk/utility/enums.dart';
import 'package:flutter/widgets.dart';

extension ElementExt on Element {
  List<Element> get children {
    final List<Element> _children = <Element>[];
    visitChildElements((Element element) => _children.add(element));
    return _children;
  }
}

extension GlobalKeyExt on GlobalKey {
  Rect? get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    final translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null) {
      return renderObject!.paintBounds
          .shift(Offset(translation.x, translation.y));
    } else {
      return null;
    }
  }
}

extension ListDecibelCustomerConsentTypeExt
    on List<DecibelCustomerConsentType> {
  List<int> toIndexList() {
    return map((consent) => consent.index).toList();
  }
}

extension ObjectExt<T> on T {
  R let<R>(R Function(T it) op) => op(this);
}
