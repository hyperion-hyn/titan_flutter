import 'package:titan/src/basic/bloc/submit_bloc/bloc.dart';

abstract class OrderContractEvent {
  const OrderContractEvent();
}

class OrderFreeContract extends OrderContractEvent {
  int contractId;

  OrderFreeContract(this.contractId);
}

class OrderContract extends OrderContractEvent {
  int contractId;

  OrderContract(this.contractId);
}

class ResetToInit extends OrderContractEvent {}
