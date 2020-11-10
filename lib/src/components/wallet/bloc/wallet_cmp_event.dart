import 'package:equatable/equatable.dart';
import 'package:titan/src/components/wallet/model.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

abstract class WalletCmpEvent {
  const WalletCmpEvent();
}

class ActiveWalletEvent extends WalletCmpEvent {
  final Wallet wallet;

  ActiveWalletEvent({this.wallet});
}

class LoadLocalDiskWalletAndActiveEvent extends WalletCmpEvent {}

class UpdateActivatedWalletBalanceEvent extends WalletCmpEvent {
  ///only update the symbol balance? or null for all coin balance.
  final String symbol;
  final String contractAddress;

  UpdateActivatedWalletBalanceEvent({this.symbol, this.contractAddress});
}

class UpdateWalletPageEvent extends WalletCmpEvent {}

class UpdateQuotesEvent extends WalletCmpEvent {
  final bool isForceUpdate;

  UpdateQuotesEvent({this.isForceUpdate});
}

class UpdateQuotesSignEvent extends WalletCmpEvent {
  final QuotesSign sign;

  UpdateQuotesSignEvent({this.sign});
}

class UpdateGasPriceEvent extends WalletCmpEvent {}