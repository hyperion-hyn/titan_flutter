import 'package:equatable/equatable.dart';
import 'package:titan/src/business/map_store/model/map_store_item.dart';


abstract class MapStoreState extends Equatable {
  MapStoreState([List props = const []]) : super(props);
}

class MapStoreLoading extends MapStoreState {}

class MapStoreLoaded extends MapStoreState {
  final List<MapStoreItem> mapStoreItems;

  MapStoreLoaded([this.mapStoreItems = const []]) : super([mapStoreItems]);
}

class MapStoreNotLoaded extends MapStoreState {}




