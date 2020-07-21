import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class ExchangeCmpBloc extends Bloc<ExchangeCmpEvent, ExchangeCmpState> {
  @override
  ExchangeCmpState get initialState => InitialExchangeCmpState();

  @override
  Stream<ExchangeCmpState> mapEventToState(
    ExchangeCmpEvent event,
  ) async* {
    // TODO: Add Logic
    if (event is SetShowBalancesEvent) {
      yield SetShowBalancesState(event.isShow);
    } else if (event is UpdateExchangeAccountEvent) {
      yield UpdateExchangeAccountState(event.account);
    }
  }
}
