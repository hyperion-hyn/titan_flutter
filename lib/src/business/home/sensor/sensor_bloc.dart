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
      print('[SensorBloc] --> mapEventToState');

      yield ValueChangeListenerState(event.values);
    }
  }

  @override
  Stream<SensorState> transformEvents(Stream<SensorEvent> events, Stream<SensorState> Function(SensorEvent event) next) {
    // TODO: implement transformEvents
    print('[SensorBloc] --> transformEvents');

    return super.transformEvents(events, next);
//    return events.expand([next(1)]);
  }

}
