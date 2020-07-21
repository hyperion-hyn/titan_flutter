import 'package:meta/meta.dart';
import 'package:titan/src/pages/market/model/exchange_account.dart';

@immutable
abstract class ExchangeCmpState {}

class InitialExchangeCmpState extends ExchangeCmpState {}

class SetShowBalancesState extends ExchangeCmpState {
  final bool isShow;

  SetShowBalancesState(this.isShow);
}

class UpdateExchangeAccountState extends ExchangeCmpState {
  final ExchangeAccount account;

  UpdateExchangeAccountState(this.account);
}

class UpdateAssetsState extends ExchangeCmpState {}
