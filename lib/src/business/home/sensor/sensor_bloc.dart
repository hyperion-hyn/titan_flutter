import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class SensorBloc extends Bloc<SensorEvent, SensorState> {
  @override
  SensorState get initialState => InitialSensorState();

  @override
  Stream<SensorState> mapEventToState(
    SensorEvent event,
  ) async* {

    if(event is ValueChangeListenerEvent) {
      //print('[SensorBloc] --> mapEventToState');

      yield ValueChangeListenerState(event.values);
    }
  }

}
