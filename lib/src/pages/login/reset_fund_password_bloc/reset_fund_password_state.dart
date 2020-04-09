abstract class ResetFundPasswordState {
  const ResetFundPasswordState();
}

class InitSubmitState extends ResetFundPasswordState {}

class SubmitIngState extends ResetFundPasswordState {}

class SubmitSuccessState extends ResetFundPasswordState {}

class SubmitFailState extends ResetFundPasswordState {
  String message;

  SubmitFailState({this.message});
}
