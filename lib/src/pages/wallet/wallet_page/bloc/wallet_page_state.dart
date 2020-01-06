import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';

abstract class WalletPageState extends Equatable {
  const WalletPageState();
}

class InitialWalletPageState extends WalletPageState {
  @override
  List<Object> get props => [];
}

class LoadingWalletState extends WalletPageState {
  @override
  List<Object> get props => null;
}

class EmptyWalletState extends WalletPageState {
  @override
  List<Object> get props => null;
}

class WalletLoadedState extends WalletPageState {
  final WalletVo walletVo;

  WalletLoadedState({@required this.walletVo});

  @override
  List<Object> get props => [walletVo];
}
