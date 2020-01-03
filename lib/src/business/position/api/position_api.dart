import 'package:dio/dio.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/business/position/model/category_item.dart';

class PositionApi {
  Future<List<CategoryItem>> getCategoryList(String keyword) async {
    print("[PositionApi] ,print start ");

    var data = await HttpCore.instance.getEntity(
        "map-collector/poi/category/search",
        EntityFactory<List<CategoryItem>>((list) =>
            (list as List).map((item) => CategoryItem.fromJson(item)).toList()),
        params: {"keyword": keyword},
        options: RequestOptions(headers: {
          "Lang": "zh-Hans",
          "UUID": "5e05c175cf27d401197904b6",
          "Iso-3166-1": "CN"
        }, contentType: "application/json"));

    return data;
  }
}
