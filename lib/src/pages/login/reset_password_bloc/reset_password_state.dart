abstract class ResetPasswordState {
  const ResetPasswordState();
}

class InitSubmitState extends ResetPasswordState {}

class SubmitIngState extends ResetPasswordState {}

class SubmitSuccessState extends ResetPasswordState {}

class SubmitFailState extends ResetPasswordState {
  String message;

  SubmitFailState({this.message});
}
