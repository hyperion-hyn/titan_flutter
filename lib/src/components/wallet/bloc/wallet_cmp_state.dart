import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/model.dart';
import 'package:titan/src/components/wallet/vo/wallet_view_vo.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/bridge/entity/cross_chain_token.dart';
import 'package:titan/src/plugins/wallet/wallet_expand_info_entity.dart';

abstract class WalletCmpState {
  const WalletCmpState();
}

// abstract class WalletVoAwareCmpState extends WalletCmpState {
//   final WalletViewVo walletVo;
//
//   WalletVoAwareCmpState({this.walletVo});
//
//   List<Object> get props => [walletVo];
// }

class InitialWalletCmpState extends WalletCmpState {}

// class LoadingWalletState extends WalletCmpState {}
// class LoadWalletFailState extends WalletCmpState {}

class ActivatedWalletState extends WalletCmpState {
  final WalletViewVo walletVo;

  ActivatedWalletState({this.walletVo});
}

// class UpdatingWalletBalanceState extends WalletCmpState {}
//
// class UpdatedWalletBalanceState extends WalletVoAwareCmpState {
//   UpdatedWalletBalanceState({WalletViewVo walletVo}) : super(walletVo: walletVo);
// }
//
// class UpdateFailedWalletBalanceState extends WalletCmpState {}

// class UpdateWalletPageState extends WalletVoAwareCmpState {
//   final LegalSign sign;
//   final QuotesModel quoteModel;
//   final WalletViewVo walletVo;
//   final int updateStatus;//-1、fail 0、complete 1、loading
//   UpdateWalletPageState(this.updateStatus, {this.sign,this.quoteModel,this.walletVo}): super(walletVo: walletVo);
// }

// class UpdatingQuotesState extends WalletCmpState {}
//
// class UpdatedQuotesState extends WalletCmpState {
//   final QuotesModel quoteModel;
//
//   UpdatedQuotesState({this.quoteModel});
// }

/// 余额状态
class BalanceState extends WalletCmpState {
  final Status status;
  final String symbol;
  final WalletViewVo walletVo;

  BalanceState({@required this.walletVo, this.status, this.symbol});
}

/// 法币行情计价
class LegalSignState extends WalletCmpState {
  final LegalSign sign;

  LegalSignState({this.sign});
}

/// 行情价格
class QuotesState extends WalletCmpState {
  final Status status;
  final QuotesModel quotes;

  QuotesState({this.status, this.quotes});
}

class GasPriceState extends WalletCmpState with EquatableMixin {
  final Status status;
  final GasPriceRecommend ethGasPriceRecommend;
  final GasPriceRecommend btcGasPriceRecommend;
  final GasPriceType type;

  GasPriceState({this.status, this.ethGasPriceRecommend, this.btcGasPriceRecommend, this.type});

  @override
  List<Object> get props => [status, ethGasPriceRecommend, btcGasPriceRecommend];
}

class UpdateWalletExpandState extends WalletCmpState {
  final WalletExpandInfoEntity walletExpandInfoEntity;

  UpdateWalletExpandState(this.walletExpandInfoEntity);
}

class UpdateCrossChainTokenListState extends WalletCmpState {
  final List<CrossChainToken> crossChainTokenList;

  UpdateCrossChainTokenListState(this.crossChainTokenList);
}
