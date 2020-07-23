import 'package:meta/meta.dart';
import 'package:titan/src/pages/market/model/exchange_account.dart';

@immutable
abstract class ExchangeCmpEvent {}

class SetShowBalancesEvent extends ExchangeCmpEvent {
  final bool isShow;

  SetShowBalancesEvent(this.isShow);
}

class UpdateExchangeAccountEvent extends ExchangeCmpEvent {
  final ExchangeAccount account;

  UpdateExchangeAccountEvent(this.account);
}

class ClearExchangeAccountEvent extends ExchangeCmpEvent {}

class UpdateAssetsEvent extends ExchangeCmpEvent {}
