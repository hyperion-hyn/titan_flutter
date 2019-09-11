import 'package:equatable/equatable.dart';
import 'package:titan/src/business/map_store/model/map_store_item.dart';
import 'package:titan/src/business/map_store/vo/map_price.dart';

abstract class MapStoreOrderState extends Equatable {
  MapStoreOrderState([List props = const []]) : super(props);
}

class IdleState extends MapStoreOrderState {}

class ShowPayingMapPriceState extends MapStoreOrderState {
  final MapPrice mapPrice;

  ShowPayingMapPriceState(this.mapPrice);
}

class OrderPlacingState extends MapStoreOrderState {}

class OrderPayingState extends MapStoreOrderState {}

class OrderSuccessState extends MapStoreOrderState {}

class OrderFailState extends MapStoreOrderState {}
