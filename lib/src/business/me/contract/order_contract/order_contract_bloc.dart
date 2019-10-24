import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:titan/src/basic/bloc/submit_bloc/bloc.dart';
import 'package:titan/src/basic/http/http_exception.dart';
import 'package:titan/src/business/login/login_bus_event.dart';
import 'package:titan/src/business/me/contract/contract_bloc/bloc.dart';
import 'package:titan/src/business/me/contract/contract_bloc/contract_state.dart';
import 'package:titan/src/business/me/model/pay_order.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/utils/exception_process.dart';
import 'package:titan/src/utils/md5_util.dart';

import 'bloc.dart';
import 'order_contract_state.dart';

class OrderContractBloc extends Bloc<OrderContractEvent, OrderContractState> {
  UserService _userService;

  ContractBloc contractBloc;

  StreamSubscription todosSubscription;

  OrderContractBloc(this._userService, this.contractBloc) {
    todosSubscription = contractBloc.listen((contractState) {
      if (contractState is ContractSwitchedState) {
        add(ResetToInit());
      }
    });
  }

  @override
  OrderContractState get initialState => InitOrderContractState();

  @override
  Stream<OrderContractState> mapEventToState(OrderContractEvent event) async* {
    if (event is OrderFreeContract) {
      yield* _orderFreeContract(event);
    } else if (event is OrderContract) {
      yield* _orderContract(event);
    } else if (event is ResetToInit) {
      yield InitOrderContractState();
    }
  }

  Stream<OrderContractState> _orderContract(OrderContract event) async* {
    yield OrderingState();

    try {
      PayOrder _payOrder = await _userService.createOrder(contractId: event.contractId);

      yield OrderSuccessState(_payOrder);
    } on HttpResponseCodeNotSuccess catch (_) {
      print("errorCOde os :${_.code}");
      if (_.code == ERROR_OUT_OF_RANGE.code) {
        yield OrderOverRangeState();
      } else {
        yield OrderFailState();
        ExceptionProcess.process(_);
      }
    } catch (_) {
      yield OrderFailState();
      ExceptionProcess.process(_);
    }
  }

  Stream<OrderContractState> _orderFreeContract(OrderFreeContract event) async* {
    yield OrderingState();
    try {
      try {
        PayOrder _payOrder = await _userService.createFreeOrder(contractId: event.contractId);
        yield OrderFreeSuccessState(_payOrder);
      } on HttpResponseCodeNotSuccess catch (_) {
        print("errorCOde os :${_.code}");
        if (_.code == ERROR_OUT_OF_RANGE.code) {
          yield OrderOverRangeState();
        } else {
          yield OrderFailState();
          ExceptionProcess.process(_);
        }
      }
    } catch (_) {
      yield OrderFailState();
      ExceptionProcess.process(_);
    }
  }

  @override
  void close() {
    todosSubscription?.cancel();
    super.close();
  }
}
