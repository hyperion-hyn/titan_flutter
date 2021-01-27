import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:titan/src/components/wallet/model.dart';
import 'package:titan/src/pages/mine/me_theme_page.dart';

import '../model.dart';
import '../system_config_entity.dart';

//store

@immutable
abstract class SettingState {
  const SettingState();
}

class InitialSettingState extends SettingState {}

class UpdatedSettingState extends SettingState with EquatableMixin {
  final LanguageModel languageModel;
  final AreaModel areaModel;
  final QuotesSign quotesSign;
  final ThemeModel themeModel;
  final SystemConfigEntity systemConfig;

  UpdatedSettingState({
    this.languageModel,
    this.areaModel,
    this.quotesSign,
    this.themeModel,
    this.systemConfig,
  });

  @override
  List<Object> get props => [languageModel, areaModel, themeModel, systemConfig];

  @override
  bool get stringify => true;
}

// class RemoteConfigSyncedState extends SettingState {
//   final SystemConfigEntity systemConfigEntity;
//
//   RemoteConfigSyncedState(this.systemConfigEntity);
// }
