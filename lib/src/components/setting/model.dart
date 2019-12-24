import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:titan/generated/i18n.dart';

class AreaModel {
  final String id;
  final String name;

  AreaModel({this.id, this.name});
}

class SupportedArea {
  static AreaModel _chinaMainLand(BuildContext context) => AreaModel(
        id: 'mainland_china_area',
        name: S.of(context).mainland_china,
      );

  static AreaModel _otherArea(BuildContext context) => AreaModel(
        id: 'other_area',
        name: S.of(context).other_area,
      );

  static List<AreaModel> all(BuildContext context) {
    return [_chinaMainLand(context), _otherArea(context)];
  }
}

class LanguageModel {
  final Locale locale;

  LanguageModel({this.locale});
}
