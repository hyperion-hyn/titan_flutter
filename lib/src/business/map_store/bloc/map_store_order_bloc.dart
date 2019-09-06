import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'map_store_order_event.dart';
import 'map_store_order_state.dart';

class MapStoreOrderBloc extends Bloc<MapStoreOrderEvent, MapStoreOrderState> {
  MapStoreOrderBloc() {}

  @override
  MapStoreOrderState get initialState => OrderIdleState();

  @override
  Stream<MapStoreOrderState> mapEventToState(MapStoreOrderEvent event) async* {
    if (event is PayEvent) {
      yield OrderFailState();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
