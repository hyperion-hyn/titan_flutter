import 'package:equatable/equatable.dart';
import 'package:titan/src/components/wallet/model.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/config/consts.dart';

abstract class WalletCmpState {
  const WalletCmpState();
}

abstract class WalletVoAwareCmpState extends WalletCmpState {
  final WalletVo walletVo;

  WalletVoAwareCmpState({this.walletVo});

  @override
  List<Object> get props => [walletVo];
}

class InitialWalletCmpState extends WalletCmpState {}

class LoadingWalletState extends WalletCmpState {}

class LoadWalletFailState extends WalletCmpState {}

class ActivatedWalletState extends WalletVoAwareCmpState {
  ActivatedWalletState({WalletVo walletVo}) : super(walletVo: walletVo);
}

class UpdatingWalletBalanceState extends WalletCmpState {}

class UpdatedWalletBalanceState extends WalletVoAwareCmpState {
  UpdatedWalletBalanceState({WalletVo walletVo}) : super(walletVo: walletVo);
}

class UpdateFailedWalletBalanceState extends WalletCmpState {}

class UpdateWalletPageState extends WalletVoAwareCmpState {
  final QuotesSign sign;
  final QuotesModel quoteModel;
  final WalletVo walletVo;
  UpdateWalletPageState({this.sign,this.quoteModel,this.walletVo}): super(walletVo: walletVo);
}

class UpdatingQuotesState extends WalletCmpState {}

class UpdatedQuotesState extends WalletCmpState {
  final QuotesModel quoteModel;

  UpdatedQuotesState({this.quoteModel});
}

class UpdatedQuotesSignState extends WalletCmpState {
  final QuotesSign sign;

  UpdatedQuotesSignState({this.sign});
}

class GasPriceState extends WalletCmpState with EquatableMixin {
  final Status status;
  final GasPriceRecommend gasPriceRecommend;
  final BTCGasPriceRecommend btcGasPriceRecommend;

  GasPriceState({this.status, this.gasPriceRecommend, this.btcGasPriceRecommend});

  @override
  List<Object> get props => [status, gasPriceRecommend, btcGasPriceRecommend];
}