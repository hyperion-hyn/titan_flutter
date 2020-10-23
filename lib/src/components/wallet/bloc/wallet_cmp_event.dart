import 'package:equatable/equatable.dart';
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
