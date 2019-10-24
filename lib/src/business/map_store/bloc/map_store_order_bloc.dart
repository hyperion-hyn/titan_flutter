import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/env.dart';
import 'package:titan/src/business/home/drawer/purchased_map/bloc/purchased_map_bloc.dart';
import 'package:titan/src/business/home/drawer/purchased_map/bloc/purchased_map_event.dart';
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
  StreamSubscription _checkAliPayStatusSubscription;
  StreamSubscription _checkGooglePayStatusSubscription;
  PurchasedMapBloc purchasedMapBloc;

  MapStoreOrderBloc(this.context, this.purchasedMapBloc);

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
      await _savePurchasedToken(event.mapStoreItem, event.purchasedSuccessToken);
      purchasedMapBloc.add(LoadPurchasedMapsEvent());
      yield OrderSuccessState();
    } else if (event is PurchaseFailEvent) {
      yield OrderFailState();
    }
  }

  @override
  void close() {
    super.close();
  }

  Stream<MapStoreOrderState> _cancelPurchase() async* {
    print("enter _cancelPurchase");
    if (_checkAliPayStatusSubscription != null) {
      print("execute cancel method");
      _checkAliPayStatusSubscription.cancel();
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
      yield* _inAppPurchase(mapStoreItem, selectedPricePolicy);
    }
  }

  /// 应用内支付
  Stream<MapStoreOrderState> _inAppPurchase(MapStoreItem mapStoreItem, PricePolicy selectedPolicy) async* {
    yield OrderPlacingState();
    StreamSubscription purchaseUpdatedStreamStreamSubscription;
    try {
      _handlePastPurchased();
      Set<String> _kIds = <String>[selectedPolicy.id].toSet();
      final ProductDetailsResponse response = await InAppPurchaseConnection.instance.queryProductDetails(_kIds);
      if (response.notFoundIDs.isNotEmpty) {
        print("notFoundIDs :${response.notFoundIDs}");
        yield OrderFailState();
        return;
      }
      List<ProductDetails> products = response.productDetails;
      final ProductDetails productDetails = products[0];
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
      InAppPurchaseConnection.instance.buyConsumable(purchaseParam: purchaseParam);

      purchaseUpdatedStreamStreamSubscription =
          InAppPurchaseConnection.instance.purchaseUpdatedStream.listen((List<PurchaseDetails> purchaseDetailsList) {
        print("enter purchaseDetailsList");
        purchaseUpdatedStreamStreamSubscription.cancel();
        purchaseUpdatedStreamStreamSubscription = null;
        _handlePurchaseUpdates(mapStoreItem, purchaseDetailsList);
      });
    } catch (err) {
      logger.e(err);
      yield OrderFailState();
    }
  }

  void _handlePurchaseUpdates(MapStoreItem mapStoreItem, List<PurchaseDetails> purchaseDetailsList) {
    if (purchaseDetailsList == null || purchaseDetailsList.isEmpty) {
      add(PurchaseFailEvent());
      return;
    }
    PurchaseDetails purchaseDetails = purchaseDetailsList[0];
    if (purchaseDetails.billingClientPurchase == null) {
      add(PurchaseFailEvent());
      return;
    }
    if (purchaseDetails.status == PurchaseStatus.error) {
      add(PurchaseFailEvent());
      return;
    }

    if (Platform.isIOS) {
      InAppPurchaseConnection.instance.completePurchase(purchaseDetails);
    }

    String itemId = purchaseDetails.billingClientPurchase.sku;
    String token = purchaseDetails.billingClientPurchase.purchaseToken;

    _checkGooglePurchaseState(mapStoreItem, itemId, token);
    return;
  }

  void _checkGooglePurchaseState(MapStoreItem mapStoreItem, String itemId, String token) {
    _checkGooglePayStatusSubscription?.cancel();
    _checkGooglePayStatusSubscription = Observable.periodic(Duration(milliseconds: 1000), (i) => i)
        .interval(Duration(milliseconds: 2000))
        .flatMap((timer) {
      return _mapStoreNetworkRepository.getGoogleOrderToken(itemId, token).asStream();
    }).listen((purchasedSuccessToken) async {
      print("enter listen");
      _checkGooglePayStatusSubscription?.cancel();
      _checkGooglePayStatusSubscription = null;
      add(PurchaseSuccessEvent(mapStoreItem, purchasedSuccessToken));
      FireBaseLogic.of(context).analytics.logEvent(name: 'pay_success');
    }, onError: (err) => print(err));
  }

  void _handlePastPurchased() async {
    final QueryPurchaseDetailsResponse response = await InAppPurchaseConnection.instance.queryPastPurchases();
    if (response.error != null) {
      print("get past error ${response.error}");
    }
    print("past purchaseds list : ${response.pastPurchases.toString()}");
    for (PurchaseDetails purchase in response.pastPurchases) {
      InAppPurchaseConnection.instance.consumePurchase(purchase);
    }
  }

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
    _checkAliPayStatusSubscription?.cancel();
    _checkAliPayStatusSubscription = Observable.periodic(Duration(milliseconds: 1000), (i) => i)
        .interval(Duration(milliseconds: 2000))
        .flatMap((timer) {
      return _mapStoreNetworkRepository.getOrderToken(orderNo).asStream();
    }).listen((purchasedSuccessToken) async {
      print("enter listen");
      _checkAliPayStatusSubscription?.cancel();
      _checkAliPayStatusSubscription = null;
      add(PurchaseSuccessEvent(mapStoreItem, purchasedSuccessToken));
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
      add(PurchaseSuccessEvent(mapStoreItem, successToken));
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
      add(PurchaseSuccessEvent(mapStoreItem, successToken));
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
