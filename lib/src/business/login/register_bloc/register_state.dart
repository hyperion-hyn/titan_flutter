abstract class RegisterState {
  const RegisterState();
}

class InitSubmitState extends RegisterState {}

class SubmitIngState extends RegisterState {}

class SubmitSuccessState extends RegisterState {}

class SubmitFailState extends RegisterState {
  String message;

  SubmitFailState({this.message});
}
