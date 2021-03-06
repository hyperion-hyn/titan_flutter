part of 'app_lock_bloc.dart';

@immutable
abstract class AppLockState {}

class AppLockInitialState extends AppLockState {}

class LoadAppLockConfigState extends AppLockState {}

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

class SetWalletLockCountDownState extends AppLockState {
  final bool isAway;

  SetWalletLockCountDownState(this.isAway);
}

class SetAppLockPwdState extends AppLockState {
  final String pwd;
  final String hint;

  SetAppLockPwdState(this.pwd, this.hint);
}

class LockAppState extends AppLockState {}

class UnlockAppState extends AppLockState {}


class IgnoreAppLockState extends AppLockState {
  final bool value;

  IgnoreAppLockState(this.value);
}
