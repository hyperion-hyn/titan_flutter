import 'package:equatable/equatable.dart';
import 'package:titan/src/business/map_store/model/map_store_item.dart';
import 'package:titan/src/business/map_store/model/purchased_success_token.dart';
import 'package:titan/src/business/map_store/vo/map_price.dart';

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

class ShowPayingMapPriceEvent extends MapStoreOrderEvent {
  final MapStoreItem mapStoreItem;

  ShowPayingMapPriceEvent(this.mapStoreItem);
}

class PurchaseEvent extends MapStoreOrderEvent {
  final MapStoreItem mapStoreItem;
  final MapPrice mapPrice;

  PurchaseEvent(this.mapStoreItem, this.mapPrice);
}

class CancelPurchaseEvent extends MapStoreOrderEvent {}

class PurchaseSuccessEvent extends MapStoreOrderEvent {
  final MapStoreItem mapStoreItem;
  final PurchasedSuccessToken purchasedSuccessToken;

  PurchaseSuccessEvent(this.mapStoreItem, this.purchasedSuccessToken);
}

class PurchaseFailEvent extends MapStoreOrderEvent {}
