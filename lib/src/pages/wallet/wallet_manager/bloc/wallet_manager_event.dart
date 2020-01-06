import 'package:flutter/material.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

@immutable
abstract class WalletManagerEvent {}

class ScanWalletEvent extends WalletManagerEvent {}

class SwitchWalletEvent extends WalletManagerEvent {
  final Wallet wallet;

  SwitchWalletEvent(this.wallet);
}
