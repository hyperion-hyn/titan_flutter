import 'package:bloc/bloc.dart';

import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  @override
  WalletState get initialState => WalletEmptyState();

  @override
  Stream<WalletState> mapEventToState(WalletEvent event) async* {
    if (event is CreateNewWalletEvent) {
      yield CreateNewWalletState();
    }
  }
}
