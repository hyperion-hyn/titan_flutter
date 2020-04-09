import 'package:flutter/widgets.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/me/model/user_info.dart';
import 'package:titan/src/pages/me/model/user_token.dart';

@immutable
abstract class AbsLoginState {}

class InitialLoginState extends AbsLoginState {}

class LoginState extends AbsLoginState {
  final Status status;
  final String msg;

  final UserToken userToken;

  LoginState({
    @required this.status,
    this.msg,
    this.userToken,
  });
}
