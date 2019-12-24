import 'package:equatable/equatable.dart';

abstract class SensorState extends Equatable {
  //const SensorState();
}

class InitialSensorState extends SensorState {
  @override
  List<Object> get props => [];
}

class ValueChangeListenerState extends SensorState {
  Map<dynamic, dynamic> values;

  ValueChangeListenerState(this.values);
}