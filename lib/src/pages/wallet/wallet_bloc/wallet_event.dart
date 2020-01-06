import 'package:flutter/material.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

@immutable
abstract class WalletEvent {}

class ScanWalletEvent extends WalletEvent {}

class UpdateWalletEvent extends WalletEvent {
  final WalletVo walletVo;

  UpdateWalletEvent(this.walletVo);
}
