import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/env.dart';
import 'package:titan/src/business/map_store/map_store_network_repository.dart';
import 'package:titan/src/business/map_store/model/map_store_item.dart';
import 'package:titan/src/business/map_store/model/purchased_map_item.dart';
import 'package:titan/src/business/map_store/model/purchased_success_token.dart';
import 'package:titan/src/business/map_store/purchased_map_repository.dart';
import 'package:titan/src/business/map_store/vo/map_price.dart';
import 'package:titan/src/business/map_store/vo/price_policy.dart';
import 'package:titan/src/domain/firebase.dart';
import 'package:titan/src/global.dart';
import 'package:url_launcher/url_launcher.dart';

import 'map_store_order_event.dart';
import 'map_store_order_state.dart';

class MapStoreOrderBloc extends Bloc<MapStoreOrderEvent, MapStoreOrderState> {
  BuildContext context;
  MapStoreNetworkRepository _mapStoreNetworkRepository = MapStoreNetworkRepository();
  PurchasedMapRepository _purchasedMapRepository = PurchasedMapRepository();
  StreamSubscription _checkPayStatusSubscription;

  MapStoreOrderBloc(this.context);

  @override
  MapStoreOrderState get initialState => IdleState();

  @override
  Stream<MapStoreOrderState> mapEventToState(MapStoreOrderEvent event) async* {
    if (event is PayEvent) {
      yield OrderFailState();
    } else if (event is BuyFreeMapEvent) {
      yield* _buyFreeMap(event.mapStoreItem);
    } else if (event is BuyAppleMapEvent) {
      yield* _buyAppleMap(event.mapStoreItem);
    } else if (event is ShowPayingMapPriceEvent) {
      yield* _showBuyingMapPrice(event.mapStoreItem);
    } else if (event is PurchaseEvent) {
      yield* _purchaseMap(event.mapStoreItem, event.mapPrice);
    } else if (event is CancelPurchaseEvent) {
      yield* _cancelPurchase();
    } else if (event is PurchaseSuccessEvent) {
      yield OrderSuccessState();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Stream<MapStoreOrderState> _cancelPurchase() async* {
    print("enter _cancelPurchase");
    if (_checkPayStatusSubscription != null) {
      print("execute cancel method");
      _checkPayStatusSubscription.cancel();
    }
  }

  ///支付
  Stream<MapStoreOrderState> _purchaseMap(MapStoreItem mapStoreItem, MapPrice mapPrice) async* {
    var selectedPricePolicy = mapPrice.policies.firstWhere((pricePolicyTemp) => pricePolicyTemp.selected);
    if (selectedPricePolicy == null) {
      yield OrderFailState();
      return;
    }

    if (Platform.isAndroid && env.channel == BuildChannel.OFFICIAL) {
      yield* _alipayPurchase(mapStoreItem, selectedPricePolicy);
    } else {
      yield* _inAppPurchase(mapPrice, selectedPricePolicy);
    }
  }

  /// 应用内支付
  Stream<MapStoreOrderState> _inAppPurchase(MapPrice mapPrice, PricePolicy selectedPolicy) async* {}

  ///阿里支付
  Stream<MapStoreOrderState> _alipayPurchase(MapStoreItem mapStoreItem, PricePolicy selectedPolicy) async* {
    yield OrderPlacingState();

    try {
      var alipayOrderResponse = await _mapStoreNetworkRepository.createAlipayOrder(selectedPolicy.id);
      String orderNo = alipayOrderResponse.orderNo;

      yield OrderPayingState();

      RegExp exp = new RegExp(r"https?://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]");

      RegExpMatch expMatch = exp.firstMatch(alipayOrderResponse.result);
      var alipayUrl = expMatch.group(0);

      //todo call url

      if (await canLaunch(alipayUrl)) {
        await launch(alipayUrl);
      } else {
        yield OrderFailState();
        print('Could not launch $alipayUrl');
      }
      yield* _checkAliayPurchaseState(mapStoreItem, orderNo);
    } catch (_) {
      logger.e(_);
      yield OrderFailState();
    }
  }

  Stream<MapStoreOrderState> _checkAliayPurchaseState(MapStoreItem mapStoreItem, String orderNo) async* {
    _checkPayStatusSubscription?.cancel();
    _checkPayStatusSubscription = Observable.periodic(Duration(milliseconds: 1000), (i) => i)
        .interval(Duration(milliseconds: 2000))
        .flatMap((timer) {
      return _mapStoreNetworkRepository.getOrderToken(orderNo).asStream();
    }).listen((purchasedSuccessToken) async {
      print("enter listen");
      _checkPayStatusSubscription?.cancel();
      _checkPayStatusSubscription = null;
      await _savePurchasedToken(mapStoreItem, purchasedSuccessToken);
      dispatch(PurchaseSuccessEvent());
      FireBaseLogic.of(context).analytics.logEvent(name: 'pay_success');
    }, onError: (err) => print(err));
  }

  ///
  ///处理价格对话框
  Stream<MapStoreOrderState> _showBuyingMapPrice(MapStoreItem mapStoreItem) async* {
    MapPrice mapPrice = _convertMapPriceFromMapStoreItem(mapStoreItem);

    yield ShowPayingMapPriceState(mapPrice);
  }

  /// 将从MapStoreItem 中抽取成MapPrice
  MapPrice _convertMapPriceFromMapStoreItem(MapStoreItem mapStoreItem) {
    var policies = mapStoreItem.policies;

    var pricePolicyList = List<PricePolicy>();

    var monthlyPayPrice = 0.0;

    //获取月付的价格，方便后续的计算
    for (var policyTemp in policies) {
      if (policyTemp.duration == 30) {
        monthlyPayPrice = policyTemp.price;
        break;
      }
    }

    for (var policyTemp in policies) {
      var duration = policyTemp.duration;

      var id = "${mapStoreItem.id}.$duration";
      var policyName = "";
      var policyUnit = "HKD";
      var policyDuration = "";
      var policyOldPrice = "";
      var policyPrice = policyTemp.price;

      if (duration == 30) {
        policyName = "One Month Valid";
        policyDuration = "/mo";
        var policyOldPriceNum = monthlyPayPrice == 0.0 ? policyPrice : monthlyPayPrice;
        policyOldPrice = "$policyUnit$policyOldPriceNum";
      } else if (duration == 365) {
        policyName = "One Year Valid";
        policyDuration = "/yr";
        var policyOldPriceNum = monthlyPayPrice == 0.0 ? policyPrice : monthlyPayPrice * 12;
        policyOldPrice = "$policyUnit$policyOldPriceNum";
      }
      var selected = false;

      var pricePolicy = PricePolicy(id, policyName, policyUnit, policyPrice, policyDuration, policyOldPrice, selected);

      pricePolicyList.add(pricePolicy);
    }
    pricePolicyList[0].selected = true;

    return MapPrice(mapId: mapStoreItem.id, policies: pricePolicyList);
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
