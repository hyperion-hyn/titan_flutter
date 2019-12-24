import 'package:meta/meta.dart';

@immutable
abstract class SettingEvent {}

class UpdateLocalEvent extends SettingEvent {}

class UpdateAreaEvent extends SettingEvent {}