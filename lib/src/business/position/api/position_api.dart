import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_pickers/Media.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/business/discover/dapp/ncov/model/ncov_poi_entity.dart';
import 'package:titan/src/business/position/model/category_item.dart';
import 'package:titan/src/business/position/model/confirm_poi_item.dart';
import 'package:titan/src/business/position/model/confirm_poi_network_item.dart';
import 'package:titan/src/business/position/model/poi_collector.dart';
import 'package:titan/src/business/position/model/poi_data.dart';
import 'package:titan/src/global.dart';


class PositionApi {

  Future<List<CategoryItem>> getCategoryList(String keyword, String address,{String lang = "zh-Hans", String countryCode = "CN"}) async {
    print("[PositionApi] ,print start ");

    var data = await HttpCore.instance.getEntity(
        "map-collector/poi/category/search",
        EntityFactory<List<CategoryItem>>((list) =>
            (list as List).map((item) => CategoryItem.fromJson(item)).toList()),
        params: {"keyword": keyword},
        options: RequestOptions(headers: {
          "Lang": lang,
          "UUID": address,
          "Iso-3166-1": countryCode,
        }, contentType: "application/json"));

    return data;
  }

  ///collect poi
  Future<int> postPoiCollector(List<Media> imagePaths, String address, PoiCollector poiCollector, ProgressCallback onSendProgress,{String lang = "zh-Hans"}) async {
    try {

      Map<String, dynamic> params = {
        "poi": json.encode(poiCollector.toJson()),
      };

      print('[PositionApi] poiCollector, 1, params:${params}');

      for (var i = 0; i < imagePaths.length; i += 1) {
        var index = i + 1;
        String key = "img$index";
         params[key] = MultipartFile.fromFileSync(imagePaths[i].path);
      }

      FormData formData = FormData.fromMap(params);

      print('[PositionApi] poiCollector, 2, params:$params, \naddress:$address, \nformDataLength:${formData.length}');
      var res = await HttpCore.instance.post("map-collector/poi/collector",
          data: formData,
          options: RequestOptions(headers: {
            "Lang": lang,
            "UUID": address
          }, contentType: "multipart/form-data"
          ),
        onSendProgress: onSendProgress
      );
      var responseEntity = ResponseEntity<String>.fromJson(res, factory: EntityFactory((json) => json));
      print("[PositionApi] , poiCollector,  responseEntity:${responseEntity}");

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

  Future<Map<String, dynamic>> getOpenCageData(String query,{String lang = "zh-Hans"}) async {
    var json = await HttpCore.instance.get(
        'map-collector/opencagedata/query',
        params: {
          'query': query,
          'pretty': 1,
          'language': lang
        },
        options: RequestOptions(contentType: "application/json")
    );

    var data = json["data"];
    var results = data["results"];
    if (results is List) {
      var components = results.first["components"];
      print('[PositionApi] openCageData, components:${components}');
      return components;
    }
    else {
      print('[PositionApi] openCageData, not is list');
    }

    return json;
  }

  Future<ConfirmPoiItem> getConfirmData(double lon, double lat,{String lang = "zh-Hans"}) async {
    var address = currentWalletVo.accountList[0].account.address;
    var confirmPoiItem = await HttpCore.instance.getEntity(
        "map-collector/poi/query/v1",
        EntityFactory<ConfirmPoiItem>((dataList) {
          if((dataList as List).length > 0 ){
            return ConfirmPoiItem.fromJson(dataList[0]);
          }
          return null;
        }),
        params: {
          'lon': lon,
          'lat': lat,
          'language': lang
        },
        options: RequestOptions(headers: {
          "Lang": lang,
          "UUID": address,
          //"Iso-3166-1": "CN"
        }, contentType: "application/json"));

    return confirmPoiItem;
  }

  Future<List<ConfirmPoiItem>> mapGetConfirmData(String pid,{String lang = "zh-Hans"}) async {
    var data = await HttpCore.instance.getEntity(
        "/map-collector/poi/detail/$pid",
        EntityFactory<List<ConfirmPoiItem>>((list) =>
            (list as List).map((item) => ConfirmPoiItem.fromJson(item)).toList()),
        options: RequestOptions(headers: {
          "Lang": lang,
        }, contentType: "application/json"));
    return data;
  }

  Future<bool> postConfirmPoiData(int answer, ConfirmPoiItem confirmPoiItem,{String lang = "zh-Hans"}) async {

    var address = currentWalletVo.accountList[0].account.address;
    var poiNetItem = ConfirmPoiNetworkItem(
        confirmPoiItem.id,
        confirmPoiItem.location,
        Properties(
            confirmPoiItem.name,
            confirmPoiItem.address,
            confirmPoiItem.category,
            confirmPoiItem.ext,
            confirmPoiItem.state,
            confirmPoiItem.phone,
            confirmPoiItem.workTime
        )
    );
    var poiStr = json.encode(poiNetItem);
    print("[PositionApi] confirm result poi = $poiStr");

    Map<String, dynamic> params = {
      "poi": poiStr,
      "answer": answer,
    };
    FormData formData = FormData.fromMap(params);

    var data = await HttpCore.instance.post(
        "/map-collector/poi/confirm",
        data:formData,
        options: RequestOptions(headers: {
          "Lang": lang,
          "UUID": address,
        }, contentType: "application/json"));

    return data['data'];
  }

  ///collect poi ncov
  Future<int> postPoiNcovCollector(List<Media> imagePaths, String address, NcovPoiEntity poiCollector, ProgressCallback onSendProgress,{String lang = "zh-Hans"}) async {
    try {

      Map<String, dynamic> params = {
        "poi": json.encode(poiCollector.toJson()),
      };

      print('[PositionApi] postNcovCollector, 1, params:${params}');

      for (var i = 0; i < imagePaths.length; i += 1) {
        var index = i + 1;
        String key = "img$index";
        params[key] = MultipartFile.fromFileSync(imagePaths[i].path);
      }

      FormData formData = FormData.fromMap(params);

      print('[PositionApi] postNcovCollector, 2, params:$params, \naddress:$address, \nformDataLength:${formData.length}');
      var res = await HttpCore.instance.post("map-collector/ncov/poi/collector",
          data: formData,
          options: RequestOptions(headers: {
            "Lang": lang,
            "UUID": address
          }, contentType: "multipart/form-data"
          ),
          onSendProgress: onSendProgress
      );
      var responseEntity = ResponseEntity<String>.fromJson(res, factory: EntityFactory((json) => json));
      print("[PositionApi] , postNcovCollector,  responseEntity:${responseEntity}");

      if (responseEntity.code == 0) {
        return 0;
      } else {
        return responseEntity.code;
      }
    } catch (_) {
      logger.e(_);
      return -1;
    }

  Future<List<NcovPoiEntity>> mapGetNcovUserPoiData(String pid,{String lang = "zh-Hans"}) async {
    var data = await HttpCore.instance.getEntity(
        "/map-collector/ncov/poi/detail/$pid",
        EntityFactory<List<NcovPoiEntity>>((list) =>
            (list as List).map((item) => NcovPoiEntity.fromJson(item)).toList()),
        options: RequestOptions(headers: {
          "Lang": lang,
        }, contentType: "application/json"));
    return data;
  }

}
