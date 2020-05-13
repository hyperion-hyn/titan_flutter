import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/pages/news/api/news_api.dart';
import 'package:titan/src/pages/news/info_state.dart';

import '../../global.dart';
import 'news_tag_utils.dart';

class WechatOfficialPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WechatOfficialState();
  }
}

class WechatOfficialState extends InfoState<WechatOfficialPage> with AutomaticKeepAliveClientMixin {
  static const String CATEGORY = "3";

  static const int FIRST_PAGE = 1;

  static const int DOMESTIC_VIDEO = 43;
  static const int FOREIGN_VIDEO = 45;

  static const int PAPER_TAG = 39;
  static const int VIDEO_TAG = 34;
  static const int AUDIO_TAG = 52;

  LoadDataBloc loadDataBloc = LoadDataBloc();

  List<InfoItemVo> _InfoItemVoList = [];
  Map<int, List<InfoItemVo>> _mapInfoItemVoList = Map();
  Map<int, int> _mapPageVoList = Map();
  Map<int, bool> _mapPageCompleteVoList = Map();
  NewsApi _newsApi = NewsApi();

  int selectedTag; // = PAPER_TAG;
//  int currentPage; // = FIRST_PAGE;

  int selectedVideoTag = DOMESTIC_VIDEO;

//  var isLoading = true;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      selectedTag = PAPER_TAG;
      _mapPageVoList = {PAPER_TAG: FIRST_PAGE,DOMESTIC_VIDEO: FIRST_PAGE
        ,FOREIGN_VIDEO: FIRST_PAGE,AUDIO_TAG: FIRST_PAGE};
      _mapPageCompleteVoList = {PAPER_TAG: false,DOMESTIC_VIDEO: false
        ,FOREIGN_VIDEO: false,AUDIO_TAG: false};
      loadDataBloc.add(LoadingEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    bool isZh = SettingInheritedModel.of(context).languageModel.isZh();

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Container(
              height: 48,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _buildTag(S.of(context).article, PAPER_TAG),
                  if (isZh) _buildTag(S.of(context).video, VIDEO_TAG),
                  if (isZh) _buildTag(S.of(context).audio, AUDIO_TAG),
                  Spacer(),
                  if (selectedTag == VIDEO_TAG && isZh)
                    DropdownButton(
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFFD2D2D2),
                        size: 24,
                      ),
                      underline: Container(),
                      style: TextStyle(fontSize: 15, color: Theme.of(context).primaryColor),
                      value: selectedVideoTag,
                      items: [
                        DropdownMenuItem(
                          child: Text(
                            S.of(context).domestic_video,
                            style: TextStyle(fontSize: 15),
                          ),
                          value: DOMESTIC_VIDEO,
                        ),
                        DropdownMenuItem(
                          child: Text(
                            S.of(context).foreign_video,
                            style: TextStyle(fontSize: 15),
                          ),
                          value: FOREIGN_VIDEO,
                        )
                      ],
                      onChanged: (value) {
                        if (selectedVideoTag == value) {
                          return;
                        }

                        setState(() {
                          selectedVideoTag = value;
                          _InfoItemVoList = _mapInfoItemVoList[selectedVideoTag];

                          var isComplete = _mapPageCompleteVoList[getSelectTag(selectedTag)];
                          if(isComplete){
                            loadDataBloc.add(LoadMoreEmptyEvent());
                          }else{
                            loadDataBloc.add(LoadingMoreSuccessEvent());
                          }
                        });
                      },
                    )
                ],
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
                  var loadMoreList = await _getPowerListByPage(getSelectTag(selectedTag), _mapPageVoList[getSelectTag(selectedTag)] + 1);
                  if (loadMoreList.length == 0) {
                    loadDataBloc.add(LoadMoreEmptyEvent());
                  } else {
                    var tempSelectTag = getSelectTag(selectedTag);
                    var _tempInfoItemVoList = _mapInfoItemVoList[tempSelectTag];
                    _tempInfoItemVoList.addAll(loadMoreList);
                    _mapInfoItemVoList[tempSelectTag] = _tempInfoItemVoList;
                    _InfoItemVoList = _mapInfoItemVoList[tempSelectTag];
                    loadDataBloc.add(LoadingMoreSuccessEvent());

                    setState(() {});
                  }
                } catch (e) {
                  logger.e(e);
                  //hack for wordpress rest_post_invalid_page_number
                  if (e is DioError && e.message == 'Http status error [400]') {
                    loadDataBloc.add(LoadMoreEmptyEvent());
                  } else {
                    _mapPageCompleteVoList[getSelectTag(selectedTag)] = true;
                    loadDataBloc.add(LoadMoreFailEvent());
                  }
                }
              },
              onLoadingMoreEmpty:() {
                _mapPageCompleteVoList[getSelectTag(selectedTag)] = true;
              },
              child: ListView.separated(
                itemBuilder: (context, index) {
                  return buildInfoItem(_InfoItemVoList[index]);
                },
                separatorBuilder: (context, index) {
                  return Divider();
                },
                itemCount: _InfoItemVoList.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Future loadOrRefreshData() async{
    _mapPageCompleteVoList = {PAPER_TAG: false,DOMESTIC_VIDEO: false
      ,FOREIGN_VIDEO: false,AUDIO_TAG: false};
    _mapPageVoList = {PAPER_TAG: FIRST_PAGE,DOMESTIC_VIDEO: FIRST_PAGE
      ,FOREIGN_VIDEO: FIRST_PAGE,AUDIO_TAG: FIRST_PAGE};
    var paperList;
    var domesticList;
    var foreignList;
    var audioList;
    bool isZh = SettingInheritedModel.of(context).languageModel.isZh();

    paperList = await _getPowerListByPage(PAPER_TAG, FIRST_PAGE);
    if(isZh){
      domesticList = await _getPowerListByPage(DOMESTIC_VIDEO, FIRST_PAGE);
      foreignList = await _getPowerListByPage(FOREIGN_VIDEO, FIRST_PAGE);
      audioList = await _getPowerListByPage(AUDIO_TAG, FIRST_PAGE);
    }
    _mapInfoItemVoList = {PAPER_TAG: paperList,DOMESTIC_VIDEO: domesticList,
      FOREIGN_VIDEO: foreignList,AUDIO_TAG: audioList};

    _InfoItemVoList = _mapInfoItemVoList[getSelectTag(selectedTag)];

    if (_InfoItemVoList.length == 0) {
      loadDataBloc.add(LoadEmptyEvent());
    } else {
      loadDataBloc.add(RefreshSuccessEvent());
    }

    setState(() {});
  }

  int getSelectTag(int tags){
    if(tags == VIDEO_TAG){
      return selectedVideoTag;
    }else{
      return selectedTag;
    }
  }

  Widget _buildTag(String text, int value) {
    return super.buildTag(text, value, selectedTag == value, activeTag);
  }

  void activeTag(int tagId) {
    if (_mapInfoItemVoList.length == 0 || selectedTag == tagId) {
      return;
    }

    setState(() {
      selectedTag = tagId;
      _InfoItemVoList = _mapInfoItemVoList[getSelectTag(selectedTag)];

      var isComplete = _mapPageCompleteVoList[getSelectTag(selectedTag)];
      print("complete tags $selectedTag and $selectedVideoTag and iscomplete $isComplete");
      if(isComplete){
        loadDataBloc.add(LoadMoreEmptyEvent());
      }else{
        loadDataBloc.add(LoadingMoreSuccessEvent());
      }
    });
  }

  Future<List<InfoItemVo>> _getPowerListByPage(int tags,int page) {
    bool isZh = SettingInheritedModel.of(context).languageModel.isZh();

    return _getPowerList(CATEGORY, tags, page, isZh);
  }

  Future<List<InfoItemVo>> _getPowerList(String categories, int tags, int page, bool isZh) async {
    var requestCatetory = NewsTagUtils.getCategory(isZh, categories);
    var requestTags = NewsTagUtils.getNewsTag(isZh, tags);

    var newsResponseList = await _newsApi.getNewsList(requestCatetory, requestTags, page);
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

    print("tags == $tags and page == $page" );
    _mapPageVoList[tags] = page;
    if (newsVoList.length == 0) {
      return null;
    }
    return newsVoList;
  }
}
