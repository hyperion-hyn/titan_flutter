import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/root_page_control_component/bloc/bloc.dart';
import 'package:titan/src/components/setting/bloc/bloc.dart';
import 'package:titan/src/components/setting/model.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/pages/app_tabbar/app_tabbar_page.dart';
import 'package:titan/src/pages/app_tabbar/bloc/app_tabbar_bloc.dart';
import 'package:titan/src/pages/setting_on_launcher/setting_on_launcher_page.dart';

class RootPageControlComponent extends StatefulWidget {
  RootPageControlComponent({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RootPageControlComponentState();
  }
}

class RootPageControlComponentState extends BaseState<RootPageControlComponent> {
  @override
  void initState() {
    super.initState();
    launchRootPage();
  }

  @override
  void onCreated() {
    //init global setting
    _initSetting();
  }

  _initSetting() async {
    var languageStr = await AppCache.getValue<String>(PrefsKey.SETTING_LANGUAGE);
    if (languageStr != null) {
      var languageModel = LanguageModel.fromJson(json.decode(languageStr));
      BlocProvider.of<SettingBloc>(context).add(UpdateLanguageEvent(languageModel: languageModel));
    } else {
      BlocProvider.of<SettingBloc>(context)
          .add(UpdateLanguageEvent(languageModel: SupportedLanguage.defaultModel(context)));
    }

    //hack. should be delay a while, or the UpdateLanguageEvent will be eaten.
    await Future.delayed(Duration(milliseconds: 300));

    var areaModelStr = await AppCache.getValue<String>(PrefsKey.SETTING_AREA);
    if (areaModelStr != null) {
      var areaModel = AreaModel.fromJson(json.decode(areaModelStr));
      BlocProvider.of<SettingBloc>(context).add(UpdateAreaEvent(areaModel: areaModel));
    } else {
      BlocProvider.of<SettingBloc>(context).add(UpdateAreaEvent(areaModel: SupportedArea.defaultModel(context)));
    }
  }

  void launchRootPage() async {
    var prefs = await SharedPreferences.getInstance();
    bool notFirstTimeLauncher = prefs.containsKey(PrefsKey.FIRST_TIME_LAUNCHER_KEY);
    if (notFirstTimeLauncher) {
//    if (false) {
      //launch dashboard
      BlocProvider.of<RootPageControlBloc>(context).add(SetRootPageEvent(
          page: BlocProvider<AppTabBarBloc>(
        create: (ctx) => AppTabBarBloc(),
        child: AppTabBarPage(),
      )));
    } else {
      //launch setting
      BlocProvider.of<RootPageControlBloc>(context).add(SetRootPageEvent(page: SettingOnLauncherPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RootPageControlBloc, RootPageControlState>(
      builder: (ctx, state) {
        if (state is UpdateRootPageState) {
          return state.child;
        }
        return Scaffold(
          body: Center(
            child: Text('please set the root page!'),
          ),
        );
      },
    );
  }
}
