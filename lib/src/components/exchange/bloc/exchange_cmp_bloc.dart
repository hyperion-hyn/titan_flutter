import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:titan/src/components/exchange/exchange_component.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/pages/market/model/exchange_account.dart';
import './bloc.dart';

class ExchangeCmpBloc extends Bloc<ExchangeCmpEvent, ExchangeCmpState> {
  @override
  ExchangeCmpState get initialState => InitialExchangeCmpState();
  ExchangeApi _exchangeApi = ExchangeApi();

  @override
  Stream<ExchangeCmpState> mapEventToState(
    ExchangeCmpEvent event,
  ) async* {
    // TODO: Add Logic
    if (event is LoginEvent) {
      yield LoginState(event.wallet, event.password, event.address);
    } else if (event is LoginSuccessEvent) {
      yield LoginSuccessState();
    } else if (event is LoginSuccessEvent) {
      yield LoginFailState();
    } else if (event is SetShowBalancesEvent) {
      yield SetShowBalancesState(event.isShow);
    } else if (event is UpdateExchangeAccountEvent) {
      yield UpdateExchangeAccountState(event.account);
    } else if (event is ClearExchangeAccountEvent) {
      yield ClearExchangeAccountState();
    } else if (event is UpdateAssetsEvent) {
      yield UpdateAssetsState();
    }
  }
}
