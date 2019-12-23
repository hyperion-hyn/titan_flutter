import 'package:equatable/equatable.dart';

abstract class SensorEvent extends Equatable {

}

class ValueChangeListenerEvent extends SensorEvent {
  final Map<dynamic, dynamic> values;

  ValueChangeListenerEvent(this.values);

}