import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class PositionBloc extends Bloc<PositionEvent, PositionState> {
  @override
  PositionState get initialState => InitialPositionState();

  @override
  Stream<PositionState> mapEventToState(
    PositionEvent event,
  ) async* {
    if(event is AddPositionEvent){
      yield AddPositionState();
    }
  }
}
