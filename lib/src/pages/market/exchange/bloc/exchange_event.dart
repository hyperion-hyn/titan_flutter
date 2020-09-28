import 'package:meta/meta.dart';

@immutable
abstract class ExchangeEvent {}

class SwitchToAuthEvent extends ExchangeEvent {}

class SwitchToContentEvent extends ExchangeEvent {}
