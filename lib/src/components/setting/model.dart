import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/style/theme.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/pages/mine/me_theme_page.dart';

part 'model.g.dart';

@JsonSerializable()
class AreaModel extends Equatable {
  final String id;

//  final String name;

  AreaModel({this.id /*, this.name*/
      });

  @override
  List<Object> get props => [
        id /*, name*/
      ];

  Map<String, Object> toJson() => _$AreaModelToJson(this);

  factory AreaModel.fromJson(Map<String, Object> json) => _$AreaModelFromJson(json);

  bool get isChinaMainland {
    return id == 'mainland_china_area';
  }

  String name(BuildContext context) {
    switch (id) {
      case 'mainland_china_area':
        return S.of(context).mainland_china;
      case 'other_area':
        return S.of(context).other_area;
      default:
        return 'unknown area';
    }
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

class LanguageModel extends Equatable {
  final Locale locale;
  final String name;

  LanguageModel({this.name, this.locale});

  @override
  List<Object> get props => [locale, name];

  Map<String, Object> toJson() {
    return <String, dynamic>{
      'name': name,
      'local': {'languageCode': (locale?.languageCode ?? 'zh'), 'countryCode': locale?.countryCode}
    };
  }

  bool isKo() {
    return (locale?.languageCode ?? 'zh') == 'ko';
  }

  bool isZh() {
    return (locale?.languageCode ?? 'zh') == 'zh';
  }

  String getLocaleName() {
    if (isZh()) {
      return "${(locale?.languageCode ?? 'zh')}_${locale.countryCode}";
    } else {
      return "${(locale?.languageCode ?? 'zh')}";
    }
  }

  factory LanguageModel.fromJson(Map<String, Object> json) {
    var localMap = json['local'] as Map;
    return LanguageModel(
      name: json['name'] as String,
      locale: Locale(localMap['languageCode'], localMap['countryCode']),
    );
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

class SupportedArea {
  static AreaModel defaultModel(/*BuildContext context*/) =>
      AreaModel(id: 'mainland_china_area' /*, name: S.of(context).mainland_china*/);

  static List<AreaModel> all(/*BuildContext context*/) {
    return [
      AreaModel(id: 'mainland_china_area' /*, name: S.of(context).mainland_china*/),
      AreaModel(id: 'other_area' /*, name: S.of(context).other_area*/)
    ];
  }
}

class SupportedLanguage {
  static LanguageModel defaultModel(BuildContext context) {
    var systemLocale = Localizations.localeOf(context);
    var allLocales = all;
    for (var locale in allLocales) {
      if (locale.locale.languageCode == systemLocale.languageCode) {
        return locale;
      }
    }
    return LanguageModel(name: 'English', locale: Locale('en'));
  }

  static List<LanguageModel> all = [
    LanguageModel(name: '简体中文', locale: Locale("zh", "CN")),
    LanguageModel(name: '繁體中文', locale: Locale("zh", "HK")),
    LanguageModel(name: 'English', locale: Locale('en')),
    LanguageModel(name: '한국어', locale: Locale("ko")),
  ];
}

class SupportedTheme {
  static List<ThemeModel> all = themeList;

  // static Color get textColor => Theme.of(Keys.rootKey.currentContext).textTheme.apply().bodyText1.color;
  static Color get textColorBlack => Color(0xff333333);
  static Color get textColorWhite => Color(0xffffffff);

  static List<Color> defaultBtnColors(BuildContext context) {
    return SettingInheritedModel.of(context, aspect: SettingAspect.theme).themeModel?.btnColors ??
        <Color>[
          Color(0xfff7d33d),
          Color(0xffedc313),
        ];
  }

  static Future<ThemeModel> defaultModel() async {
    var name = await AppCache.getValue(PrefsKey.SETTING_SYSTEM_THEME);
    if (name != null) {
      var jsonName = json.decode(name);
      for (var item in themeList) {
        if (item.name == jsonName) {
          return item;
        }
      }
    } else {
      return themeList[0];
    }
    return themeList[0];
  }

  static List<ThemeModel> get themeList {
    List<ThemeModel> themes = [];
    var themeName = S.of(Keys.rootKey.currentContext).theme_default;
    ThemeData themeData;
    Color color;
    List<Color> btnColors;
    for (int i = 0; i < 4; i++) {
      switch (i) {
        case 0:
          themeName = S.of(Keys.rootKey.currentContext).theme_default;
          themeData = appThemeDeepYellow;
          color = Colors.yellow;
          btnColors = <Color>[
            Color(0xfff7d33d),
            Color(0xffedc313),
          ];
          break;

        case 1:
          themeName = S.of(Keys.rootKey.currentContext).theme_dark_blue;
          themeData = appThemeDeepBlue;
          color = Color(0xff1097B4);
          btnColors = <Color>[Color(0xff15B2D2), Color(0xff1097B4)];
          break;

        case 2:
          themeName = S.of(Keys.rootKey.currentContext).theme_dark_red;
          themeData = appThemeDeepRed;
          color = Color(0xffcc5858);
          btnColors = <Color>[Color(0xffEB8686), Color(0xffcc5858)];
          break;

        case 3:
          themeName = S.of(Keys.rootKey.currentContext).theme_blue;
          themeData = appThemeDefault;
          color = Colors.blue;
          btnColors = <Color>[Color(0xff96CBFF), Color(0xff3B8BFF)];
          break;
      }
      var model = ThemeModel(
        name: themeName,
        color: color,
        theme: themeData,
        btnColors: btnColors,
      );
      themes.add(model);
    }
    return themes;
  }
}
