import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:titan/src/business/wallet/coin_market_api.dart';
import 'package:titan/src/business/wallet/model/wallet_account_vo.dart';
import 'package:titan/src/business/wallet/model/wallet_vo.dart';
import 'package:titan/src/business/wallet/service/wallet_service.dart';
import 'package:titan/src/plugins/wallet/account.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';

import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletService _walletService = WalletService();

  @override
  WalletState get initialState => WalletEmptyState();

  @override
  Stream<WalletState> mapEventToState(WalletEvent event) async* {
    if (event is ScanWalletEvent) {
      yield* _scanWallet();
    } else if (event is UpdateWalletEvent) {
      yield* _updateWallet(event.walletVo);
    }
  }

  Stream<WalletState> _scanWallet() async* {
    yield ScanWalletLoadingState();
    var wallets = await WalletUtil.scanWallets();
    print("wallets is ${wallets.length}");
    if (wallets.length == 0) {
      yield WalletEmptyState();
    } else {
      Wallet wallet = wallets[0];
      var walletVo = await _walletService.buildWalletVo(wallet);
      yield ShowWalletState(walletVo);
      await _walletService.updateWalletVoBalace(walletVo);
      yield ShowWalletState(walletVo);
      yield ShowWalletState(await _walletService.updateWalletVoPrice(walletVo));
    }
  }

  Stream<WalletState> _updateWallet(WalletVo walletVo) async* {
    yield ScanWalletLoadingState();
    yield ShowWalletState(walletVo);
    await _walletService.updateWalletVoBalace(walletVo);
    yield ShowWalletState(walletVo);
    yield ShowWalletState(await _walletService.updateWalletVoPrice(walletVo));
  }
}
