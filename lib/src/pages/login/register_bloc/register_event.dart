abstract class AbsRegisterEvent {}

class RegisterEvent extends AbsRegisterEvent {
  String email;
  String password;
  String fundPassword;
  String invitationCode;
  int verificationCode;

  RegisterEvent(
    this.email,
    this.password,
    this.fundPassword,
    this.invitationCode,
    this.verificationCode,
  );
}

//class ResetToInit extends RegisterEvent {}
