import 'package:decibel_sdk/src/features/autoMasking/auto_masking_enums.dart';
import 'package:decibel_sdk/src/features/autoMasking/auto_masking_widgets.dart';
import 'package:decibel_sdk/src/utility/logger_sdk.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class AutoMasking with RenderObjectAutoMaskGetter {
  AutoMasking() : _logger = LoggerSDK.instance;
  final LoggerSDK _logger;
  Logger get logger => _logger.autoMaskingLogger;
  final Set<RenderObject> renderObjectsToMask = Set.of({});
  //Webbview and input text masking by default
  static final Set<AutoMaskingType> _defaultAutoMaskingTypeSet = {
    const AutoMaskingType(autoMaskingTypeEnum: AutoMaskingTypeEnum.webView),
    const AutoMaskingType(autoMaskingTypeEnum: AutoMaskingTypeEnum.inputText)
  };
  Set<AutoMaskingType> _autoMaskingTypeSet = Set.from(
    _defaultAutoMaskingTypeSet,
  );
  Set<AutoMaskingType> get autoMaskingTypeSet => _autoMaskingTypeSet;
  set autoMaskingTypeSet(Set<AutoMaskingType> value) {
    if (value.contains(
      const AutoMaskingType(autoMaskingTypeEnum: AutoMaskingTypeEnum.all),
    )) {
      if (value.length > 1) {
        throw ArgumentError('''
AutoMaskingType.all cannot be selected
along with other AutoMaskingType enums
''');
      }
      final Set<AutoMaskingType> allEnumsSet =
          (value.first.getAutoMaskingType as AllAutomaskWidgets).getAllTypes();
      _autoMaskingTypeSet = allEnumsSet;
      return;
    }

    if (value.contains(
      const AutoMaskingType(autoMaskingTypeEnum: AutoMaskingTypeEnum.none),
    )) {
      if (value.length > 1) {
        throw ArgumentError('''
AutoMaskingType.none cannot be selected
along with other AutoMaskingType enums
''');
      }
      _autoMaskingTypeSet = {
        const AutoMaskingType(autoMaskingTypeEnum: AutoMaskingTypeEnum.none)
      };
      return;
    }
    _autoMaskingTypeSet.addAll(value);
    logger.d('After setAutoMaskingTypeSet ${autoMaskingTypeSet.toString()}');
  }

  void removeUnmaskedTypesFromAutoMaskingTypeSet(Set<AutoMaskingType> set) {
    if (set.contains(
      const AutoMaskingType(autoMaskingTypeEnum: AutoMaskingTypeEnum.none),
    )) {
      return;
    }
    if (set.contains(
      const AutoMaskingType(autoMaskingTypeEnum: AutoMaskingTypeEnum.all),
    )) {
      _autoMaskingTypeSet = {};
      return;
    }

    _autoMaskingTypeSet.removeAll(set);
    logger.d('After  Unmasking ${autoMaskingTypeSet.toString()}');
  }

  void setAutoMasking(BuildContext context) {
    logger.d('set AutoMasking ${autoMaskingTypeSet.toString()}');
    if (autoMaskingTypeSet.contains(
      const AutoMaskingType(autoMaskingTypeEnum: AutoMaskingTypeEnum.none),
    )) {
      return;
    }
    renderObjectsToMask
        .addAll(getRenderObjectsByAutoMaskingType(context, autoMaskingTypeSet));
    logger.d('renderObjectsToMask ${renderObjectsToMask.toString()}');
  }

  void clear() {
    logger.d('renderObjectsToMask clear');
    renderObjectsToMask.clear();
  }
}

mixin RenderObjectAutoMaskGetter {
  Set<RenderObject> getRenderObjectsByAutoMaskingType(
      BuildContext context, Set<AutoMaskingType> widgetTypes) {
    final Set<RenderObject> renderObjectList = Set.of({});

    void findChild(Element parentElement) {
      parentElement.visitChildElements((element) {
        //check if the element has a widget of the same type we
        //want to mask
        final bool typeCheck = widgetTypes.any((type) {
          if (type.getAutoMaskingType.widgets
              .contains(element.widget.runtimeType)) {
            return true;
          }
          //check if the widget that matches a subtype
          //of a family of widgets we want to mask. e.g. a custom
          //button
          return type.getAutoMaskingType.isSubtype(element.widget);
        });
        if (typeCheck) {
          if (element.renderObject != null) {
            renderObjectList.add(element.renderObject!);
          }
          return;
        } else {
          findChild(element);
        }
      });
    }

    findChild(context as Element);
    return renderObjectList;
  }
}
