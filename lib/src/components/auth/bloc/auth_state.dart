import 'package:meta/meta.dart';

import '../model.dart';

@immutable
abstract class AuthState {}

class InitialAuthState extends AuthState {}

class UpdateAuthConfigState extends AuthState {
  final AuthConfigModel authConfigModel;

  UpdateAuthConfigState({this.authConfigModel});
}

class RefreshBioAuthConfigState extends AuthState {

  RefreshBioAuthConfigState();
}

class UpdateAuthStatusState extends AuthState {
  final bool authorized;

  UpdateAuthStatusState({this.authorized});
}
