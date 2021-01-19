import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:titan/src/components/wallet/model.dart';
import 'package:titan/src/components/setting/model.dart';
import 'package:titan/src/pages/mine/me_theme_page.dart';

@immutable
abstract class SettingEvent {}

class UpdateSettingEvent extends SettingEvent with EquatableMixin {
  final LanguageModel languageModel;
  final AreaModel areaModel;
  final ThemeModel themeModel;

  UpdateSettingEvent({this.languageModel, this.areaModel, this.themeModel,});

  @override
  List<Object> get props => [languageModel, areaModel, themeModel];

  @override
  bool get stringify => true;
}

class SystemConfigEvent extends SettingEvent{
  SystemConfigEvent();
}