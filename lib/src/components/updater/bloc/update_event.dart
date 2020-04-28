import 'package:meta/meta.dart';

@immutable
abstract class UpdateEvent {}

class CheckUpdate extends UpdateEvent {
  final String lang;
  final bool isManual;

  CheckUpdate({this.lang, this.isManual = false});
}
