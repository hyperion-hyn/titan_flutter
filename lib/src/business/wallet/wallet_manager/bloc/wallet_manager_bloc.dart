import 'package:bloc/bloc.dart';
import 'package:titan/src/business/wallet/coin_market_api.dart';
import 'package:titan/src/business/wallet/service/wallet_service.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';

import 'wallet_manager_event.dart';
import 'wallet_manager_state.dart';

class WalletManagerBloc extends Bloc<WalletManagerEvent, WalletManagerState> {
  static const String QUOTE_UNIT = "USD";

  WalletService _walletService = WalletService();

  @override
  WalletManagerState get initialState => WalletEmptyState();

  @override
  Stream<WalletManagerState> mapEventToState(WalletManagerEvent event) async* {
    if (event is ScanWalletEvent) {
      yield* _scanWallet();
    } else if (event is SwitchWalletEvent) {
      yield* _switchWallet(event);
    }
  }

  Stream<WalletManagerState> _scanWallet() async* {
    var wallets = await WalletUtil.scanWallets();
    var defaultWalletFileName = await _walletService.getDefaultWalletFileName();
    print("wallets is ${wallets.length}");
    if (wallets.length == 0) {
      yield WalletEmptyState();
    } else {
      yield ShowWalletState(wallets, defaultWalletFileName);
    }
  }

  Stream<WalletManagerState> _switchWallet(SwitchWalletEvent switchWalletEvent) async* {
    String defaultWalletFileName = switchWalletEvent.wallet.keystore.fileName;
    await _walletService.saveDefaultWalletFileName(defaultWalletFileName);
    var wallets = await WalletUtil.scanWallets();
    print("wallets is ${wallets.length}");
    if (wallets.length == 0) {
      yield WalletEmptyState();
    } else {
      yield ShowWalletState(wallets, defaultWalletFileName);
    }
  }
}
