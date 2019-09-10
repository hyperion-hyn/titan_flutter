import 'package:equatable/equatable.dart';
import 'package:titan/src/business/map_store/model/map_store_item.dart';

abstract class MapStoreOrderEvent extends Equatable {
  MapStoreOrderEvent([List props = const []]) : super(props);
}

class CreateOrderEvent extends MapStoreOrderEvent {}

class PayEvent extends MapStoreOrderEvent {}

class BuyFreeMapEvent extends MapStoreOrderEvent {
  final MapStoreItem mapStoreItem;

  BuyFreeMapEvent(this.mapStoreItem);
}

class BuyAppleMapEvent extends MapStoreOrderEvent {
  final MapStoreItem mapStoreItem;

  BuyAppleMapEvent(this.mapStoreItem);
}

class BuyPayingMapEvent extends MapStoreOrderEvent {
  final MapStoreItem mapStoreItem;

  BuyPayingMapEvent(this.mapStoreItem);
}
