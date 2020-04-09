import 'package:titan/src/basic/bloc/submit_bloc/bloc.dart';
import 'package:titan/src/pages/me/model/contract_info_v2.dart';

abstract class ContractState {
  const ContractState();
}

class InitState extends ContractState {}

class LoadingState extends ContractState {}

class LoadFailState extends ContractState {}

class LoadedState extends ContractState {
  List<ContractInfoV2> contrctInfoList;

  LoadedState(this.contrctInfoList);
}

class ContractSwitchedState extends ContractState {
  int index;

  ContractSwitchedState(this.index);
}
