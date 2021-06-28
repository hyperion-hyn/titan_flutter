import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/news/api/news_api.dart';
import 'package:titan/src/pages/news/model/news_detail.dart';
import 'bloc.dart';

class AppTabBarBloc extends Bloc<AppTabBarEvent, AppTabBarState> {
  NewsApi _newsApi = NewsApi();

  @override
  AppTabBarState get initialState => InitialAppTabBarState();

  @override
  Stream<AppTabBarState> mapEventToState(AppTabBarEvent event) async* {
    if (event is InitialAppTabBarEvent) {
      yield InitialAppTabBarState();
    }
    else if (event is CheckNewAnnouncementEvent) {
      print("[bloc] isShowDialog,1111");

      var announcement = await _newsApi.getAnnouncement();

      var announcementV3 = await _newsApi.getAnnouncementV3();
      _setDomain(domain: announcementV3);

      print("[bloc] isShowDialog,2222, announcement：${announcement}, announcementV3:${announcementV3}");


      if (announcement != null) {
        var isShowDialog = false;

        // var sharePre = await SharedPreferences.getInstance();
        // var lastData = sharePre.getString(PrefsKey.lastAnnouncement);
        // if (lastData != null) {
        //   var storeData = NewsDetail.fromJson(json.decode(lastData));
        //   if (storeData.id != announcement.id) {
        //     isShowDialog = true;
        //   }
        // } else {
        //   isShowDialog = true;
        // }

        isShowDialog = true;

        // sharePre.setString(PrefsKey.lastAnnouncement, json.encode(announcement));

        print("[bloc] isShowDialog:$isShowDialog");

        if(isShowDialog){
          yield CheckNewAnnouncementState(announcement: announcement);
        }
      }
    } else if (event is BottomNavigationBarEvent) {
      yield BottomNavigationBarState(isHided: event.isHided);
    } else if (event is ChangeTabBarItemEvent) {
      yield ChangeTabBarItemState(index: event.index);
    }
    else if (event is ChangeNodeTabBarItemEvent) {
      yield ChangeNodeTabBarItemState(index: event.index);
    }
  }

  void _setDomain({domain = 'https://ht.mdex.co/#/swap?'}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var last = prefs.getString(PrefsKey.lastMexDomain);
    print('[SetDomain] last:$last, domain:$domain');

    prefs.setString(PrefsKey.lastMexDomain, domain);
  }
}
