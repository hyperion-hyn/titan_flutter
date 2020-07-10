import 'package:local_auth/local_auth.dart';
import 'package:meta/meta.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

import '../model.dart';

@immutable
abstract class AuthState {}

class InitialAuthState extends AuthState {}

class SetBioAuthState extends AuthState {
  final BiometricType biometricType;
  final bool value;
  final Wallet wallet;

  SetBioAuthState(
    this.biometricType,
    this.value,
    this.wallet
  );
}

class RefreshBioAuthConfigState extends AuthState {
  final Wallet wallet;

  RefreshBioAuthConfigState(this.wallet);
}
