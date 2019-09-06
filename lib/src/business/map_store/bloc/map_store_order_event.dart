import 'package:equatable/equatable.dart';

abstract class MapStoreOrderEvent extends Equatable {
  MapStoreOrderEvent([List props = const []]) : super(props);
}

class CreateOrderEvent extends MapStoreOrderEvent {}

class PayEvent extends MapStoreOrderEvent {}


