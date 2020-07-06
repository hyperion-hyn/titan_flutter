import 'package:meta/meta.dart';

import '../model.dart';

@immutable
abstract class AuthState {}

class InitialAuthState extends AuthState {}

class SetBioAuthState extends AuthState {
  final bool value;
  final String walletAddress;

  SetBioAuthState(this.value, this.walletAddress);
}

class RefreshBioAuthConfigState extends AuthState {
  final String walletAddress;

  RefreshBioAuthConfigState(this.walletAddress);
}
