import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:titan/src/basic/bloc/submit_bloc/bloc.dart';
import 'package:titan/src/business/login/login_bus_event.dart';
import 'package:titan/src/business/me/model/user_token.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/utils/exception_process.dart';
import 'package:titan/src/utils/md5_util.dart';

import 'bloc.dart';

class LoginBloc extends Bloc<LoginEvent, SubmitState> {
  UserService _userService;

  LoginBloc(this._userService);

  @override
  SubmitState get initialState => InitSubmitState();

  @override
  Stream<SubmitState> mapEventToState(LoginEvent event) async* {
    if (event is Login) {
      yield* _mapLogin(event);
    }
  }

  Stream<SubmitState> _mapLogin(Login event) async* {
    yield Submiting();
    try {
      await _userService.login(event.email, Md5Util.generateMd5(event.password));
      LOGIN_STATUS = 2;
      eventBus.fire(LoginSuccessBusEvent());
      yield SubmitSuccess();
    } catch (_) {
      yield SubmitFail(message: "系统错误");
      ExceptionProcess.process(_);
    }
  }
}
