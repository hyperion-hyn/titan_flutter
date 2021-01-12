import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'app_lock_event.dart';
part 'app_lock_state.dart';

class AppLockBloc extends Bloc<AppLockEvent, AppLockState> {
  @override
  AppLockState get initialState => AppLockInitialState();

  @override
  Stream<AppLockState> mapEventToState(
    AppLockEvent event,
  ) async* {
    if (event is LockWalletEvent) {
      yield LockWalletState();
    } else if (event is UnLockWalletEvent) {
      yield UnlockWalletState();
    }
  }
}
