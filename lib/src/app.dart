import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/components/app_lock/app_lock_bloc.dart';
import 'package:titan/src/components/atlas/atlas_component.dart';
import 'package:titan/src/components/auth/auth_component.dart';
import 'package:titan/src/components/exchange/exchange_component.dart';
import 'package:titan/src/components/rp/redpocket_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/components/style/theme.dart';
import 'components/app_lock/app_lock_component.dart';
import 'components/root_page_control_component/bloc/bloc.dart';
import 'components/setting/setting_component.dart';
import 'components/socket/socket_component.dart';
import 'components/updater/bloc/bloc.dart';
import 'components/wallet/wallet_component.dart';
import 'config/application.dart';
import 'routes/routes.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AppState();
  }
}

class _AppState extends State<App> with WidgetsBindingObserver {
  _AppState() {
    var router = MyRouter();
    Routes.configureRoutes(router);
    Application.router = router;
  }

  int _appLockAwayTime = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
       // print('-----[App] inactive');
        break;
      case AppLifecycleState.paused:
        //print('-----[App] paused');
        _setAppLockCountDown(true);
        //_appLockAwayTime = await AppLockUtil.getAwayTime();
        break;
      case AppLifecycleState.detached:
        //print('-----[App] detached');
        break;
      case AppLifecycleState.resumed:
        //print('-----[App] resumed');
        _setAppLockCountDown(false);
        //print('appLockAwayTime $_appLockAwayTime');
        //if (mounted) setState(() {});
        break;
    }
  }

  _setAppLockCountDown(bool isAway) {
    BlocProvider.of<AppLockBloc>(
      Keys.rootKey.currentContext,
    ).add(
      SetAppLockCountDownEvent(isAway),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MultiProvider(
        providers: [
          AuthComponent(),
          SettingComponent(),
          ExchangeComponent(),
          WalletComponent(),
          SocketComponent(),
          AtlasComponent(),
          RedPocketComponent(),
          //AccountComponent(),
          AppLockComponent(),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<UpdateBloc>(create: (context) => UpdateBloc(context: context)),
            BlocProvider<RootPageControlBloc>(create: (context) => RootPageControlBloc()),
          ],
          child: Builder(
            builder: (context) {
              return RefreshConfiguration(
                //pull to refresh config
                dragSpeedRatio: 0.91,
                headerTriggerDistance: 80,
                footerTriggerDistance: 80,
                maxOverScrollExtent: 100,
                maxUnderScrollExtent: 0,
                headerBuilder: () => WaterDropMaterialHeader(),
                footerBuilder: () => ClassicFooter(),
                autoLoad: true,
                enableLoadingWhenFailed: false,
                hideFooterWhenNotFull: true,
                enableBallisticLoad: true,
                child: Container(
                  color: Colors.white,
                  child: MaterialApp(
                    key: Keys.materialAppKey,
                    debugShowCheckedModeBanner: false,
                    locale: SettingInheritedModel.of(context, aspect: SettingAspect.language)
                        .languageModel
                        ?.locale,
                    title: 'titan',
                    theme: appTheme,
                    localizationsDelegates: [
                      S.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                      RefreshLocalizations.delegate,
                    ],
                    supportedLocales: S.delegate.supportedLocales,
                    navigatorObservers: [Application.routeObserver],
                    onGenerateRoute: Application.router.generator,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
