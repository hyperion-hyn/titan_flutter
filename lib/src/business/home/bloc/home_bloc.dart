import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/src/business/infomation/api/news_api.dart';
import 'package:titan/src/business/infomation/model/news_detail.dart';
import 'package:titan/src/consts/consts.dart';

import './bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  BuildContext context;
  NewsApi _newsApi = NewsApi();

  HomeBloc({this.context});

  @override
  HomeState get initialState => InitialHomeState();

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    if(event is HomeInitEvent) {
      var announcement = await _newsApi.getAnnouncement();
      var isShowDialog = false;
      await SharedPreferences.getInstance().then((sharePre){
        var lastData = sharePre.getString(PrefsKey.lastAnnouncement);
        if(lastData != null){
          var storeData = NewsDetail.fromJson(json.decode(lastData));
          if(storeData.id != announcement.id){
            isShowDialog = true;
          }
        }else{
          isShowDialog = true;
        }
        sharePre.setString(PrefsKey.lastAnnouncement, json.encode(announcement));
      });
      if(isShowDialog){
        yield InitialHomeState(announcement: announcement);
      }else{
        yield InitialHomeState();
      }
    } else if(event is MapOperatingEvent) {
      yield MapOperatingState();
    }

  }
}
