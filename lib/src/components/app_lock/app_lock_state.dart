part of 'app_lock_bloc.dart';

@immutable
abstract class AppLockState {}

class AppLockInitialState extends AppLockState {}

class LockWalletState extends AppLockState {}

class UnlockWalletState extends AppLockState {}
