import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/business/infomation/api/news_api.dart';
import 'package:titan/src/pages/news/info_state.dart';
import 'package:titan/src/business/load_data_container/bloc/bloc.dart';
import 'package:titan/src/business/load_data_container/load_data_container.dart';

import '../../global.dart';
import 'news_tag_utils.dart';

class WechatOfficialPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WechatOfficialState();
  }
}

class WechatOfficialState extends InfoState<WechatOfficialPage> {
  static const String CATEGORY = "3";

  static const int FIRST_PAGE = 1;

  static const int DOMESTIC_VIDEO = 43;
  static const int FOREIGN_VIDEO = 45;

  static const int PAPER_TAG = 39;
  static const int VIDEO_TAG = 34;
  static const int AUDIO_TAG = 52;

  LoadDataBloc loadDataBloc = LoadDataBloc();

  List<InfoItemVo> _InfoItemVoList = [];
  NewsApi _newsApi = NewsApi();

  int selectedTag; // = PAPER_TAG;
  int currentPage; // = FIRST_PAGE;

  int selectedVideoTag = DOMESTIC_VIDEO;

//  var isLoading = true;

  @override
  void initState() {
    super.initState();
//    _getPowerListByPage(FIRST_PAGE);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      activeTag(PAPER_TAG);
    });
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _buildTag(S.of(context).article, PAPER_TAG),
                  if (appLocale.languageCode == "zh") _buildTag(S.of(context).video, VIDEO_TAG),
                  if (appLocale.languageCode == "zh") _buildTag(S.of(context).audio, AUDIO_TAG),
                  Spacer(),
                  if (selectedTag == VIDEO_TAG && appLocale.languageCode == "zh")
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
                          currentPage = 1;
                        });
//                        isLoading = true;
//                        _getPowerListByPage(currentPage);
                        loadDataBloc.add(LoadingEvent());
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
                  await _getPowerListByPage(FIRST_PAGE);

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
                  await _getPowerListByPage(FIRST_PAGE);

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
                  await _getPowerListByPage(currentPage + 1);

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
                itemCount: _InfoItemVoList.length,
              ),
            ),
//            child: LoadDataWidget(
//              isLoading: isLoading,
//              child: SmartPullRefresh(
//                onRefresh: () {
//                  _getPowerListByPage(FIRST_PAGE);
//                },
//                onLoading: () {
//                  _getPowerListByPage(currentPage + 1);
//                },
//                child: ListView.separated(
//                    itemBuilder: (context, index) {
//                      return buildInfoItem(_InfoItemVoList[index]);
//                    },
//                    separatorBuilder: (context, index) {
//                      return Divider();
//                    },
//                    itemCount: _InfoItemVoList.length),
//              ),
//            ),
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

    setState(() {
      selectedTag = tagId;
      currentPage = 1;
    });
    loadDataBloc.add(LoadingEvent());

//      isLoading = true;
//    _getPowerListByPage(currentPage);
//    setState(() {});
  }

  Future _getPowerListByPage(int page) {
    var tags;
    if (selectedTag == VIDEO_TAG && appLocale.languageCode == "zh") {
      tags = selectedVideoTag;
    } else {
      tags = selectedTag;
    }

    return _getPowerList(CATEGORY, tags, page);
  }

  Future _getPowerList(String categories, int tags, int page) async {
    var requestCatetory = NewsTagUtils.getCatetory(appLocale, categories);
    var requestTags = NewsTagUtils.getNewsTag(appLocale, tags);

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
    if (newsVoList.length == 0) {
      return;
    }
    if (page == FIRST_PAGE) {
      _InfoItemVoList.clear();
      _InfoItemVoList.addAll(newsVoList);
    } else {
      _InfoItemVoList.addAll(newsVoList);
    }
    currentPage = page;
    if (mounted) {
      setState(() {});
    }
  }
}
