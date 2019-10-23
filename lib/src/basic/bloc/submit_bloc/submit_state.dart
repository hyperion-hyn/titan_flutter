abstract class SubmitState {
  const SubmitState();
}

class InitSubmitState extends SubmitState {}

class Submiting extends SubmitState {}

class SubmitSuccess extends SubmitState {}

class SubmitFail extends SubmitState {
  String message;

  SubmitFail({this.message});
}
