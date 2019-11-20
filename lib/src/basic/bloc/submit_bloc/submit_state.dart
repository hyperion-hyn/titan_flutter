abstract class SubmitState {
  const SubmitState();
}

class InitSubmitState extends SubmitState {}

class SubmitIngState extends SubmitState {}

class SubmitSuccessState extends SubmitState {}

class SubmitFailState extends SubmitState {
  String message;

  SubmitFailState({this.message});
}
