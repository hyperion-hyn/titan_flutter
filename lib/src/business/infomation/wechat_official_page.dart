import 'package:flutter/material.dart';
import 'package:titan/src/business/infomation/api/news_api.dart';
import 'package:titan/src/business/infomation/info_state.dart';

class WechatOfficialPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WechatOfficialState();
  }
}

class _WechatOfficialState extends InfoState<WechatOfficialPage> {
  final String CATEGORY = "3";

  static final int DOMESTIC_VIDEO = 43;
  static final int FOREIGN_VIDEO = 46;

  static final int PAPER_TAG = 39;
  static final int VIDEO_TAG = 34;

  List<InfoItemVo> _InfoItemVoList = [];
  int selectedTag = 39;
  NewsApi _newsApi = NewsApi();
  int page = 1;

  int selectedVideoTag = DOMESTIC_VIDEO;

  @override
  void initState() {
    super.initState();
    _getPowerListByPage(1);
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
                        page = 1;
                        _getPowerListByPage(page);
                        setState(() {});
                      },
                    )
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
                itemBuilder: (context, index) {
                  return buildInfoItem(_InfoItemVoList[index]);
                },
                separatorBuilder: (context, index) {
                  return Divider();
                },
                itemCount: _InfoItemVoList.length),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, int value) {
    Color textColor = value == selectedTag ? Theme.of(context).primaryColor : Color(0xFF252525);

    Color borderColor = value == selectedTag ? Theme.of(context).primaryColor : Color(0xFFB7B7B7);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: () async {
          if (selectedTag == value) {
            return;
          }
          selectedTag = value;
          page = 1;
          _getPowerListByPage(page);
          setState(() {});
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Text(
            text,
            style: TextStyle(fontSize: 15, color: textColor),
          ),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), border: Border.all(color: borderColor)),
        ),
      ),
    );
  }

  Future _getPowerListByPage(int page) {
    var tags = "";
    if (selectedTag == PAPER_TAG) {
      tags = selectedTag.toString();
    } else {
      tags = "$selectedTag,$selectedVideoTag";
    }
    _getPowerList(CATEGORY, tags, page);
  }

  Future _getPowerList(String categories, String tags, int page) async {
    var newsResponseList = await _newsApi.getNewsList(categories, tags, page);

    var newsVoList = newsResponseList.map((newsResponse) {
      return InfoItemVo(
          id: newsResponse.id,
          url: newsResponse.outlink,
          photoUrl: newsResponse.customCover,
          title: newsResponse.title,
          publisher: "",
          publishTime: newsResponse.date * 1000);
    }).toList();
    if (page == 1) {
      _InfoItemVoList.clear();
      _InfoItemVoList.addAll(newsVoList);
    } else {
      _InfoItemVoList.addAll(newsVoList);
    }
    setState(() {});
  }
}
