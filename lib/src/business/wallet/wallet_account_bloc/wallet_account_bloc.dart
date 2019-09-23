import 'package:bloc/bloc.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';

import 'wallet_account_event.dart';
import 'wallet_account_state.dart';


class WalletBloc extends Bloc<WalletAccountEvent, WalletAccountState> {
  @override
  WalletAccountState get initialState => WalletEmptyState();

  @override
  Stream<WalletAccountState> mapEventToState(WalletAccountEvent event) async* {
    if (event is ScanWalletEvent) {
      yield* _scanWallet();
    }
  }

  Stream<WalletAccountState> _scanWallet() async* {
    var wallets = await WalletUtil.scanWallets();
    if (wallets.length == 0) {
      yield WalletEmptyState();
    } else {
      print(wallets[0]);
      yield ShowWalletState(wallets[0]);
    }
  }
}
