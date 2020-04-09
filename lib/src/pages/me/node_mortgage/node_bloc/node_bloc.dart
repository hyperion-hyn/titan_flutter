import 'package:titan/src/pages/me/model/contract_info_v2.dart';
import 'package:titan/src/pages/me/model/mortgage_info_v2.dart';
import 'package:titan/src/pages/me/service/user_service.dart';

import 'package:bloc/bloc.dart';
import 'bloc.dart';
import 'node_state.dart';

class NodeBloc extends Bloc<NodeEvent, NodeState> {
  UserService _userService;

  NodeBloc(this._userService);

  @override
  NodeState get initialState => InitState();

  @override
  Stream<NodeState> mapEventToState(NodeEvent event) async* {
    if (event is LoadNodes) {
      yield* _mapLoadContracts();
    } else if (event is SwitchNode) {
      yield NodeSwitchedState(event.index);
    }
  }

  Stream<NodeState> _mapLoadContracts() async* {
    yield LoadingState();
    try {
      List<MortgageInfoV2> mortgageList = await _userService.getMortgageListV2();
      yield LoadedState(mortgageList);
    } catch (_) {
      yield LoadFailState();
//      ExceptionProcess.process(_);
    }
  }
}
