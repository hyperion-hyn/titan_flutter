abstract class ResetFundPasswordEvent {
  const ResetFundPasswordEvent();
}

class ResetFundPassword extends ResetFundPasswordEvent {
  String email;
  String loginPassword;
  String fundPassword;
  int verificationCode;

  ResetFundPassword(this.email, this.loginPassword, this.fundPassword, this.verificationCode);
}

class ResetToInit extends ResetFundPasswordEvent {}
