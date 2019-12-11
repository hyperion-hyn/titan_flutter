import 'package:titan/src/business/infomation/model/focus_response.dart';
import 'package:titan/src/business/infomation/model/news_detail.dart';
import 'package:titan/src/business/infomation/model/news_response.dart';

import 'news_http.dart';

class NewsApi {
  Future<List<NewsResponse>> getNewsList(String categories, String tags, int page) async {
    List dataList = await NewsHttpCore.instance.get(
      "wp-json/wp/v2/posts",
      params: {"page": page, "categories": categories, "tags": tags},
    ) as List;

    return dataList.map((json) => NewsResponse.fromJson(json)).toList();
  }

  Future<List<NewsResponse>> getOfficialNewsList(
      int page, String categories, String titanTag, String starRichTag) async {
    List dataList = await NewsHttpCore.instance.get(
      "wp-json/wp/v2/posts?page=$page&categories=1&tags[]=$titanTag&tags[]=$starRichTag",
    ) as List;

    return dataList.map((json) => NewsResponse.fromJson(json)).toList();
  }

  Future<NewsDetail> getNewsDetai(int id) async {
    var data = await NewsHttpCore.instance.get(
      "wp-json/wp/v2/posts/${id}",
    ) as Map;

    return NewsDetail.fromJson(data);
  }

  Future<List<FocusImage>> getFocusList() async {
    List dataList = await NewsHttpCore.instance.get(
      "wp-json/wp/v2/posts",
      params: {
        "categories": 18,
      },
    ) as List;

    return dataList.map((json) => FocusImage.fromJson(json["focus"])).toList();
  }
}
