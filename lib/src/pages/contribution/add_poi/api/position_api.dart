import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_pickers/Media.dart';
import 'package:path_provider/path_provider.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/pages/contribution/add_poi/model/category_item.dart';
import 'package:titan/src/pages/contribution/add_poi/model/confirm_poi_network_item.dart';
import 'package:titan/src/pages/contribution/add_poi/model/poi_collector.dart';
import 'package:titan/src/data/entity/poi/user_contribution_poi.dart';
import 'package:titan/src/pages/discover/dapp/ncov/model/ncov_poi_entity.dart';

class PositionApi {
  Future<List<CategoryItem>> getCategoryList(String keyword, String address,
      {String lang = "zh-Hans", String countryCode = "CN"}) async {
    print("[PositionApi] ,print start ");

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

      print('[PositionApi] poiCollector, 1, params:${params}');

      for (var i = 0; i < imagePaths.length; i += 1) {
        var filePath = await FlutterAbsolutePath.getAbsolutePath(imagePaths[i].path);
        var compressPath = await getCompressPath(filePath);
        var index = i + 1;
        String key = "img$index";
        params[key] = MultipartFile.fromFileSync(compressPath);
      }

      FormData formData = FormData.fromMap(params);

      print('[PositionApi] poiCollector, 2, params:$params, \naddress:$address, \nformDataLength:${formData.length}');
      var res = await HttpCore.instance.post("map-collector/poi/collector",
          data: formData,
          options: RequestOptions(headers: {"Lang": lang, "UUID": address}, contentType: "multipart/form-data"),
          onSendProgress: onSendProgress);
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

  Future<String> getCompressPath(String imagePath) async {
    ImageProperties properties = await FlutterNativeImage.getImageProperties(imagePath);
    File compressedFile = await FlutterNativeImage.compressImage(imagePath, quality: 90,
        targetWidth: 1000,
        targetHeight: (properties.height * 1000 / properties.width).round());
    return compressedFile.path;
  }

  Future<Map<String, dynamic>> getOpenCageData(String query, {String lang = "zh-Hans"}) async {
    var json = await HttpCore.instance.get('map-collector/opencagedata/query',
        params: {'query': query, 'pretty': 1, 'language': lang},
        options: RequestOptions(contentType: "application/json"));

    var data = json["data"];
    var results = data["results"];
    if (results is List) {
      var components = results.first["components"];
      print('[PositionApi] openCageData, components:${components}');
      return components;
    } else {
      print('[PositionApi] openCageData, not is list');
    }

    return json;
  }

  Future<UserContributionPoi> getConfirmData(String address, double lon, double lat, {String lang = "zh-Hans"}) async {
    var confirmPoiItem =
        await HttpCore.instance.getEntity("map-collector/poi/query/v1", EntityFactory<UserContributionPoi>((dataList) {
      if ((dataList as List).length > 0) {
        return UserContributionPoi.fromJson(dataList[0]);
      }
      return null;
    }),
            params: {'lon': lon, 'lat': lat, 'language': lang},
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
      {String lang = "zh-Hans"}) async {
    var poiNetItem = ConfirmPoiNetworkItem(
        confirmPoiItem.id,
        confirmPoiItem.location,
        Properties(confirmPoiItem.name, confirmPoiItem.address, confirmPoiItem.category, confirmPoiItem.ext,
            confirmPoiItem.state, confirmPoiItem.phone, confirmPoiItem.workTime));
    var poiStr = json.encode(poiNetItem);
    print("[PositionApi] confirm result poi = $poiStr");

    Map<String, dynamic> params = {
      "poi": poiStr,
      "answer": answer,
    };
    FormData formData = FormData.fromMap(params);

    var data = await HttpCore.instance.post("/map-collector/poi/confirm",
        data: formData,
        options: RequestOptions(headers: {
          "Lang": lang,
          "UUID": address,
        }, contentType: "application/json"));

    return data['data'];
  }

  ///collect poi ncov
  Future<int> postPoiNcovCollector(
      List<Media> imagePaths, String address, NcovPoiEntity poiCollector, ProgressCallback onSendProgress,
      {String lang = "zh-Hans"}) async {
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

      print(
          '[PositionApi] postNcovCollector, 2, params:$params, \naddress:$address, \nformDataLength:${formData.length}');
      var res = await HttpCore.instance.post("map-collector/ncov/poi/collector",
          data: formData,
          options: RequestOptions(headers: {"Lang": lang, "UUID": address}, contentType: "multipart/form-data"),
          onSendProgress: onSendProgress);
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
}
