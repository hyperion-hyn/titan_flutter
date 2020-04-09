import 'package:titan/src/basic/bloc/submit_bloc/bloc.dart';
import 'package:titan/src/pages/me/model/pay_order.dart';

abstract class SnapUpState {}

class InitSnapUpNodeState extends SnapUpState {}

class SnapUpIngState extends SnapUpState {}

class SnapSuccessState extends SnapUpState {
  SnapSuccessState();
}

class SnapUpOverRangeState extends SnapUpState {}

class SnapUpFailState extends SnapUpState {}
