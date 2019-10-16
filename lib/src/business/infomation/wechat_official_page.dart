import 'package:flutter/material.dart';
import 'package:titan/src/business/infomation/api/news_api.dart';
import 'package:titan/src/business/infomation/info_state.dart';
import 'package:titan/src/widget/load_data_widget.dart';
import 'package:titan/src/widget/smart_pull_refresh.dart';

class WechatOfficialPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WechatOfficialState();
  }
}

class _WechatOfficialState extends InfoState<WechatOfficialPage> {
  static const String CATEGORY = "3";

  static const int FIRST_PAGE = 1;

  static const int DOMESTIC_VIDEO = 43;
  static const int FOREIGN_VIDEO = 45;

  static const int PAPER_TAG = 39;
  static const int VIDEO_TAG = 34;
  static const int AUDIO_TAG = 52;

  List<InfoItemVo> _InfoItemVoList = [];
  int selectedTag = PAPER_TAG;
  NewsApi _newsApi = NewsApi();
  int currentPage = FIRST_PAGE;

  int selectedVideoTag = DOMESTIC_VIDEO;
  var isLoading = true;

  @override
  void initState() {
    super.initState();
    _getPowerListByPage(FIRST_PAGE);
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
                  _buildTag("文章", PAPER_TAG),
                  _buildTag("视频", VIDEO_TAG),
                  _buildTag("音频", AUDIO_TAG),
                  Spacer(),
                  if (selectedTag == 34)
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
                            "国内视频",
                            style: TextStyle(fontSize: 15),
                          ),
                          value: DOMESTIC_VIDEO,
                        ),
                        DropdownMenuItem(
                          child: Text(
                            "国外视频",
                            style: TextStyle(fontSize: 15),
                          ),
                          value: FOREIGN_VIDEO,
                        )
                      ],
                      onChanged: (value) {
                        if (selectedVideoTag == value) {
                          return;
                        }
                        selectedVideoTag = value;
                        currentPage = 1;
                        isLoading = true;
                        _getPowerListByPage(currentPage);
                        setState(() {});
                      },
                    )
                ],
              ),
            ),
          ),
          Expanded(
            child: LoadDataWidget(
              isLoading: isLoading,
              child: SmartPullRefresh(
                onRefresh: () {
                  _getPowerListByPage(FIRST_PAGE);
                },
                onLoading: () {
                  _getPowerListByPage(currentPage + 1);
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
      currentPage = 1;
      isLoading = true;
      _getPowerListByPage(currentPage);
      setState(() {});
    });
  }

  Future _getPowerListByPage(int page) {
    var tags = "";
    if (selectedTag == VIDEO_TAG) {
      tags = selectedVideoTag.toString();
    } else {
      tags = selectedTag.toString();
    }

    _getPowerList(CATEGORY, tags, page);
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
