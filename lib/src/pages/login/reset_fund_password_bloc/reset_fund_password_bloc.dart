import 'package:titan/src/pages/login/reset_fund_password_bloc/reset_fund_password_state.dart';
import 'package:titan/src/pages/me/service/user_service.dart';
import 'package:titan/src/utils/exception_process.dart';
import 'package:titan/src/utils/md5_util.dart';
import 'package:bloc/bloc.dart';
import 'bloc.dart';

class ResetFundPasswordBloc extends Bloc<ResetFundPasswordEvent, ResetFundPasswordState> {
  UserService _userService;

  ResetFundPasswordBloc(this._userService);

  @override
  ResetFundPasswordState get initialState => InitSubmitState();

  @override
  Stream<ResetFundPasswordState> mapEventToState(ResetFundPasswordEvent event) async* {
    if (event is ResetFundPassword) {
      yield* _mapResetPassword(event);
    } else if (event is ResetToInit) {
      yield initialState;
    }
  }

  Stream<ResetFundPasswordState> _mapResetPassword(ResetFundPassword event) async* {
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
