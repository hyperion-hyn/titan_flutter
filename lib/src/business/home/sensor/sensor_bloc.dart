import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import './bloc.dart';
import 'package:titan/src/plugins/sensor_type.dart';

class SensorBloc extends Bloc<SensorEvent, SensorState> {
  @override
  SensorState get initialState => InitialSensorState();

  @override
  Stream<SensorState> mapEventToState(
    SensorEvent event,
  ) async* {

    if(event is ValueChangeListenerEvent) {
      //print('[SensorBloc] --> mapEventToState');

      var values = event.values;
      yield ValueChangeListenerState(values);
    }
  }

}
