import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:titan/src/business/infomation/api/news_api.dart';
import 'package:titan/src/business/infomation/info_state.dart';
import 'package:titan/src/business/load_data_container/bloc/bloc.dart';
import 'package:titan/src/business/load_data_container/load_data_container.dart';

import '../../global.dart';

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
  NewsApi _newsApi = NewsApi();

  int selectedTag; // = LAST_NEWS_TAG;
  int currentPage; // = FIRST_PAGE;

//  var isLoading = true;

  LoadDataBloc loadDataBloc = LoadDataBloc();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      activeTag(LAST_NEWS_TAG);
    });
  }

  @override
  void dispose() {
    loadDataBloc.close();
    super.dispose();
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
            child: LoadDataContainer(
              bloc: loadDataBloc,
              onLoadData: () async {
                try {
                  await _loadNewsData(FIRST_PAGE);

                  if (_InfoItemVoList.length == 0) {
                    loadDataBloc.add(LoadEmptyEvent());
                  } else {
                    loadDataBloc.add(RefreshSuccessEvent());
                  }
                } catch (e) {
                  logger.e(e);
                  loadDataBloc.add(LoadFailEvent());
                }
              },
              onRefresh: () async {
                try {
                 await  _loadNewsData(FIRST_PAGE);

                  if (_InfoItemVoList.length == 0) {
                    loadDataBloc.add(LoadEmptyEvent());
                  } else {
                    loadDataBloc.add(RefreshSuccessEvent());
                  }
                } catch (e) {
                  logger.e(e);
                  loadDataBloc.add(RefreshFailEvent());
                }
              },
              onLoadingMore: () async {
                try {
                  int lastSize = _InfoItemVoList.length;

                  await _loadNewsData(currentPage + 1);

                  if (_InfoItemVoList.length == lastSize) {
                    loadDataBloc.add(LoadMoreEmptyEvent());
                  } else {
                    loadDataBloc.add(LoadingMoreSuccessEvent());
                  }
                } catch (e) {
                  logger.e(e);
                  //hack for wordpress rest_post_invalid_page_number
                  if (e is DioError && e.message == 'Http status error [400]') {
                    loadDataBloc.add(LoadMoreEmptyEvent());
                  } else {
                    loadDataBloc.add(LoadMoreFailEvent());
                  }
                }
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
        ],
      ),
    );
  }

  Widget _buildTag(String text, int value) {
    return super.buildTag(text, value, selectedTag == value, activeTag);
  }

  void activeTag(int tagId) {
    if (selectedTag == tagId) {
      return;
    }
//      isLoading = true;
    setState(() {
      selectedTag = tagId;
      currentPage = FIRST_PAGE;
    });
    loadDataBloc.add(LoadingEvent());
  }

  Future _loadNewsData(int page) async {
    if (selectedTag == OFFICIAL_ANNOUNCEMENT_TAG) {
      await _getOfficialNewsList(page);
    } else {
      await _getNewsList(CATEGORY, selectedTag.toString(), page);
    }
  }

  Future _getNewsList(String categories, String tags, int page) async {
    var newsResponseList = await _newsApi.getNewsList(categories, tags, page);

//    isLoading = false;
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

  Future _getOfficialNewsList(int page) async {
    var newsResponseList = await _newsApi.getOfficialNewsList(page);

//    isLoading = false;
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
