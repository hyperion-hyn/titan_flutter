import 'package:meta/meta.dart';

import '../model.dart';

@immutable
abstract class AuthState {}

class InitialAuthState extends AuthState {}

class InitAuthConfigState extends AuthState {
  final AuthConfigModel authConfigModel;

  InitAuthConfigState({this.authConfigModel});
}

class SetBioAuthState extends AuthState {
  final bool value;
  final String walletFileName;

  SetBioAuthState(this.value, this.walletFileName);
}

class SaveAuthConfigState extends AuthState {
  final AuthConfigModel authConfigModel;
  final String walletFileName;

  SaveAuthConfigState(this.walletFileName, this.authConfigModel);
}

class RefreshBioAuthConfigState extends AuthState {
  final String walletFileName;

  RefreshBioAuthConfigState(this.walletFileName);
}
