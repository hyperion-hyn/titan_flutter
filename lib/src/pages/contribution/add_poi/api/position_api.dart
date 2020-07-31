import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_pickers/Media.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/pages/contribution/add_poi/model/category_item.dart';
import 'package:titan/src/pages/contribution/add_poi/model/confirm_poi_network_item.dart';
import 'package:titan/src/pages/contribution/add_poi/model/poi_collector.dart';
import 'package:titan/src/data/entity/poi/user_contribution_poi.dart';
import 'package:titan/src/pages/discover/dapp/ncov/model/ncov_poi_entity.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';

class PositionApi {
  Future<List<CategoryItem>> getCategoryList(String keyword, String address,
      {String lang = "zh-Hans", String countryCode = "CN"}) async {
    //print("[PositionApi] ,print start ");

    var data = await HttpCore.instance.getEntity("map-collector/poi/category/search",
        EntityFactory<List<CategoryItem>>((list) => (list as List).map((item) => CategoryItem.fromJson(item)).toList()),
        params: {"keyword": keyword},
        options: RequestOptions(headers: {
          "Lang": lang,
          "UUID": address,
          "Iso-3166-1": countryCode,
        }, contentType: "application/json"));

    return data;
  }

  ///collect poi
  Future<int> postPoiCollector(
      List<Media> imagePaths, String address, PoiCollector poiCollector, ProgressCallback onSendProgress,
      {String lang = "zh-Hans"}) async {
    try {
      Map<String, dynamic> params = {
        "poi": json.encode(poiCollector.toJson()),
      };

      //print('[PositionApi] poiCollector, 1, params:${params}');

      for (var i = 0; i < imagePaths.length; i += 1) {
        var index = i + 1;
        String key = "img$index";
        params[key] = MultipartFile.fromFileSync(imagePaths[i].path);
      }

      /*for (var i = 0; i < imagePaths.length; i += 1) {
        var filePath = await FlutterAbsolutePath.getAbsolutePath(imagePaths[i].path);
        var compressPath = await getCompressPath(filePath);
        var index = i + 1;
        String key = "img$index";
        params[key] = MultipartFile.fromFileSync(compressPath);
      }*/

      FormData formData = FormData.fromMap(params);

      //print('[PositionApi] poiCollector, 2, params:$params, \naddress:$address, \nformDataLength:${formData.length}');
      var res = await HttpCore.instance.post("map-collector/poi/collector",
          data: formData,
          options: RequestOptions(headers: {"Lang": lang, "UUID": address}, contentType: "multipart/form-data"),
          onSendProgress: onSendProgress);
      var responseEntity = ResponseEntity<String>.fromJson(res, factory: EntityFactory((json) => json));
      //print("[PositionApi] , poiCollector,  responseEntity:${responseEntity}");

      if (responseEntity.code == 0) {
        return 0;
      } else {
        return responseEntity.code;
      }
    } catch (_) {
      LogUtil.uploadException(_, 'poi upload');
      return -1;
    }
  }

  Future<int> postPoiV2Collector(List<Media> outImagePaths, List<Media> inImagePaths, String address,
      PoiCollector poiCollector, ProgressCallback onSendProgress,
      {String lang = "zh-Hans"}) async {
    try {
      Map<String, dynamic> params = {
        "poi": json.encode(poiCollector.toJson()),
      };

      //print('[PositionApi] poiCollector, 1, params:${params}');

      // out
      if (outImagePaths.isNotEmpty) {
        for (var i = 0; i < outImagePaths.length; i += 1) {
          var index = i + 1;
          String key = "img$index";
          params[key] = MultipartFile.fromFileSync(outImagePaths[i].path);
        }
      }

      // in
      if (inImagePaths.isNotEmpty) {
        for (var i = 0; i < inImagePaths.length; i += 1) {
          var index = i + 4;
          String key = "img$index";
          params[key] = MultipartFile.fromFileSync(inImagePaths[i].path);
        }
      }

      FormData formData = FormData.fromMap(params);

      //print('[PositionApi] poiCollector, 2, params:$params, \naddress:$address, \nformDataLength:${formData.length}');
      var res = await HttpCore.instance.post("map-collector/poi/v2/collector",
          data: formData,
          options: RequestOptions(headers: {"Lang": lang, "UUID": address}, contentType: "multipart/form-data"),
          onSendProgress: onSendProgress);
      var responseEntity = ResponseEntity<String>.fromJson(res, factory: EntityFactory((json) => json));
      //print("[PositionApi] , poiCollector,  responseEntity:${responseEntity.code}, msg:${responseEntity.msg}");

      if (responseEntity.code == 0) {
        return 0;
      } else {
        return responseEntity.code;
      }
    } catch (_) {
      LogUtil.uploadException(_, 'poi upload');
      return -1;
    }
  }

  Future<UserContributionPoi> getConfirmData(String address, double lon, double lat,
      {String lang = "zh-Hans", String id = ""}) async {
    var confirmPoiItem = await HttpCore.instance.getEntity("map-collector/poi/query/v1",
        EntityFactory<UserContributionPoi>((dataList) {
          print("[get] dataList:$dataList");
          //return UserContributionPoi.onlyId("-1");

          if ((dataList as List).length > 0) {
            return UserContributionPoi.fromJson(dataList[0]);
          } else {
            return UserContributionPoi.onlyId("-1");
          }
        }),
        params: id?.isEmpty ?? false
            ? {'lon': lon, 'lat': lat, 'language': lang}
            : {'lon': lon, 'lat': lat, 'language': lang, 'id': id},
        options: RequestOptions(headers: {
          "Lang": lang,
          "UUID": address,
          //"Iso-3166-1": "CN"
        }, contentType: "application/json"));

    return confirmPoiItem;
  }

  Future<List<UserContributionPoi>> getUserContributionPoiDetail(String pid, {String lang = "zh-Hans"}) async {
    var data = await HttpCore.instance.getEntity(
        "/map-collector/poi/detail/$pid",
        EntityFactory<List<UserContributionPoi>>(
                (list) => (list as List).map((item) => UserContributionPoi.fromJson(item)).toList()),
        options: RequestOptions(headers: {
          "Lang": lang,
        }, contentType: "application/json"));
    return data;
  }

  Future<bool> postConfirmPoiData(String address, int answer, UserContributionPoi confirmPoiItem,
      {String lang = "zh-Hans", List<Map<String, dynamic>> detail}) async {
    //print("[PositionApi] confirm result 1, detail:$detail");

    var poiNetItem = ConfirmPoiNetworkItem(
        confirmPoiItem.id,
        confirmPoiItem.location,
        Properties(confirmPoiItem.name, confirmPoiItem.address, confirmPoiItem.category, confirmPoiItem.ext,
            confirmPoiItem.state, confirmPoiItem.phone, confirmPoiItem.workTime));
    var poiStr = json.encode(poiNetItem);
    //print("[PositionApi] confirm result poi = $poiStr, detail:$detail");

    List<Map<String, dynamic>> newDetail = [];
    detail.forEach((element) {
      if (element.values.isNotEmpty) {
        newDetail.add(element);
      }
    });
    Map<String, dynamic> params = {};
    if (newDetail.isNotEmpty) {
      params = {
        "poi": poiStr,
        "answer": answer,
        "detail": newDetail,
      };
    } else {
      params = {
        "poi": poiStr,
        "answer": answer,
      };
    }

    FormData formData = FormData.fromMap(params);
    //print("[PositionApi] confirm result formData = $formData, params:$params ");

    var res = await HttpCore.instance.post("/map-collector/poi/confirm",
        data: formData,
        options: RequestOptions(headers: {
          "Lang": lang,
          "UUID": address,
        }, contentType: "application/x-www-form-urlencoded"));
    var responseEntity = ResponseEntity<bool>.fromJson(res, factory: EntityFactory((json) => json));

    return responseEntity != null;
    /*
    if (responseEntity != null) {
      return responseEntity.data;
    }
    return false;
    */
  }

  ///collect poi ncov
  Future<int> postPoiNcovCollector(
      List<Media> imagePaths, String address, NcovPoiEntity poiCollector, ProgressCallback onSendProgress,
      {String lang = "zh-Hans"}) async {
    try {
      Map<String, dynamic> params = {
        "poi": json.encode(poiCollector.toJson()),
      };

      //print('[PositionApi] postNcovCollector, 1, params:${params}');

      for (var i = 0; i < imagePaths.length; i += 1) {
        var index = i + 1;
        String key = "img$index";
        params[key] = MultipartFile.fromFileSync(imagePaths[i].path);
      }

      FormData formData = FormData.fromMap(params);

//      print(
//          '[PositionApi] postNcovCollector, 2, params:$params, \naddress:$address, \nformDataLength:${formData.length}');
      var res = await HttpCore.instance.post("map-collector/ncov/poi/collector",
          data: formData,
          options: RequestOptions(headers: {"Lang": lang, "UUID": address}, contentType: "multipart/form-data"),
          onSendProgress: onSendProgress);
      var responseEntity = ResponseEntity<String>.fromJson(res, factory: EntityFactory((json) => json));
      //print("[PositionApi] , postNcovCollector,  responseEntity:${responseEntity}");

      if (responseEntity.code == 0) {
        return 0;
      } else {
        return responseEntity.code;
      }
    } catch (_) {
      logger.e(_);
      return -1;
    }
  }

  Future<List<NcovPoiEntity>> mapGetNcovUserPoiData(String pid, {String lang = "zh-Hans"}) async {
    var data = await HttpCore.instance.getEntity(
        "/map-collector/ncov/poi/detail/$pid",
        EntityFactory<List<NcovPoiEntity>>(
                (list) => (list as List).map((item) => NcovPoiEntity.fromJson(item)).toList()),
        options: RequestOptions(headers: {
          "Lang": lang,
        }, contentType: "application/json"));
    return data;
  }

  Future<Map<String, dynamic>> getOpenCageData(String query, {String lang = "zh-Hans"}) async {
    var json = await HttpCore.instance.get('map-collector/opencagedata/query',
        params: {'query': query, 'pretty': 1, 'language': lang},
        options: RequestOptions(contentType: "application/json"));

    var data = json["data"];
    var results = data["results"];
    if (results is List) {
      var components = results.first["components"];
      //print('[PositionApi] openCageData, components:${components}');
      return components;
    } else {
      //print('[PositionApi] openCageData, not is list');
    }

    return json;
  }
 

  Future<dynamic> getConfirmV2Data(double lon, double lat, {String lang = "zh-Hans"}) async {
    //print("[PositionApi] getConfirmDataV2, address = $userEthAddress");
    return await HttpCore.instance.get("map-collector/poi/v2/query",
        params: {'lon': lon, 'lat': lat, 'language': lang},
        options: RequestOptions(headers: {
          "Lang": lang,
          "UUID": userEthAddress,
          //"Iso-3166-1": "CN"
        }, contentType: "application/json"));
  }

  Future<dynamic> postConfirmPoiV2Data(List<int> answers, UserContributionPois contributionPois,
      {String lang = "zh-Hans"}) async {
    List<Map<String, dynamic>> data = [];
    getEthAddress();

    for (var contributionPoi in contributionPois.pois) {
      var index = contributionPois.pois.indexOf(contributionPoi);
      var answer = answers[index];
      if (contributionPoi.id.isNotEmpty) {
        data.add({"poiID": contributionPoi.id, "answer": answer});
      }
    }

    Map<String, dynamic> params = {
      "coordinates": contributionPois.coordinates,
      "data": data,
    };

    //print("[PositionApi] postConfirmPoiDataV2, params = $params");

    return await HttpCore.instance.post("/map-collector/poi/v2/confirm",
        params: params,
        options: RequestOptions(headers: {
          "Lang": lang,
          "UUID": userEthAddress,
        }, contentType: "application/json"));
  }

// ✅： [position_api] --> postBindWallets, formData:{wallets: [{"address":"0x2b0a973b4a569Db234dcA5e4Af7628465Bef3A08","isMaster":true},{"address":"0x2d31F32E26b8C3E7418352DE57A6d5eC3507EaFd","isMaster":false}]}
// ❎  [position_api] --> postBindWallets, formData:{wallets: [{address: 0x2b0a973b4a569Db234dcA5e4Af7628465Bef3A08, isMaster: true}, {address: 0x2d31F32E26b8C3E7418352DE57A6d5eC3507EaFd, isMaster: false}]}
  Future<bool> postBindWallets({String lang = "zh-Hans"}) async {
    getEthAddress();

    List<Map<String, dynamic>> postData = [];
    if (userEthAddress.isNotEmpty) {
      postData.add({"address": userEthAddress, "isMaster": true});
    }

    var wallets = await WalletUtil.scanWallets();
    for (var wallet in wallets) {
      var walletAddress = wallet.getEthAccount().address;
      if (walletAddress.isNotEmpty) {
        postData.add({"address": walletAddress, "isMaster": false});
      }
    }

    var postDataStr = json.encode(postData);
    Map<String, dynamic> map = {"wallets": postDataStr};
    FormData formData = FormData.fromMap(map);
    //print("[position_api] --> postBindWallets, formData:$map");

    var res = await HttpCore.instance.post("/map-collector/wallet/bind",
        data: formData,
        options: RequestOptions(headers: {
          "Lang": lang,
          "UUID": userEthAddress,
        }, contentType: "multipart/form-data"));

    //print("[position_api] --> postBindWallets, res:$res");
    var responseEntity = ResponseEntity<String>.fromJson(res, factory: EntityFactory((json) => json));

    return responseEntity.code == 0;
  }

  Future getEthAddress() async {
    if (userEthAddress?.isEmpty??true) {
      var _wallet = WalletInheritedModel.of(Keys.homePageKey.currentContext).activatedWallet?.wallet;

      userEthAddress = _wallet.getEthAccount().address;
    }

    //isBindSuccess = await postBindWallets();
    //print("[API] 钱包绑定:${isBindSuccess}");
  }
}
