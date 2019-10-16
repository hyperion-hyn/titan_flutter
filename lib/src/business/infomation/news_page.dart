import 'package:flutter/material.dart';
import 'package:titan/src/business/infomation/api/news_api.dart';
import 'package:titan/src/business/infomation/info_state.dart';
import 'package:titan/src/widget/load_data_widget.dart';
import 'package:titan/src/widget/smart_pull_refresh.dart';

class NewsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NewsState();
  }
}

class _NewsState extends InfoState<NewsPage> {
  static const int LAST_NEWS_TAG = 26;
  static const int OFFICIAL_ANNOUNCEMENT_TAG = 22;
  static const int TUTORIAL_TAG = 30;
  static const int VIDEO_TAG = 48;
  static const String CATEGORY = "1";
  static const int FIRST_PAGE = 1;

  List<InfoItemVo> _InfoItemVoList = [];
  int selectedTag = LAST_NEWS_TAG;
  NewsApi _newsApi = NewsApi();
  int currentPage = FIRST_PAGE;
  var isLoading = true;

  @override
  void initState() {
    super.initState();
    _getPowerList(CATEGORY, selectedTag.toString(), FIRST_PAGE);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Container(
              height: 48,
              child: Row(
                children: <Widget>[
                  _buildTag("最新资讯", LAST_NEWS_TAG),
                  _buildTag("官方公告", OFFICIAL_ANNOUNCEMENT_TAG),
                  _buildTag("教程", TUTORIAL_TAG),
                  _buildTag("视频", VIDEO_TAG),
                ],
              ),
            ),
          ),
          Expanded(
            child: LoadDataWidget(
              isLoading: isLoading,
              child: SmartPullRefresh(
                onRefresh: () {
                  _getPowerList(CATEGORY, selectedTag.toString(), FIRST_PAGE);
                },
                onLoading: () {
                  _getPowerList(CATEGORY, selectedTag.toString(), currentPage + 1);
                },
                child: ListView.separated(
                    itemBuilder: (context, index) {
                      return buildInfoItem(_InfoItemVoList[index]);
                    },
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                    itemCount: _InfoItemVoList.length),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, int value) {
    return super.buildTag(text, value, selectedTag, () async {
      if (selectedTag == value) {
        return;
      }
      selectedTag = value;
      currentPage = FIRST_PAGE;
      isLoading = true;
      _getPowerList(CATEGORY, selectedTag.toString(), currentPage);
      setState(() {});
    });
  }

  Future _getPowerList(String categories, String tags, int page) async {
    var newsResponseList = await _newsApi.getNewsList(categories, tags, page);

    isLoading = false;
    var newsVoList = newsResponseList.map((newsResponse) {
      return InfoItemVo(
          id: newsResponse.id,
          url: newsResponse.outlink,
          photoUrl: newsResponse.customCover,
          title: newsResponse.title,
          publisher: "",
          publishTime: newsResponse.date * 1000);
    }).toList();
    if (page == FIRST_PAGE) {
      _InfoItemVoList.clear();
      _InfoItemVoList.addAll(newsVoList);
    } else {
      if (newsVoList.length == 0) {
        return;
      }
      _InfoItemVoList.addAll(newsVoList);
    }
    currentPage = page;
    if (mounted) {
      setState(() {});
    }
  }
}
