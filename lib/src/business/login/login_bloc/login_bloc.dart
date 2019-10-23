import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:titan/src/business/login/login_bus_event.dart';
import 'package:titan/src/business/me/model/user_token.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/utils/exception_process.dart';
import 'package:titan/src/utils/md5_util.dart';

import 'bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  UserService _userService;

  LoginBloc(this._userService);

  @override
  LoginState get initialState => WaittingLogin();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is Login) {
      yield* _mapLogin(event);
    }
  }

  Stream<LoginState> _mapLogin(Login event) async* {
    yield Logining();
    try {
      UserToken userToken = await _userService.login(event.email, Md5Util.generateMd5(event.password));
      if (userToken == null) {
        yield LoginFail("系统错误");
      } else {
        LOGIN_STATUS = 2;
        eventBus.fire(LoginSuccessBusEvent());
        yield LoginSuccess();
      }
    } catch (_) {
      yield LoginFail("系统错误");
      ExceptionProcess.process(_);
    }
  }
}
