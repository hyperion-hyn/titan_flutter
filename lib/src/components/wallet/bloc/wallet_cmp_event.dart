import 'package:flutter/widgets.dart';
import 'package:titan/src/components/wallet/model.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

abstract class WalletCmpEvent {
  const WalletCmpEvent();
}

/// 激活指定钱包
class ActiveWalletEvent extends WalletCmpEvent {
  final Wallet wallet;
  final bool onlyActive;

  ActiveWalletEvent({this.wallet, this.onlyActive});
}

/// 加载本地钱包并激活
class LoadLocalDiskWalletAndActiveEvent extends WalletCmpEvent {}

/// 更新当前钱包的余额
class UpdateActivatedWalletBalanceEvent extends WalletCmpEvent {
  final Status status;

  ///only update the symbol balance? or null for all coin balance.
  final String symbol;

  // final String contractAddress;

  UpdateActivatedWalletBalanceEvent({this.status, this.symbol});
}

// class UpdateWalletPageEvent extends WalletCmpEvent {
//   final bool updateGasPrice;
//
//   UpdateWalletPageEvent({this.updateGasPrice = false});
// }

/// 更新法币行情
class UpdateQuotesEvent extends WalletCmpEvent {
  final Status status;
  final bool isForceUpdate;

  UpdateQuotesEvent({this.status, this.isForceUpdate});
}

/// 更新当前法币计价
class UpdateLegalSignEvent extends WalletCmpEvent {
  final LegalSign legal;

  UpdateLegalSignEvent({@required this.legal});
}

/// 更新矿工费
class UpdateGasPriceEvent extends WalletCmpEvent {
  final Status status;
  final GasPriceType type;

  UpdateGasPriceEvent({this.status, this.type});
}

enum GasPriceType { ETH, BTC }
