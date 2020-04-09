import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:titan/src/basic/http/http_exception.dart';
import 'package:titan/src/pages/me/node_mortgage/node_bloc/bloc.dart';
import 'package:titan/src/pages/me/service/user_service.dart';
import 'package:titan/src/utils/exception_process.dart';

import 'bloc.dart';
import 'snap_up_state.dart';

class SnapUpBloc extends Bloc<SnapUpEvent, SnapUpState> {
  UserService _userService;

  NodeBloc nodeBloc;

  StreamSubscription todosSubscription;

  SnapUpBloc(this._userService, this.nodeBloc) {
    todosSubscription = nodeBloc.listen((nodeState) {
      if (nodeState is NodeSwitchedState) {
        add(ResetToInit());
      }
    });
  }

  @override
  SnapUpState get initialState => InitSnapUpNodeState();

  @override
  Stream<SnapUpState> mapEventToState(SnapUpEvent event) async* {
    if (event is SnapUpNode) {
      yield* _snapUpNode(event);
    } else if (event is ResetToInit) {
      yield InitSnapUpNodeState();
    }
  }

  Stream<SnapUpState> _snapUpNode(SnapUpNode event) async* {
    yield SnapUpIngState();

    try {
      var _mortgageList = await _userService.getMortgageListV2();

      var selectedContract = _mortgageList[event.index];
      if (selectedContract.snapUpStocks <= 0) {
        yield SnapUpOverRangeState();
        return;
      }

      yield SnapSuccessState();
    } on HttpResponseCodeNotSuccess catch (_) {
      print("errorCOde os :${_.code}");
      if (_.code == ERROR_OUT_OF_RANGE.code) {
        yield SnapUpOverRangeState();
      } else {
        yield SnapUpFailState();
        ExceptionProcess.process(_);
      }
    } catch (_) {
      yield SnapUpFailState();
      ExceptionProcess.process(_);
    }
  }

  @override
  Future<void> close() {
    todosSubscription?.cancel();
    return super.close();
  }
}
