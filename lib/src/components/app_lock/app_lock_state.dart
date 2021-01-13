part of 'app_lock_bloc.dart';

@immutable
abstract class AppLockState {}

class AppLockInitialState extends AppLockState {}

class LockWalletState extends AppLockState {}

class UnlockWalletState extends AppLockState {}

class SetWalletLockState extends AppLockState {
  final String walletAddress;
  final bool isEnabled;

  SetWalletLockState(this.walletAddress,this.isEnabled);
}
