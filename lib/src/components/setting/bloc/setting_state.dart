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

class UpdateLanguageState extends SettingState {
  final LanguageModel languageModel;

  UpdateLanguageState({this.languageModel});

  @override
  List<Object> get props => [languageModel];
}

class UpdateAreaState extends SettingState {
  final AreaModel areaModel;

  UpdateAreaState({this.areaModel});

  @override
  List<Object> get props => [areaModel];
}
