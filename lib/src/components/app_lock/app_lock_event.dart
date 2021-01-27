part of 'app_lock_bloc.dart';

@immutable
abstract class AppLockEvent {}

class LoadAppLockConfigEvent extends AppLockEvent {}

class SetWalletLockEvent extends AppLockEvent {
  final bool isEnabled;

  SetWalletLockEvent(this.isEnabled);
}

class SetWalletLockAwayTimeEvent extends AppLockEvent {
  final int awayTime;

  SetWalletLockAwayTimeEvent(this.awayTime);
}

class SetWalletLockBioAuthEvent extends AppLockEvent {
  final bool isEnabled;

  SetWalletLockBioAuthEvent(this.isEnabled);
}

class SetAppLockCountDownEvent extends AppLockEvent {
  final bool isAway;

  SetAppLockCountDownEvent(this.isAway);
}

class SetAppLockPwdEvent extends AppLockEvent {
  final String pwd;
  final String hint;

  SetAppLockPwdEvent(this.pwd, this.hint);
}

class LockAppEvent extends AppLockEvent {}

class UnLockAppEvent extends AppLockEvent {}
