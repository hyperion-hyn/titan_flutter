import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:titan/src/components/quotes/model.dart';

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
  final QuotesSign quotesSign;

  UpdatedSettingState({this.languageModel, this.areaModel, this.quotesSign});

  @override
  List<Object> get props => [languageModel, areaModel, quotesSign];

  @override
  bool get stringify => true;
}
