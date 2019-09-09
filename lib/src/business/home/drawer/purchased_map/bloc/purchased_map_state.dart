import 'package:equatable/equatable.dart';
import 'package:titan/src/business/map_store/model/purchased_map_item.dart';


abstract class PurchasedMapState extends Equatable {
  PurchasedMapState([List props = const []]) : super(props);
}

class PurchasedMapLoading extends PurchasedMapState {}

class PurchasedMapLoaded extends PurchasedMapState {
  final List<PurchasedMap> purchasedMaps;

  PurchasedMapLoaded([this.purchasedMaps = const []]) : super([purchasedMaps]);
}

class PurchasedMapNotLoaded extends PurchasedMapState {}




