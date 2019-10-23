import 'package:titan/src/basic/bloc/submit_bloc/bloc.dart';

abstract class ResetFundPasswordEvent extends SubmitEvent {
  const ResetFundPasswordEvent();
}

class ResetFundPassword extends ResetFundPasswordEvent {
  String email;
  String loginPassword;
  String fundPassword;
  int verificationCode;

  ResetFundPassword(this.email, this.loginPassword, this.fundPassword, this.verificationCode);
}
