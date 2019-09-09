import 'package:equatable/equatable.dart';
import 'package:titan/src/business/map_store/model/purchased_map_item.dart';

abstract class PurchasedMapEvent extends Equatable {
  PurchasedMapEvent([List props = const []]) : super(props);
}

class LoadPurchasedMapsEvent extends PurchasedMapEvent {}

class ShowPurchasedMapEvent extends PurchasedMapEvent {
  final PurchasedMap purchasedMap;

  ShowPurchasedMapEvent(this.purchasedMap);
}
