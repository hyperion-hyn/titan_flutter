import 'package:meta/meta.dart';
import 'package:titan/src/components/auth/model.dart';

@immutable
abstract class AuthEvent {}

class UpdateAuthConfigEvent extends AuthEvent {
  final AuthConfigModel authConfigModel;

  UpdateAuthConfigEvent({this.authConfigModel});
}

class UpdateAuthStatusEvent extends AuthEvent {
  final bool authorized;

  UpdateAuthStatusEvent({this.authorized});
}
