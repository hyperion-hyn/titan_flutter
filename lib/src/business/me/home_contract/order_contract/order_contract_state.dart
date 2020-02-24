import 'package:titan/src/basic/bloc/submit_bloc/bloc.dart';
import 'package:titan/src/business/me/model/pay_order.dart';

abstract class OrderContractState {}

class InitOrderContractState extends OrderContractState {}

class OrderingState extends OrderContractState {}

class OrderFreeSuccessState extends OrderContractState {
  PayOrder payOrder;

  OrderFreeSuccessState(this.payOrder);
}

class OrderSuccessState extends OrderContractState {
  PayOrder payOrder;

  OrderSuccessState(this.payOrder);
}

class OrderOverRangeState extends OrderContractState {}

class OrderFailState extends OrderContractState {}
