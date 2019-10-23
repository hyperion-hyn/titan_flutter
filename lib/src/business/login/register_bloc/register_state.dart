

abstract class RegisterState {
  const RegisterState();
}

class WaittingRegister extends RegisterState {}

class Registering extends RegisterState {}

class RegisterSuccess extends RegisterState {}

class RegisterFail extends RegisterState {
  String message;

  RegisterFail(this.message);
}
