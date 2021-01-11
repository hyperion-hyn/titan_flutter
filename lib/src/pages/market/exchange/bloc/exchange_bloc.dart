import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class ExchangeBloc extends Bloc<ExchangeEvent, ExchangeState> {
  @override
  ExchangeState get initialState => InitialExchangeState();

  @override
  Stream<ExchangeState> mapEventToState(
    ExchangeEvent event,
  ) async* {
    if (event is SwitchToAuthEvent) {
      yield SwitchToAuthState();
    } else if (event is SwitchToContentEvent) {
      yield SwitchToContentState();
    }
  }
}
