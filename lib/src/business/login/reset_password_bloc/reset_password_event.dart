abstract class ResetPasswordEvent {
  const ResetPasswordEvent();
}

class ResetToInit extends ResetPasswordEvent {}

class ResetPassword extends ResetPasswordEvent {
  String email;
  String password;
  int verificationCode;

  ResetPassword(this.email, this.password, this.verificationCode);
}
