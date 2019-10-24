import 'package:titan/src/basic/bloc/submit_bloc/bloc.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/utils/exception_process.dart';
import 'package:titan/src/utils/md5_util.dart';

import 'bloc.dart';

class RegisterBloc extends SubmitBloc<RegisterEvent, SubmitState> {
  UserService _userService;

  RegisterBloc(this._userService);

  @override
  SubmitState get initialState => InitSubmitState();

  @override
  Stream<SubmitState> mapEventToState(SubmitEvent event) async* {
    if (event is Register) {
      yield* _mapRegister(event);
    }
  }

  Stream<SubmitState> _mapRegister(Register event) async* {
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
