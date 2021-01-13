part of 'app_lock_bloc.dart';

@immutable
abstract class AppLockEvent {}

class LockWalletEvent extends AppLockEvent {}

class UnLockWalletEvent extends AppLockEvent {}

class SetWalletLockEvent extends AppLockEvent {
  final String walletAddress;
  final bool isEnabled;

  SetWalletLockEvent(this.walletAddress, this.isEnabled);
}
