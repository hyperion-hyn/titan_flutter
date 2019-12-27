import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/i18n.dart';

class AreaModel extends Equatable {
  final String id;
  final String name;

  AreaModel({this.id, this.name});

  @override
  List<Object> get props => [id, name];
}

class LanguageModel extends Equatable {
  final Locale locale;
  final String name;

  LanguageModel({this.name, this.locale});

  @override
  List<Object> get props => [locale, name];
}

class SupportedArea {
  static List<AreaModel> all(BuildContext context) {
    return [
      AreaModel(id: 'mainland_china_area', name: S.of(context).mainland_china),
      AreaModel(id: 'other_area', name: S.of(context).other_area)
    ];
  }
}

class SupportedLanguage {
  static List<LanguageModel> all() {
    return [
      LanguageModel(name: '简体中文', locale: Locale("zh", "CN")),
      LanguageModel(name: 'English', locale: Locale('en')),
      LanguageModel(name: '한국어', locale: Locale("ko")),
    ];
  }
}
