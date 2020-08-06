import 'package:meta/meta.dart';
import 'package:titan/src/pages/market/model/exchange_account.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

@immutable
abstract class ExchangeCmpEvent {}

class SetShowBalancesEvent extends ExchangeCmpEvent {
  final bool isShow;

  SetShowBalancesEvent(this.isShow);
}

class LoginEvent extends ExchangeCmpEvent {
  final Wallet wallet;
  final String password;
  final String address;

  LoginEvent(this.wallet, this.password, this.address);
}

class LoginSuccessEvent extends ExchangeCmpEvent{}

class LoginFailEvent extends ExchangeCmpEvent{

}

class UpdateExchangeAccountEvent extends ExchangeCmpEvent {
  final ExchangeAccount account;

  UpdateExchangeAccountEvent(this.account);
}

class ClearExchangeAccountEvent extends ExchangeCmpEvent {}

class UpdateAssetsEvent extends ExchangeCmpEvent {}
