import 'package:titan/src/basic/bloc/submit_bloc/bloc.dart';

abstract class AbsLoginEvent {}

class LoginEvent extends AbsLoginEvent {
  String email;
  String password;

  LoginEvent(
    this.email,
    this.password,
  );
}
