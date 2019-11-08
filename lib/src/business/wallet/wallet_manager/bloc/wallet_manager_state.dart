import 'package:flutter/material.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

@immutable
abstract class WalletManagerState {}

class WalletEmptyState extends WalletManagerState {}

class ShowWalletState extends WalletManagerState {
  List<Wallet> wallets;

  ShowWalletState(this.wallets);
}
