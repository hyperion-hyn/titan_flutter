import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/business/infomation/api/news_api.dart';
import 'package:titan/src/business/infomation/info_state.dart';
import 'package:titan/src/business/load_data_container/bloc/bloc.dart';
import 'package:titan/src/business/load_data_container/load_data_container.dart';
import '../../global.dart';

class NewsNcovPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NewsNcovState();
  }
}

class NewsNcovState extends InfoState<NewsNcovPage> {

//  int NCOV_TAG = 26;
//  String CATEGORY = "1";

  int NCOV_TAG = 101;
  String CATEGORY = "95";

  int FIRST_PAGE = 1;

  List<InfoItemVo> _InfoItemVoList = [];
  NewsApi _newsApi = NewsApi();

  int selectedTag; // = LAST_NEWS_TAG;
  int currentPage; // = FIRST_PAGE;

  LoadDataBloc loadDataBloc = LoadDataBloc();

  @override
  void initState() {
    super.initState();

    activeTag();
  }

  @override
  void dispose() {
    loadDataBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          S.of(context).ncov_guide,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: LoadDataContainer(
          bloc: loadDataBloc,
          onLoadData: () async {
            try {
              await _getPowerList(CATEGORY, selectedTag, FIRST_PAGE);

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
              await _getPowerList(CATEGORY, selectedTag, FIRST_PAGE);

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
              await _getPowerList(CATEGORY, selectedTag, currentPage + 1);

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
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return buildInfoItem(_InfoItemVoList[index]);
              },
              separatorBuilder: (context, index) {
                return Divider();
              },
              itemCount: _InfoItemVoList.length),
        ),
      ),
    );
  }

  void activeTag() {
    setState(() {
      selectedTag = NCOV_TAG;
      currentPage = FIRST_PAGE;
    });
    loadDataBloc.add(LoadingEvent());
  }

  Future _getPowerList(String categories, int tags, int page) async {
    //print('[news_ncov] --> getPowerList, page:$page');

    var newsResponseList = await _newsApi.getNewsList(CATEGORY, "$NCOV_TAG", page);
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
