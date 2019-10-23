import 'package:bloc/bloc.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/utils/exception_process.dart';
import 'package:titan/src/utils/md5_util.dart';

import 'bloc.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  UserService _userService;

  RegisterBloc(this._userService);

  @override
  RegisterState get initialState => WaittingRegister();

  @override
  Stream<RegisterState> mapEventToState(RegisterEvent event) async* {
    if (event is Register) {
      yield* _mapRegister(event);
    }
  }

  Stream<RegisterState> _mapRegister(Register event) async* {
    yield Registering();
    try {
      await _userService.registoer(event.email, Md5Util.generateMd5(event.password), event.verificationCode,
          event.invitationCode, Md5Util.generateMd5(event.fundPassword));
      yield RegisterSuccess();
    } catch (_) {
      yield RegisterFail("系统错误");
      ExceptionProcess.process(_);
    }
  }
}
