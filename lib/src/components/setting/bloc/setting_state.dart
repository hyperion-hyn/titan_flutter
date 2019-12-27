import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../model.dart';

//store

@immutable
abstract class SettingState extends Equatable {
  const SettingState();
}

class InitialSettingState extends SettingState {
  @override
  List<Object> get props => [];
}

class UpdateSettingState extends SettingState {
  final AreaModel areaModel;
  final LanguageModel languageModel;

  UpdateSettingState({
    this.languageModel,
    this.areaModel,
  });

  @override
  List<Object> get props => [areaModel, areaModel];
}
