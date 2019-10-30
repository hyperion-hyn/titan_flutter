import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/utils/exception_process.dart';
import 'package:titan/src/utils/md5_util.dart';
import 'package:bloc/bloc.dart';
import 'bloc.dart';

class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  UserService _userService;

  ResetPasswordBloc(this._userService);

  @override
  ResetPasswordState get initialState => InitSubmitState();

  @override
  Stream<ResetPasswordState> mapEventToState(ResetPasswordEvent event) async* {
    if (event is ResetPassword) {
      yield* _mapResetPassword(event);
    } else if (event is ResetToInit) {
      yield initialState;
    }
  }

  Stream<ResetPasswordState> _mapResetPassword(ResetPassword event) async* {
    yield SubmitIngState();
    try {
      await _userService.resetPassword(event.email, Md5Util.generateMd5(event.password), event.verificationCode);
      yield SubmitSuccessState();
    } catch (_) {
      yield SubmitFailState();
      ExceptionProcess.process(_);
    }
  }
}
