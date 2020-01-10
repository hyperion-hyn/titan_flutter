import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/components/style/theme.dart';

import 'components/quotes/quotes_component.dart';
import 'components/root_page_control_component/bloc/bloc.dart';
import 'components/setting/setting_component.dart';
import 'components/updater/bloc/bloc.dart';
import 'components/wallet/wallet_component.dart';
import 'config/application.dart';
import 'config/routes.dart';

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AppState();
  }
}

class _AppState extends State<App> {
  _AppState() {
    var router = MyRouter();
    Routes.configureRoutes(router);
    Application.router = router;
  }

  @override
  Widget build(BuildContext context) {
    return QuotesComponent(
      child: SettingComponent(
        child: WalletComponent(
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
                  child: MaterialApp(
                    key: Keys.materialAppKey,
                    debugShowCheckedModeBanner: false,
                    locale: SettingInheritedModel.of(context, aspect: SettingAspect.language).languageModel?.locale,
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
