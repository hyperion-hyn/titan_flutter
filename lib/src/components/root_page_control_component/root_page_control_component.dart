import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/auth/bloc/auth_bloc.dart';
import 'package:titan/src/components/auth/bloc/auth_event.dart';
import 'package:titan/src/components/auth/bloc/auth_state.dart';
import 'package:titan/src/components/auth/model.dart';
import 'package:titan/src/components/inject/injector.dart';
import 'package:titan/src/components/quotes/bloc/bloc.dart';
import 'package:titan/src/components/quotes/model.dart';
import 'package:titan/src/components/root_page_control_component/bloc/bloc.dart';
import 'package:titan/src/components/scaffold_map/bloc/bloc.dart';
import 'package:titan/src/components/setting/bloc/bloc.dart';
import 'package:titan/src/components/setting/model.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/pages/app_tabbar/app_tabbar_page.dart';
import 'package:titan/src/pages/app_tabbar/bloc/app_tabbar_bloc.dart';
import 'package:titan/src/pages/discover/bloc/bloc.dart';
import 'package:titan/src/pages/setting_on_launcher/setting_on_launcher_page.dart';

class RootPageControlComponent extends StatefulWidget {
  RootPageControlComponent({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RootPageControlComponentState();
  }
}

class RootPageControlComponentState
    extends BaseState<RootPageControlComponent> {
  @override
  void initState() {
    super.initState();
    _initSetting();
    launchRootPage();
  }

//  @override
//  void onCreated() {
//    //init global setting
//    _initSetting();
//  }

  _initSetting() async {
    var languageStr =
        await AppCache.getValue<String>(PrefsKey.SETTING_LANGUAGE);
    LanguageModel languageModel = languageStr != null
        ? LanguageModel.fromJson(json.decode(languageStr))
        : SupportedLanguage.defaultModel(context);

    var areaModelStr = await AppCache.getValue<String>(PrefsKey.SETTING_AREA);
    AreaModel areaModel = areaModelStr != null
        ? AreaModel.fromJson(json.decode(areaModelStr))
        : SupportedArea.defaultModel();

    var quoteSignStr =
        await AppCache.getValue<String>(PrefsKey.SETTING_QUOTE_SIGN);
    QuotesSign quotesSign = quoteSignStr != null
        ? QuotesSign.fromJson(json.decode(quoteSignStr))
        : SupportedQuoteSigns.defaultQuotesSign;

    BlocProvider.of<SettingBloc>(context).add(UpdateSettingEvent(
        areaModel: areaModel,
        languageModel: languageModel,
        quotesSign: quotesSign));

    BlocProvider.of<QuotesCmpBloc>(context).add(UpdateGasPriceEvent());

    ///Every time app restart, set to false first
    BlocProvider.of<AuthBloc>(context).add(UpdateAuthStatusEvent(
      authorized: false,
    ));

    List availableBiometricTypes = List();
    try {
      LocalAuthentication auth = LocalAuthentication();
      availableBiometricTypes = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }
    var authConfigStr = await AppCache.getValue<String>(PrefsKey.AUTH_CONFIG);
    AuthConfigModel authConfigModel = authConfigStr != null
        ? AuthConfigModel.fromJson(json.decode(authConfigStr))
        : AuthConfigModel(
            useFace: false,
            useFingerprint: false,
            setBioAuthAsked: false,
            availableBiometricTypes: availableBiometricTypes);

    BlocProvider.of<AuthBloc>(context).add(UpdateAuthConfigEvent(
      authConfigModel: authConfigModel,
    ));

    Future.delayed(Duration(milliseconds: 1500), () {
      BlocProvider.of<SettingBloc>(context).add(SystemConfigEvent());
    });
  }

  void launchRootPage() async {
    var prefs = await SharedPreferences.getInstance();
    bool notFirstTimeLauncher =
        prefs.containsKey(PrefsKey.FIRST_TIME_LAUNCHER_KEY);
    if (notFirstTimeLauncher) {
//    if (false) {
      //launch dashboard
      BlocProvider.of<RootPageControlBloc>(context)
          .add(SetRootPageEvent(page: AppTabBarPage()));
    } else {
      //launch setting
      BlocProvider.of<RootPageControlBloc>(context)
          .add(SetRootPageEvent(page: SettingOnLauncherPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ScaffoldMapBloc>(
            create: (context) => ScaffoldMapBloc(context)),
        BlocProvider<AppTabBarBloc>(create: (context) => AppTabBarBloc()),
        BlocProvider<DiscoverBloc>(create: (context) => DiscoverBloc(context)),
      ],
      child: BlocBuilder<RootPageControlBloc, RootPageControlState>(
        builder: (ctx, state) {
          if (state is UpdateRootPageState) {
            return state.child;
          }
          return Scaffold(
            body: Center(
                //child: Text('please set the root page!'),
                ),
          );
        },
      ),
    );
  }
}
