import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/login/register_bloc/register_state.dart';
import 'package:titan/src/pages/me/service/user_service.dart';
import 'package:titan/src/utils/md5_util.dart';

import 'package:bloc/bloc.dart';

import 'bloc.dart';

class RegisterBloc extends Bloc<AbsRegisterEvent, AbsRegisterState> {
  UserService _userService = UserService();

  RegisterBloc();

  @override
  AbsRegisterState get initialState => InitialRegisterState();

  @override
  Stream<AbsRegisterState> mapEventToState(AbsRegisterEvent event) async* {
    if (event is RegisterEvent) {
      yield* _mapRegister(event);
    }
  }

  Stream<RegisterState> _mapRegister(RegisterEvent event) async* {
    yield RegisterState(status: Status.loading);
    try {
      await _userService.register(event.email, Md5Util.generateMd5(event.password), event.verificationCode,
          event.invitationCode, Md5Util.generateMd5(event.fundPassword));
      yield RegisterState(status: Status.success);
    } catch (_) {
      yield RegisterState(status: Status.failed, msg: _.message ?? '注册失败');
    }
  }
}
