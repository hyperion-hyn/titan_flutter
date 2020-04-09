import 'package:titan/src/basic/bloc/status_task_mixin.dart';
import 'package:titan/src/config/consts.dart';

abstract class AbsRegisterState {}

class InitialRegisterState extends AbsRegisterState {}

class RegisterState extends AbsRegisterState with StatusTaskMixin {

  RegisterState({Status status, String msg}) {
    this.status = status;
    this.msg = msg;
  }
}
