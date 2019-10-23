import 'package:titan/src/business/login/submit_bloc/bloc.dart';

abstract class ResetPasswordEvent extends SubmitEvent {
  const ResetPasswordEvent();
}

class ResetPassword extends ResetPasswordEvent {
  String email;
  String password;
  int verificationCode;

  ResetPassword(this.email, this.password, this.verificationCode);
}
