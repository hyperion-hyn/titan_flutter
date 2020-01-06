import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/components/quotes/coin_market_api.dart';
import 'package:titan/src/pages/wallet/model/wallet_account_vo.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/pages/wallet/service/wallet_service.dart';
import 'package:titan/src/plugins/wallet/account.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';

import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  BuildContext context;
  WalletService _walletService;

  WalletBloc({@required this.context}) : _walletService = WalletService(context: context);


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
    if (wallets.length == 0) {
      yield WalletEmptyState();
    } else {
      Wallet wallet;
      String defaultWalletFileName = await _walletService.getDefaultWalletFileName();
      if (defaultWalletFileName == null) {
        wallet = wallets[0];
        await _walletService.saveDefaultWalletFileName(wallet.keystore.fileName);
      } else {
        for (var walletTemp in wallets) {
          if (walletTemp.keystore.fileName == defaultWalletFileName) {
            wallet = walletTemp;
            break;
          }
        }
        if (wallet == null) {
          wallet = wallets[0];
        }
      }
      var walletVo = await _walletService.buildWalletVo(wallet);
      yield ShowWalletState(walletVo);
      await _walletService.updateWalletVoBalace(walletVo);
      yield ShowWalletState(walletVo);
      walletVo = await _walletService.updateWalletVoPrice(walletVo);
      yield ShowWalletState(walletVo);
      _walletService.saveDefaultWalletVo(walletVo);
    }
  }

  Stream<WalletState> _updateWallet(WalletVo walletVo) async* {
//    yield ScanWalletLoadingState();
    yield ShowWalletState(walletVo);
    await _walletService.updateWalletVoBalace(walletVo);
    yield ShowWalletState(walletVo);
    yield ShowWalletState(await _walletService.updateWalletVoPrice(walletVo));
  }
}
