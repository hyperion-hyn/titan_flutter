import 'package:titan/src/basic/bloc/submit_bloc/bloc.dart';

abstract class ContractEvent {
  const ContractEvent();
}

class LoadContracts extends ContractEvent {}

class SwtichContract extends ContractEvent {
  int index;

  SwtichContract(this.index);
}
