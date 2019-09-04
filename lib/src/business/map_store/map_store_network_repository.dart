import 'package:titan/src/business/map_store/map_store_api.dart';

import 'model/map_store_item.dart';
import 'model/purchased_success_token.dart';

class MapStoreNetworkRepository {
  MapStoreApi _mapStoreApi = MapStoreApi();

  Future<List<MapStoreItem>> getAllMapItem(String channel, String language) async {
    return await _mapStoreApi.getAllMapItem(channel, language);
  }

  Future<PurchasedSuccessToken> orderFreeMap(String policyId) async {
    return await _mapStoreApi.orderFreeMap(policyId);
  }
}
