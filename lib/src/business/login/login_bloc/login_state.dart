import 'package:equatable/equatable.dart';

abstract class LoginState {
  const LoginState();
}

class WaittingLogin extends LoginState {}

class Logining extends LoginState {}

class LoginSuccess extends LoginState {}

class LoginFail extends LoginState {
  String message;

  LoginFail(this.message);
}
