import 'package:bloc/bloc.dart';
import 'package:titan/src/business/wallet/coin_market_api.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';

import 'wallet_manager_event.dart';
import 'wallet_manager_state.dart';

class WalletManagerBloc extends Bloc<WalletManagerEvent, WalletManagerState> {
  static const String QUOTE_UNIT = "USD";

  CoinMarketApi _coinMarketApi = CoinMarketApi();

  @override
  WalletManagerState get initialState => WalletEmptyState();

  @override
  Stream<WalletManagerState> mapEventToState(WalletManagerEvent event) async* {
    if (event is ScanWalletEvent) {
      yield* _scanWallet();
    }
  }

  Stream<WalletManagerState> _scanWallet() async* {
    var wallets = await WalletUtil.scanWallets();
    print("wallets is ${wallets.length}");
    if (wallets.length == 0) {
      yield WalletEmptyState();
    } else {
      Wallet wallet = wallets[0];
      yield ShowWalletState(wallets);
    }
  }
}
