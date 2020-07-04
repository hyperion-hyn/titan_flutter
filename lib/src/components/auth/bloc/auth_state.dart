import 'package:meta/meta.dart';

import '../model.dart';

@immutable
abstract class AuthState {}

class InitialAuthState extends AuthState {}

class SetBioAuthState extends AuthState {
  final bool value;
  final String walletFileName;

  SetBioAuthState(this.value, this.walletFileName);
}

class RefreshBioAuthConfigState extends AuthState {
  final String walletFileName;

  RefreshBioAuthConfigState(this.walletFileName);
}
