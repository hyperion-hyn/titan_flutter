import 'package:titan/src/basic/bloc/submit_bloc/bloc.dart';

abstract class LoginEvent extends SubmitEvent {
  const LoginEvent();
}

class Login extends LoginEvent {
  String email;
  String password;

  Login(this.email, this.password);
}
