import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

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
  final SystemConfigEntity systemConfig;

  UpdatedSettingState({
    this.languageModel,
    this.areaModel,
    this.systemConfig,
  });

  @override
  List<Object> get props => [languageModel, areaModel, systemConfig];

  @override
  bool get stringify => true;
}

// class RemoteConfigSyncedState extends SettingState {
//   final SystemConfigEntity systemConfigEntity;
//
//   RemoteConfigSyncedState(this.systemConfigEntity);
// }
