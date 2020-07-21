import 'package:meta/meta.dart';

@immutable
abstract class ExchangeState {}

class InitialExchangeState extends ExchangeState {}

class SwitchToAuthState extends ExchangeState {}

class SwitchToContentState extends ExchangeState {}
