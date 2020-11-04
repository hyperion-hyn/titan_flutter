import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:titan/src/components/wallet/model.dart';
import 'package:titan/src/components/setting/model.dart';

@immutable
abstract class SettingEvent {}

class UpdateSettingEvent extends SettingEvent with EquatableMixin {
  final LanguageModel languageModel;
  final AreaModel areaModel;
  final QuotesSign quotesSign;

  UpdateSettingEvent({this.languageModel, this.areaModel, this.quotesSign});

  @override
  List<Object> get props => [languageModel, areaModel];

  @override
  bool get stringify => true;
}

class SystemConfigEvent extends SettingEvent{
  SystemConfigEvent();
}