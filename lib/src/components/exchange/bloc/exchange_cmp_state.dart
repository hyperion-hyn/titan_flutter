import 'package:meta/meta.dart';
import 'package:titan/src/pages/market/model/exchange_account.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

@immutable
abstract class ExchangeCmpState {}

class InitialExchangeCmpState extends ExchangeCmpState {}

class CheckAccountState extends ExchangeCmpState{}


class LoginState extends ExchangeCmpState {
  final Wallet wallet;
  final String password;
  final String address;

  LoginState(this.wallet, this.password, this.address);
}

class LoginSuccessState extends ExchangeCmpState {}

class LoginFailState extends ExchangeCmpState {}

class SetShowBalancesState extends ExchangeCmpState {
  final bool isShow;

  SetShowBalancesState(this.isShow);
}

class UpdateExchangeAccountState extends ExchangeCmpState {
  final ExchangeAccount account;

  UpdateExchangeAccountState(this.account);
}

class ClearExchangeAccountState extends ExchangeCmpState {}

class UpdateAssetsState extends ExchangeCmpState {}
