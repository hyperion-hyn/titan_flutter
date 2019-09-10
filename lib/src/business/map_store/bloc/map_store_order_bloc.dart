import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:titan/src/business/map_store/map_store_network_repository.dart';
import 'package:titan/src/business/map_store/model/map_store_item.dart';
import 'package:titan/src/business/map_store/model/purchased_map_item.dart';
import 'package:titan/src/business/map_store/model/purchased_success_token.dart';
import 'package:titan/src/business/map_store/purchased_map_repository.dart';
import 'package:titan/src/global.dart';

import 'map_store_order_event.dart';
import 'map_store_order_state.dart';

class MapStoreOrderBloc extends Bloc<MapStoreOrderEvent, MapStoreOrderState> {
  MapStoreNetworkRepository _mapStoreNetworkRepository = MapStoreNetworkRepository();
  PurchasedMapRepository _purchasedMapRepository = PurchasedMapRepository();

  MapStoreOrderBloc() {}

  @override
  MapStoreOrderState get initialState => OrderIdleState();

  @override
  Stream<MapStoreOrderState> mapEventToState(MapStoreOrderEvent event) async* {
    if (event is PayEvent) {
      yield OrderFailState();
    }
    if (event is BuyFreeMapEvent) {
      yield* _buyFreeMap(event.mapStoreItem);
    }
    if (event is BuyAppleMapEvent) {
      yield* _buyAppleMap(event.mapStoreItem);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///
  /// 处理购买免费的商品
  Stream<MapStoreOrderState> _buyFreeMap(MapStoreItem mapStoreItem) async* {
    yield OrderPlacingState();
    try {
      var firstPolicy = mapStoreItem.policies[0];
      var policyId = "${mapStoreItem.id}.${firstPolicy.duration}";

      PurchasedSuccessToken successToken = await _mapStoreNetworkRepository.orderFreeMap(policyId);
      await _savePurchasedToken(mapStoreItem, successToken);
      yield OrderSuccessState();
    } catch (err) {
      logger.e(err);
      yield OrderFailState();
    }
  }

  ///
  /// 处理苹果购买商品
  Stream<MapStoreOrderState> _buyAppleMap(MapStoreItem mapStoreItem) async* {
    yield OrderPlacingState();
    try {
      var firstPolicy = mapStoreItem.policies[0];
      var policyId = "${mapStoreItem.id}.${firstPolicy.duration}";

      PurchasedSuccessToken successToken = await _mapStoreNetworkRepository.orderAppleFreeMap(policyId);
      await _savePurchasedToken(mapStoreItem, successToken);
      yield OrderSuccessState();
    } catch (err) {
      logger.e(err);
      yield OrderFailState();
    }
  }

  ///
  /// 保存购买的凭证信息
  ///
  Future _savePurchasedToken(MapStoreItem mapStoreItem, PurchasedSuccessToken purchasedSuccessToken) async {
    var authTileUrl = mapStoreItem.tileUrl + "?auth=" + purchasedSuccessToken.token;
    var purchasedMapItem = PurchasedMap(
        mapStoreItem.id,
        mapStoreItem.title,
        mapStoreItem.preview,
        authTileUrl,
        mapStoreItem.layerName,
        mapStoreItem.config.icon,
        mapStoreItem.config.color,
        mapStoreItem.config.minZoom,
        mapStoreItem.config.maxZoom,
        true);
    await _purchasedMapRepository.savePurchasedMapItem(purchasedMapItem);
  }
}
