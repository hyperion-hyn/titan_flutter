import 'package:titan/src/basic/http/map_store_http.dart';
import 'package:titan/src/business/map_store/model/map_store_item.dart';

import 'model/purchased_success_token.dart';

class MapStoreApi {
  Future<List<MapStoreItem>> getAllMapItem(String channel, String language) async {
    var data = await MapStoreHttpCore.instance.get("search/${channel}", params: {"language": language}) as List;

    return data.map((item) {
      return MapStoreItem.fromJson(item);
    }).toList();
  }

  Future<PurchasedSuccessToken> orderFreeMap(String policyId) async {
    var token = await MapStoreHttpCore.instance.post("/token/free/${policyId}");

    return PurchasedSuccessToken.fromJson(token);
  }


//  http://10.10.1.115:3000/token/apple/{mapPolicy}

  Future<PurchasedSuccessToken> orderAppleFreeMap(String policyId) async {
    var token = await MapStoreHttpCore.instance.post("/token/apple/${policyId}");
    return PurchasedSuccessToken.fromJson(token);
  }




  Future<PurchasedSuccessToken> getGoogleOrderToken(String itemId, String token) async {
    String path = "/token/google/hmap";
    var getGoogleTokenRequest = {"item_id": itemId, "token": token};
    var map = await MapStoreHttpCore.instance.post(path, params: getGoogleTokenRequest);
    return PurchasedSuccessToken.fromJson(map);
  }



}
