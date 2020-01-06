import 'package:equatable/equatable.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';

abstract class WalletCmpEvent extends Equatable {
  const WalletCmpEvent();

  @override
  List<Object> get props => null;
}

class ActiveWalletEvent extends WalletCmpEvent {
  final WalletVo walletVo;

  ActiveWalletEvent({this.walletVo});

  @override
  List<Object> get props => [walletVo];
}

class FindBestWalletAndActiveEvent extends WalletCmpEvent {}

class UpdateActivatedWalletBalanceEvent extends WalletCmpEvent {}
