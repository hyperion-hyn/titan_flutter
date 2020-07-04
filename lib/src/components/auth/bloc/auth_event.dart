import 'package:meta/meta.dart';
import 'package:titan/src/components/auth/model.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

@immutable
abstract class AuthEvent {}

class InitAuthConfigEvent extends AuthEvent {
  final AuthConfigModel authConfigModel;

  InitAuthConfigEvent({this.authConfigModel});
}

class SaveAuthConfigEvent extends AuthEvent {
  final AuthConfigModel authConfigModel;
  final String walletFileName;

  SaveAuthConfigEvent(this.walletFileName, this.authConfigModel);
}

class SetBioAuthEvent extends AuthEvent {
  final bool value;
  final String walletFileName;

  SetBioAuthEvent(this.value, this.walletFileName);
}

class RefreshBioAuthConfigEvent extends AuthEvent {
  final String walletFileName;

  RefreshBioAuthConfigEvent(this.walletFileName);
}
