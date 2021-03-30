import 'package:flutter/widgets.dart';
import 'package:titan/src/components/wallet/model.dart';
import 'package:titan/src/components/wallet/vo/coin_view_vo.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_expand_info_entity.dart';

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

/// 关闭部分合约币显示
class TurnOffTokensEvent extends WalletCmpEvent {
  final List<CoinViewVo> vos;

  TurnOffTokensEvent({@required this.vos});
}

/// 开启部分合约币显示
class TurnOnTokensEvent extends WalletCmpEvent {
  final List<CoinViewVo> vos;

  TurnOnTokensEvent({@required this.vos});
}

class UpdateWalletExpandEvent extends WalletCmpEvent {
  final String address;
  final WalletExpandInfoEntity walletExpandInfoEntity;

  UpdateWalletExpandEvent(this.address, this.walletExpandInfoEntity);
}

class UpdateCrossChainTokenListEvent extends WalletCmpEvent {}

enum GasPriceType { ETH, BTC }
