import 'package:local_auth/local_auth.dart';
import 'package:meta/meta.dart';

import '../model.dart';

@immutable
abstract class AuthState {}

class InitialAuthState extends AuthState {}

class SetBioAuthState extends AuthState {
  final BiometricType biometricType;
  final bool value;
  final String walletAddress;

  SetBioAuthState(
    this.biometricType,
    this.value,
    this.walletAddress,
  );
}

class RefreshBioAuthConfigState extends AuthState {
  final String walletAddress;

  RefreshBioAuthConfigState(this.walletAddress);
}
