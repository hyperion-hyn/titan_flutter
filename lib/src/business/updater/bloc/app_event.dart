import 'package:meta/meta.dart';

@immutable
abstract class AppEvent {}

class CheckUpdate extends AppEvent {
  final String lang;

  CheckUpdate({this.lang});
}
