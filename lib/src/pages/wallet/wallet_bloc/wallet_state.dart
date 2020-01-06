import 'package:flutter/material.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

@immutable
abstract class WalletState {}

class ScanWalletLoadingState extends WalletState {}

class WalletEmptyState extends WalletState {}

class ShowWalletState extends WalletState {
  final WalletVo wallet;

  ShowWalletState(this.wallet);
}
