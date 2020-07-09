import 'package:local_auth/local_auth.dart';
import 'package:meta/meta.dart';
import 'package:titan/src/components/auth/model.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

@immutable
abstract class AuthEvent {}

class SetBioAuthEvent extends AuthEvent {
  final BiometricType biometricType;
  final bool value;
  final String walletAddress;

  SetBioAuthEvent(
    this.biometricType,
    this.value,
    this.walletAddress,
  );
}

class RefreshBioAuthConfigEvent extends AuthEvent {
  final String walletAddress;

  RefreshBioAuthConfigEvent(this.walletAddress);
}
