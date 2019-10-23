abstract class LoginEvent {
  const LoginEvent();
}

class Login extends LoginEvent {
  String email;
  String password;

  Login(this.email, this.password);
}
