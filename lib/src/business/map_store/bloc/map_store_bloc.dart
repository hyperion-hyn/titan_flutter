import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';
import 'package:titan/env.dart';
import 'package:titan/src/business/map_store/bloc/map_store_event.dart';
import 'package:titan/src/business/map_store/bloc/map_store_state.dart';
import 'package:titan/src/business/map_store/map_store_network_repository.dart';
import 'package:titan/src/business/map_store/model/map_store_item.dart';
import 'package:titan/src/business/map_store/model/purchased_map_item.dart';
import 'package:titan/src/business/map_store/purchased_map_repository.dart';
import 'package:titan/src/global.dart';

class MapStoreBloc extends Bloc<MapStoreEvent, MapStoreState> {
  final MapStoreNetworkRepository mapStoreNetworkRepository;
  final PurchasedMapRepository _purchasedMapRepository = PurchasedMapRepository();
  final BuildContext context;

  MapStoreBloc({@required this.context, @required this.mapStoreNetworkRepository});

  @override
  MapStoreState get initialState => MapStoreNotLoaded();

  @override
  Stream<MapStoreState> mapEventToState(MapStoreEvent event) async* {
    if (event is LoadMapStoreItemsEvent) {
      yield* _loadedMapStoreItemState(event.channel, event.language);
    }
  }

  Stream<MapStoreState> _loadedMapStoreItemState(String channel, String language) async* {
//    var channel = "";
    var language = Localizations.localeOf(context).languageCode;
    switch (env.channel) {
      case BuildChannel.OFFICIAL:
        {
          channel = "official";
          break;
        }
      case BuildChannel.STORE:
        {
          channel = "google";
          break;
        }

      default:
        {
          channel = "google";
          break;
        }
    }

    try {
      final mapStoreItems = await mapStoreNetworkRepository.getAllMapItem(channel, language);
      await modifyMapStoreItemPrice(mapStoreItems);
      yield MapStoreLoaded(mapStoreItems);
    } catch (_) {
      logger.e(_);
      yield MapStoreNotLoaded();
    }
  }

  Future modifyMapStoreItemPrice(List<MapStoreItem> mapStoreItems) async {
    List<PurchasedMap> purchasedMapList = await _purchasedMapRepository.getPurchasedMapItems();

    List<String> purchasedMapIdList = purchasedMapList.map((purchasedMap) => purchasedMap.id).toList();

    for (MapStoreItem mapStoreItem in mapStoreItems) {
      if (Platform.isIOS) {
        _buildAppleFreeMapStoreItem(mapStoreItem, purchasedMapIdList);
      } else {
        _buildCommonMapStoreItem(mapStoreItem, purchasedMapIdList);
      }
    }
  }

  void _buildAppleFreeMapStoreItem(MapStoreItem mapStoreItem, List<String> purchasedMapIdList) {
    mapStoreItem.showPrice = "免费";
    mapStoreItem.isFree = true;
    if (purchasedMapIdList.contains(mapStoreItem.id)) {
      mapStoreItem.isPurchased = true;
    }
  }

  void _buildCommonMapStoreItem(MapStoreItem mapStoreItem, List<String> purchasedMapIdList) {
    var policys = mapStoreItem.policies;
    if (policys.length == 1) {
      var policy = policys[0];
      if (policy.price == 0.0) {
        mapStoreItem.showPrice = "免费";
        mapStoreItem.isFree = true;
      } else if (policy.duration == 30) {
        mapStoreItem.showPrice = sprintf("HKD %.2f", [policy.price]);
      } else {
        mapStoreItem.showPrice = sprintf("HKD %.2f", [policy.price / 12]);
      }
    } else {
      for (var policy in policys) {
        if (policy.duration == 365) {
          mapStoreItem.showPrice = sprintf("HKD %.2f", [policy.price / 12]);
          break;
        }
      }
    }
    if (purchasedMapIdList.contains(mapStoreItem.id)) {
      mapStoreItem.isPurchased = true;
    }
  }
}
