import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:titan/src/components/setting/system_config_entity.dart';
import 'package:titan/src/components/wallet/model.dart';
import 'package:titan/src/components/setting/model.dart';
import 'package:titan/src/pages/mine/me_theme_page.dart';

@immutable
abstract class SettingEvent {}

class UpdateSettingEvent extends SettingEvent with EquatableMixin {
  final LanguageModel languageModel;
  final AreaModel areaModel;

  final ThemeModel themeModel;

  final SystemConfigEntity systemConfig;

  UpdateSettingEvent({
    this.languageModel,
    this.areaModel,
    this.themeModel,
    this.systemConfig,
  });

  @override
  List<Object> get props => [languageModel, areaModel, this.themeModel, systemConfig];

  @override
  bool get stringify => true;
}

class RestoreSettingEvent extends SettingEvent {}

class SyncRemoteConfigEvent extends SettingEvent {}

class SystemConfigEvent extends SettingEvent {}

