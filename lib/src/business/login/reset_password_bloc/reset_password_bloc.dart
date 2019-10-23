import 'package:titan/src/business/login/submit_bloc/bloc.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/utils/exception_process.dart';
import 'package:titan/src/utils/md5_util.dart';

import 'bloc.dart';

class ResetPasswordBloc extends SubmitBloc<SubmitEvent, SubmitState> {
  UserService _userService;

  ResetPasswordBloc(this._userService);

  @override
  SubmitState get initialState => InitSubmitState();

  @override
  Stream<SubmitState> mapEventToState(SubmitEvent event) async* {
    if (event is ResetPassword) {
      yield* _mapResetPassword(event);
    }
  }

  Stream<SubmitState> _mapResetPassword(ResetPassword event) async* {
    yield Submiting();
    try {
      await _userService.resetPassword(event.email, Md5Util.generateMd5(event.password), event.verificationCode);
      yield SubmitSuccess();
    } catch (_) {
      yield SubmitFail();
      ExceptionProcess.process(_);
    }
  }
}
