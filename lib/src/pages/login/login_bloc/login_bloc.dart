import 'package:bloc/bloc.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/pages/me/model/user_token.dart';
import 'package:titan/src/pages/me/service/user_service.dart';
import 'package:titan/src/utils/md5_util.dart';

import 'bloc.dart';

class LoginBloc extends Bloc<AbsLoginEvent, AbsLoginState> {
  UserService _userService = UserService();

  LoginBloc();

  @override
  AbsLoginState get initialState => InitialLoginState();

  @override
  Stream<AbsLoginState> mapEventToState(AbsLoginEvent event) async* {
    if (event is LoginEvent) {
      yield LoginState(status: Status.loading);

      try {
        UserToken userToken = await _userService.login(event.email, Md5Util.generateMd5(event.password));
        yield LoginState(status: Status.success, userToken: userToken);
      } catch (e) {
        logger.e(e);
        yield LoginState(status: Status.failed, msg: e.message ?? '登录失败');
      }
    }
  }
}
