import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/pages/news/api/news_api.dart';
import 'package:titan/src/pages/news/news_tag_utils.dart';
import '../dmap_define.dart';
import 'bloc.dart';
import 'package:titan/src/components/scaffold_map/bloc/bloc.dart' as map;
import 'package:titan/src/pages/news/model/focus_response.dart' as focus;

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
      //main map back to default state
      BlocProvider.of<map.ScaffoldMapBloc>(context).add(map.DefaultMapEvent());
    } else if (event is ActiveDMapEvent) {
      DMapCreationModel model = DMapDefine.kMapList[event.name];
      if (model != null) {
        yield ActiveDMapState(name: event.name);

        BlocProvider.of<map.ScaffoldMapBloc>(context).add(map.EnterDMapEvent(
          dMapConfigModel: model.dMapConfigModel,
        ));
      }
    } else if (event is LoadFocusImageEvent) {
      bool isZh = SettingInheritedModel.of(context)?.languageModel?.isZh()??true;
      var requestCategory = NewsTagUtils.getFocusCategory(isZh);
      List<focus.FocusImage> focusList = await _newsApi.getFocusList(requestCategory);
      //save to cache
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var json = jsonEncode(focusList);
      await prefs.setString("disc_focus", json);

      yield (LoadedFocusState(focusImages: focusList));
    }
  }
}
