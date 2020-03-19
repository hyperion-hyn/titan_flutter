import 'package:equatable/equatable.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';

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