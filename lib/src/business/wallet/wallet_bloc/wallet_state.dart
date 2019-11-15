import 'package:flutter/material.dart';
import 'package:titan/src/business/wallet/model/wallet_vo.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

@immutable
abstract class WalletState {}

class ScanWalletLoadingState extends WalletState {}

class WalletEmptyState extends WalletState {}

class ShowWalletState extends WalletState {
  WalletVo wallet;

  ShowWalletState(this.wallet);
}
