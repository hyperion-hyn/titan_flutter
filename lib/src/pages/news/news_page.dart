import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';

import '../../global.dart';
import 'api/news_api.dart';
import 'info_state.dart';
import 'news_tag_utils.dart';

class NewsPage extends StatefulWidget {
  @override
  NewsState createState() => NewsState();
}

//class NewsState extends State<NewsPage> {
//  static const int LAST_NEWS_TAG = 26;
//  static const int OFFICIAL_ANNOUNCEMENT_TAG = 22;
//  static const int TUTORIAL_TAG = 30;
//  static const int VIDEO_TAG = 48;
//
//  static const String CATEGORY = "1";
//
//  static const int FIRST_PAGE = 1;
//
//  @override
//  Widget build(BuildContext context) {
//    return Center(
//      child: Text('this is news page'),
//    );
//  }
//}

class NewsState extends InfoState<NewsPage> with AutomaticKeepAliveClientMixin{
  static const int LAST_NEWS_TAG = 26;
  static const int OFFICIAL_ANNOUNCEMENT_TAG = 22;
  static const int TUTORIAL_TAG = 30;
  static const int VIDEO_TAG = 48;

  static const String CATEGORY = "1";

  static const int FIRST_PAGE = 1;

  List<InfoItemVo> _InfoItemVoList = [];
  Map<int, List<InfoItemVo>> _mapInfoItemVoList = Map();
  Map<int, int> _mapPageVoList = Map();
  Map<int, bool> _mapPageCompleteVoList = Map();
  NewsApi _newsApi = NewsApi();

  int selectedTag; // = LAST_NEWS_TAG;
  int currentPage; // = FIRST_PAGE;

//  var isLoading = true;

  LoadDataBloc loadDataBloc = LoadDataBloc();

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) async{
//      activeTag(LAST_NEWS_TAG);
    print("news init");
      selectedTag = LAST_NEWS_TAG;
      _mapPageVoList = {LAST_NEWS_TAG: FIRST_PAGE,OFFICIAL_ANNOUNCEMENT_TAG: FIRST_PAGE
        ,TUTORIAL_TAG: FIRST_PAGE,VIDEO_TAG: FIRST_PAGE};
      _mapPageCompleteVoList = {LAST_NEWS_TAG: false,OFFICIAL_ANNOUNCEMENT_TAG: false
        ,TUTORIAL_TAG: false,VIDEO_TAG: false};
      currentPage = FIRST_PAGE;

      loadDataBloc.add(LoadingEvent());
    });
  }

  @override
  void dispose() {
    loadDataBloc.close();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 48,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      _buildTag(S.of(context).latest_news, LAST_NEWS_TAG),
                      _buildTag(S.of(context).official_announcement,
                          OFFICIAL_ANNOUNCEMENT_TAG,
                          isUpdate: Application.isUpdateAnnounce),
                      _buildTag(S.of(context).information_guide, TUTORIAL_TAG),
                      _buildTag(S.of(context).information_video, VIDEO_TAG),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: LoadDataContainer(
              bloc: loadDataBloc,
              onLoadData: () async {
                try {
                  await loadOrRefreshData();
                } catch (e) {
                  logger.e(e);
                  loadDataBloc.add(LoadFailEvent());
                }
              },
              onRefresh: () async {
                try {
                  await loadOrRefreshData();
                } catch (e) {
                  logger.e(e);
                  loadDataBloc.add(RefreshFailEvent());
                }
              },
              onLoadingMore: () async {
                try {
                  var loadMoreList = await _getPowerList(CATEGORY, selectedTag, _mapPageVoList[selectedTag] + 1);
                  if (loadMoreList.length == 0) {
                    loadDataBloc.add(LoadMoreEmptyEvent());
                  } else {
                    var _tempInfoItemVoList = _mapInfoItemVoList[selectedTag];
                    _tempInfoItemVoList.addAll(loadMoreList);
                    _mapInfoItemVoList[selectedTag] = _tempInfoItemVoList;
                    _InfoItemVoList = _mapInfoItemVoList[selectedTag];
                    loadDataBloc.add(LoadingMoreSuccessEvent());

                    setState(() {});
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
              onLoadingMoreEmpty:() {
                _mapPageCompleteVoList[selectedTag] = true;
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

  Future loadOrRefreshData() async{
    _mapPageCompleteVoList = {LAST_NEWS_TAG: false,OFFICIAL_ANNOUNCEMENT_TAG: false
      ,TUTORIAL_TAG: false,VIDEO_TAG: false};
    var newsList = await _getPowerList(CATEGORY, LAST_NEWS_TAG, FIRST_PAGE);
    var announcementList = await _getPowerList(CATEGORY, OFFICIAL_ANNOUNCEMENT_TAG, FIRST_PAGE);
    var tutorialList = await _getPowerList(CATEGORY, TUTORIAL_TAG, FIRST_PAGE);
    var videoList = await _getPowerList(CATEGORY, VIDEO_TAG, FIRST_PAGE);
    _mapInfoItemVoList = {LAST_NEWS_TAG: newsList,OFFICIAL_ANNOUNCEMENT_TAG: announcementList
      ,TUTORIAL_TAG: tutorialList,VIDEO_TAG: videoList};

    _InfoItemVoList = _mapInfoItemVoList[selectedTag];
    if (_InfoItemVoList.length == 0) {
      loadDataBloc.add(LoadEmptyEvent());
    } else {
      loadDataBloc.add(RefreshSuccessEvent());
    }

    setState(() {});
  }

  Widget _buildTag(String text, int value, {bool isUpdate = false}) {
    return super.buildTag(text, value, selectedTag == value, activeTag,
        isUpdate: isUpdate);
  }

  void activeTag(int tagId) {
    if (_mapInfoItemVoList.length == 0 || selectedTag == tagId) {
      return;
    }

    setState(() {

      var isUpdate = tagId == OFFICIAL_ANNOUNCEMENT_TAG && Application.isUpdateAnnounce;

      if (isUpdate) {
        Application.isUpdateAnnounce = false;
        Application.eventBus.fire(ClearBadgeEvent());
      }

      selectedTag = tagId;
      currentPage = _mapPageVoList[selectedTag];
      if(_mapInfoItemVoList.containsKey(selectedTag)) {
        _InfoItemVoList = _mapInfoItemVoList[selectedTag];
      }

      var isComplete = _mapPageCompleteVoList[selectedTag];
      if(isComplete){
        loadDataBloc.add(LoadMoreEmptyEvent());
      }else{
        loadDataBloc.add(LoadingMoreSuccessEvent());
      }
    });
  }

  Future<List<InfoItemVo>> _getPowerList(
      String categories, int tags, int page) async {
    var isZhLanguage =
        SettingInheritedModel.of(context, aspect: SettingAspect.language)
            ?.languageModel
            ?.isZh()??true;
    var requestCatetory = NewsTagUtils.getCategory(isZhLanguage, categories);
    var requestTags = NewsTagUtils.getNewsTag(isZhLanguage, tags);
    var newsResponseList =
        await _newsApi.getNewsList(requestCatetory, requestTags, page);

    var newsVoList = newsResponseList.map((newsResponse) {
      return InfoItemVo(
          id: newsResponse.id,
          url: newsResponse.outlink,
          photoUrl: newsResponse.customCover,
          title: newsResponse.title,
          publisher: "",
          publishTime: newsResponse.date * 1000);
    }).toList();

    _mapPageVoList[tags] = page;
    return newsVoList;
  }
}
