import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../model.dart';

//store

@immutable
abstract class SettingState {
  const SettingState();
}

class InitialSettingState extends SettingState {}

class UpdatedSettingState extends SettingState with EquatableMixin {
  final LanguageModel languageModel;
  final AreaModel areaModel;

  UpdatedSettingState({this.languageModel, this.areaModel});

  @override
  List<Object> get props => [languageModel, areaModel];

  @override
  bool get stringify => true;
}
