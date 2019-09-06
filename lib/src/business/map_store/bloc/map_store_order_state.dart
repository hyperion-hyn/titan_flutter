import 'package:equatable/equatable.dart';
import 'package:titan/src/business/map_store/model/map_store_item.dart';

abstract class MapStoreOrderState extends Equatable {
  MapStoreOrderState([List props = const []]) : super(props);
}

class OrderIdleState extends MapStoreOrderState {}

class OrderPlacingState extends MapStoreOrderState {}

class OrderPayingState extends MapStoreOrderState {}

class OrderSuccessState extends MapStoreOrderState {}

class OrderFailState extends MapStoreOrderState {}
