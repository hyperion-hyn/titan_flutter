import 'package:titan/src/business/login/register_bloc/register_state.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/utils/exception_process.dart';
import 'package:titan/src/utils/md5_util.dart';

import 'package:bloc/bloc.dart';

import 'bloc.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  UserService _userService;

  RegisterBloc(this._userService);

  @override
  RegisterState get initialState => InitSubmitState();

  @override
  Stream<RegisterState> mapEventToState(RegisterEvent event) async* {
    if (event is Register) {
      yield* _mapRegister(event);
    } else if (event is ResetToInit) {
      yield initialState;
    }
  }

  Stream<RegisterState> _mapRegister(Register event) async* {
    yield SubmitIngState();
    try {
      await _userService.registoer(event.email, Md5Util.generateMd5(event.password), event.verificationCode,
          event.invitationCode, Md5Util.generateMd5(event.fundPassword));
      yield SubmitSuccessState();
    } catch (_) {
      yield SubmitFailState(message: "系统错误");
      ExceptionProcess.process(_);
    }
  }
}
