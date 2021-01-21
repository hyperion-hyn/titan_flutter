part of 'app_lock_bloc.dart';

@immutable
abstract class AppLockState {}

class AppLockInitialState extends AppLockState {}

class SetWalletLockState extends AppLockState {
  final bool isEnabled;

  SetWalletLockState(this.isEnabled);
}

class SetWalletLockAwayTimeState extends AppLockState {
  final int awayTime;

  SetWalletLockAwayTimeState(this.awayTime);
}

class SetWalletLockBioAuthState extends AppLockState {
  final bool isEnabled;

  SetWalletLockBioAuthState(this.isEnabled);
}

class LockWalletState extends AppLockState {}

class UnlockWalletState extends AppLockState {}
