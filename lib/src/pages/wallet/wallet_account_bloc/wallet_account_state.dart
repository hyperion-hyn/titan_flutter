import 'package:flutter/material.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

@immutable
abstract class WalletAccountState {}

class WalletEmptyState extends WalletAccountState {}

class ShowWalletState extends WalletAccountState {
  Wallet wallet;
  ShowWalletState(this.wallet);
}
