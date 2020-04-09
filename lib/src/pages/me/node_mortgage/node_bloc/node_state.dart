import 'package:titan/src/pages/me/model/mortgage_info_v2.dart';

abstract class NodeState {
  const NodeState();
}

class InitState extends NodeState {}

class LoadingState extends NodeState {}

class LoadFailState extends NodeState {}

class LoadedState extends NodeState {
  List<MortgageInfoV2> mortgageInfoList;

  LoadedState(this.mortgageInfoList);
}

class NodeSwitchedState extends NodeState {
  int index;

  NodeSwitchedState(this.index);
}
