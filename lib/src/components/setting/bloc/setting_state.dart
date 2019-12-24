import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../model.dart';

@immutable
abstract class SettingState extends Equatable {
  SettingState([List pros = const []]) : super(pros);
}

class InitialSettingState extends SettingState {}

class UpdateSettingState extends SettingState {
  final AreaModel areaModel;
  final LanguageModel languageModel;

  UpdateSettingState({
    this.languageModel,
    this.areaModel,
  }) : super([languageModel, areaModel]);
}
