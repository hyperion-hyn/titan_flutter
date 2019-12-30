import 'package:meta/meta.dart';
import 'package:titan/src/components/setting/model.dart';

@immutable
abstract class SettingEvent {}

class UpdateLanguageEvent extends SettingEvent {
  final LanguageModel languageModel;

  UpdateLanguageEvent({this.languageModel});

  @override
  String toString() {
    return 'UpdateLanguageEvent: $languageModel';
  }
}

class UpdateAreaEvent extends SettingEvent {
  final AreaModel areaModel;

  UpdateAreaEvent({this.areaModel});

  @override
  String toString() {
    return 'UpdateAreaEvent: $areaModel';
  }
}
