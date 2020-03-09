import 'package:titan/src/basic/http/entity.dart';
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

  Future<NewsDetail> getNewsDetai(int id) async {
    var data = await NewsHttpCore.instance.get(
      "wp-json/wp/v2/posts/${id}",
    ) as Map;

    return NewsDetail.fromJson(data);
  }

  Future<List<FocusImage>> getFocusList(String category) async {
    List dataList = await NewsHttpCore.instance.get(
      "wp-json/wp/v2/posts",
      params: {
        "categories": category,
      },
    ) as List;

    return dataList.map((json) => FocusImage.fromJson(json["focus"])).toList();
  }

  Future<NewsDetail> getAnnouncement() async {
    var announcement = await NewsHttpCore.instance.getEntity(
        "wp-json/sr/news/last",EntityFactory<NewsDetail>((data) => NewsDetail.fromJson(data)));

    return announcement;
  }
}
