import 'package:titan/src/basic/bloc/submit_bloc/bloc.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/utils/exception_process.dart';
import 'package:titan/src/utils/md5_util.dart';

import 'bloc.dart';

class ResetFundPasswordBloc extends SubmitBloc<SubmitEvent, SubmitState> {
  UserService _userService;

  ResetFundPasswordBloc(this._userService);

  @override
  SubmitState get initialState => InitSubmitState();

  @override
  Stream<SubmitState> mapEventToState(SubmitEvent event) async* {
    if (event is ResetFundPassword) {
      yield* _mapResetPassword(event);
    }
  }

  Stream<SubmitState> _mapResetPassword(ResetFundPassword event) async* {
    yield SubmitIngState();
    try {
      await _userService.resetFundPassword(event.email, Md5Util.generateMd5(event.loginPassword),
          Md5Util.generateMd5(event.fundPassword), event.verificationCode);
      yield SubmitSuccessState();
    } catch (_) {
      yield SubmitFailState();
      ExceptionProcess.process(_);
    }
  }
}
