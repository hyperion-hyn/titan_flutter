import 'package:local_auth/local_auth.dart';
import 'package:meta/meta.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';


@immutable
abstract class AuthEvent {}

class SetBioAuthEvent extends AuthEvent {
  final BiometricType biometricType;
  final bool value;
  final Wallet wallet;

  SetBioAuthEvent(
    this.biometricType,
    this.value,
    this.wallet,
  );
}

class RefreshBioAuthConfigEvent extends AuthEvent {
  final Wallet wallet;

  RefreshBioAuthConfigEvent(this.wallet);
}
