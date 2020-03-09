import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/src/business/infomation/api/news_api.dart';
import 'package:titan/src/business/infomation/model/focus_response.dart' as focus;
import 'package:titan/src/pages/news/news_tag_utils.dart';
import 'package:titan/src/business/scaffold_map/bloc/bloc.dart' as map;
import 'package:titan/src/global.dart';
import '../dmap_define.dart';
import 'bloc.dart';

class DiscoverBloc extends Bloc<DiscoverEvent, DiscoverState> {
  final BuildContext context;

  NewsApi _newsApi = NewsApi();

  DiscoverBloc(this.context);

  @override
  DiscoverState get initialState => InitialDiscoverState();

  @override
  Stream<DiscoverState> mapEventToState(DiscoverEvent event) async* {
    if (event is InitDiscoverEvent) {
      yield InitialDiscoverState();

      BlocProvider.of<map.ScaffoldMapBloc>(context).add(map.InitMapEvent());
    } else if (event is ActiveDMapEvent) {
      DMapCreationModel model = DMapDefine.kMapList[event.name];
      if (model != null) {
        yield ActiveDMapState(name: event.name);

        DMapCreationModel model = DMapDefine.kMapList[event.name];
        BlocProvider.of<map.ScaffoldMapBloc>(context).add(map.InitDMapEvent(
          dMapConfigModel: model.dMapConfigModel,
        ));
      }
    } else if (event is LoadFocusImageEvent) {
      var requestCategory = NewsTagUtils.getFocusCatetory(appLocale);
      List<focus.FocusImage> focusList = await _newsApi.getFocusList(requestCategory);
      //save to cache
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var json = jsonEncode(focusList);
      await prefs.setString("disc_focus", json);

      yield (LoadedFocusState(focusImages: focusList));
    }
  }
}
