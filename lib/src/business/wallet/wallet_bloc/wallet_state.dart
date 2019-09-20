import 'package:flutter/material.dart';
import 'package:titan/src/business/wallet/model_vo.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

@immutable
abstract class WalletState {}

class WalletEmptyState extends WalletState {}

class ShowWalletState extends WalletState {
  WalletVo wallet;
  ShowWalletState(this.wallet);
}
