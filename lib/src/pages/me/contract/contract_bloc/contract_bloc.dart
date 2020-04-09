import 'package:titan/src/basic/bloc/submit_bloc/bloc.dart';
import 'package:titan/src/pages/me/model/contract_info_v2.dart';
import 'package:titan/src/pages/me/service/user_service.dart';
import 'package:titan/src/utils/exception_process.dart';

import 'package:bloc/bloc.dart';
import 'bloc.dart';
import 'contract_state.dart';

class ContractBloc extends Bloc<ContractEvent, ContractState> {
  UserService _userService;

  ContractBloc(this._userService);

  @override
  ContractState get initialState => InitState();

  @override
  Stream<ContractState> mapEventToState(ContractEvent event) async* {
    if (event is LoadContracts) {
      yield* _mapLoadContracts();
    } else if (event is SwtichContract) {
      yield ContractSwitchedState(event.index);
    }
  }

  Stream<ContractState> _mapLoadContracts() async* {
    yield LoadingState();
    try {
      List<ContractInfoV2> contraceList = await _userService.getContractListV2();
      yield LoadedState(contraceList);
    } catch (_) {
      yield LoadFailState();
      ExceptionProcess.process(_);
    }
  }
}
