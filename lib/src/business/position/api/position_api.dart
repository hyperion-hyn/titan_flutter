import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_pickers/Media.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/business/position/model/category_item.dart';
import 'package:titan/src/business/position/model/confirm_poi_item.dart';
import 'package:titan/src/business/position/model/poi_collector.dart';
import 'package:titan/src/global.dart';


class PositionApi {

  Future<List<CategoryItem>> getCategoryList(String keyword, String address) async {
    print("[PositionApi] ,print start ");

    var data = await HttpCore.instance.getEntity(
        "map-collector/poi/category/search",
        EntityFactory<List<CategoryItem>>((list) =>
            (list as List).map((item) => CategoryItem.fromJson(item)).toList()),
        params: {"keyword": keyword},
        options: RequestOptions(headers: {
          "Lang": "zh-Hans",
          "UUID": address,
          "Iso-3166-1": "CN"
        }, contentType: "application/json"));

    return data;
  }

  ///collect poi
  Future<bool> postPoiCollector(List<Media> imagePaths, String address, PoiCollector poiCollector, ProgressCallback onSendProgress) async {
    try {

      Map<String, dynamic> params = {
        "poi": json.encode(poiCollector.toJson()),
      };

      print('[position] poiCollector, 1, params:${params}');

      for (var i = 0; i < imagePaths.length; i += 1) {
        var index = i + 1;
        String key = "img$index";
         params[key] = MultipartFile.fromFile(imagePaths[i].path);
      }

      FormData formData = FormData.fromMap(params);

      print('[position] poiCollector, 2, params:$params, \naddress:$address');
      var res = await HttpCore.instance.post("map-collector/poi/collector",
          data: formData,
          options: RequestOptions(headers: {
            "Lang": "zh-Hans",
            "UUID": address
          }, contentType: "multipart/form-data"
          ),
        onSendProgress: onSendProgress
      );
      var responseEntity = ResponseEntity<String>.fromJson(res, factory: EntityFactory((json) => json));
      print("[PositionApi] , poiCollector,  responseEntity:${responseEntity}");

      if (responseEntity.code == 0) {
        return true;
      } else {
        return false;
      }
    } catch (_) {
      logger.e(_);
      return false;
    }
  }


  Future<Map<String, dynamic>> getOpenCageData(String query, String language) async {
    var json = await HttpCore.instance.get(
        'map-collector/opencagedata/query',
        params: {
          'query': query,
          'pretty': 1,
          'language': language
        },
        options: RequestOptions(contentType: "application/json")
    );

    //var responseEntity = ResponseEntity<String>.fromJson(res, factory: EntityFactory((json) => json));

    var data = json["data"];
    var results = data["results"];
    if (results is List) {
      var components = results.first["components"];
      print('[position] openCageData, components:${components}');
      return components;
    }
    else {
      print('[position] openCageData, not is list');
    }

    return json;
  }

  Future<List<ConfirmPoiItem>> getConfirmData(double lon,double lat, String language) async {
    var address = currentWalletVo.accountList[0].account.address;
    var data = await HttpCore.instance.getEntity(
        "map-collector/poi/query/v1",
        EntityFactory<List<ConfirmPoiItem>>((list) =>
            (list as List).map((item) => ConfirmPoiItem.fromJson(item)).toList()),
        params: {
          'lon': lon,
          'lat': lat,
          'language': language
        },
        options: RequestOptions(headers: {
          "Lang": "zh-Hans",
          "UUID": address,
          "Iso-3166-1": "CN"
        }, contentType: "application/json"));

    return data;

  }

  Future<List<ConfirmPoiItem>> mapGetConfirmData(String pid) async {
    var data = await HttpCore.instance.getEntity(
//        "/map-collector/poi/detail/$pid",
        "/map-collector/poi/detail/5e13f8caea7db700f4411406",
        EntityFactory<List<ConfirmPoiItem>>((list) =>
            (list as List).map((item) => ConfirmPoiItem.fromJson(item)).toList()),
//        params: {
//          'id': pid,
//        },
        options: RequestOptions(headers: {
          "Lang": "zh-Hans",
        }, contentType: "application/json"));

    return data;

  }

  Future<bool> postConfirmPoiData(int answer,ConfirmPoiItem confirmPoiItem) async {
    var address = currentWalletVo.accountList[0].account.address;
    var data = await HttpCore.instance.postEntity(
        "/map-collector/poi/confirm",
        EntityFactory<bool>((result) {
          return result;
        }
    ),
        params: {
          'answer': answer,
          'poi': confirmPoiItem.toJson(),
        },
        options: RequestOptions(headers: {
          "Lang": "zh-Hans",
          "UUID": address,
        }, contentType: "application/json"));

    return data;

  }

}
