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
  Future<bool> poiCollector(List<Media> imagePaths, String address, PoiCollector poiCollector) async {
    try {

      List imgList = List();
      for (var item in imagePaths) {
        String firstPath = item.path;
        final ByteData imageByte = await rootBundle.load(firstPath);
        imgList.add(imageByte);
        print('[add] _selectImages, firstPath:${firstPath}, imageByte:${imageByte.lengthInBytes}');
      }

      var params = {
        "poi": poiCollector.toJson(),
      };

      for (var i = 0; i < imgList.length; i += 1) {
        var index = i - 1;
        String key = "img_${index}";
         params[key] = imgList[i];
      }
      print('[position] poiCollector, params:${params}');

      var res = await HttpCore.instance.post("map-collector/poi/collector",
          params: params,
          options: RequestOptions(headers: {
            "Lang": "zh-Hans",
            "UUID": address
          }, contentType: "multipart/form-data"));
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


}
