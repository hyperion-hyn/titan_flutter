part of 'app_lock_bloc.dart';

@immutable
abstract class AppLockEvent {}

class LockWalletEvent extends AppLockEvent {}

class UnLockWalletEvent extends AppLockEvent {}
