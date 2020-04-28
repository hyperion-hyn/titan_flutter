import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class RootPageControlBloc extends Bloc<RootPageControlEvent, RootPageControlState> {
  @override
  RootPageControlState get initialState => InitialRootPageControlState();

  @override
  Stream<RootPageControlState> mapEventToState(RootPageControlEvent event) async* {
    if (event is SetRootPageEvent) {
      yield UpdateRootPageState(child: event.page);
    }
  }
}
