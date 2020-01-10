import 'package:equatable/equatable.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

abstract class WalletCmpEvent extends Equatable {
  const WalletCmpEvent();

  @override
  List<Object> get props => null;
}

class ActiveWalletEvent extends WalletCmpEvent {
  final Wallet wallet;

  ActiveWalletEvent({this.wallet});

  @override
  List<Object> get props => [wallet];
}

class LoadLocalDiskWalletAndActiveEvent extends WalletCmpEvent {}

class UpdateActivatedWalletBalanceEvent extends WalletCmpEvent {
  ///only update the symbol balance? or null for all coin balance.
  final String symbol;

  UpdateActivatedWalletBalanceEvent({this.symbol});
}
