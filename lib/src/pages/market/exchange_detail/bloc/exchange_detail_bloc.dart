import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';

part 'exchange_detail_event.dart';
part 'exchange_detail_state.dart';

class ExchangeBloc extends Bloc<ExchangeDetailEvent, ExchangeDetailState> {
  @override
  ExchangeDetailState get initialState => ExchangeInitial();

  @override
  Stream<ExchangeDetailState> mapEventToState(
      ExchangeDetailEvent event,
  ) async* {
    // TODO: implement mapEventToState
  }
}
