import 'package:meta/meta.dart';

@immutable
abstract class AppEvent {}

class CheckUpdate extends AppEvent {
  final String lang;
  final bool isManual;

  CheckUpdate({this.lang, this.isManual = false});
}
