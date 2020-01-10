//import 'dart:html';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:image_pickers/Media.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/business/position/model/category_item.dart';
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
  Future<bool> postPoiCollector(List<Media> imagePaths, String address, PoiCollector poiCollector) async {
    try {

      List imgList = List();
      for (var item in imagePaths) {
        String firstPath = item.path;
//        final ByteData imageByte = await rootBundle.load(firstPath);
//        imgList.add(imageByte.buffer.asUint8List());
//        print('[add] _selectImages, firstPath:${firstPath}, imageByte:${imageByte.lengthInBytes}');
      }

      Map<String, dynamic> params = {
        "poi": poiCollector.toJson(),
      };

      print('[position] poiCollector, 1, params:${params}');

      for (var i = 0; i < imagePaths.length; i += 1) {
        var index = i + 1;
//        String key = "img${index}";
//         params[key] = imgList[i];
      }

      FormData formData = new FormData.fromMap(params);

      print('[position] poiCollector, 2, params:${params}, \naddress:${address}');
      var res = await HttpCore.instance.post("map-collector/poi/collector",
          data: formData,
          options: RequestOptions(headers: {
            "Lang": "zh-Hans",
            "UUID": address
          }, contentType: "multipart/form-data"
          )
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

}
