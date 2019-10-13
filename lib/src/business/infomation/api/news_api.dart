import 'package:dio/dio.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/business/infomation/model/news_detail.dart';
import 'package:titan/src/business/infomation/model/news_response.dart';
import 'package:titan/src/business/me/model/page_response.dart';

import 'news_http.dart';

class NewsApi {
  ///获取算力列表
  Future<List<NewsResponse>> getNewsList(String categories, String tags, int page) async {
    List dataList = await NewsHttpCore.instance.get(
      "wp-json/wp/v2/posts",
      params: {"page": page, "categories": categories, "tags": tags},
    ) as List;

    return dataList.map((json) => NewsResponse.fromJson(json)).toList();
  }

  Future<NewsDetail> getNewsDetai(int id) async {
    var data = await NewsHttpCore.instance.get(
      "wp-json/wp/v2/posts/${id}",
    ) as Map;

    return NewsDetail.fromJson(data);
  }
}
