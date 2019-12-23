import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/business/discover/bloc/bloc.dart';
import 'package:titan/src/business/scaffold_map/bloc/bloc.dart';
import 'package:titan/src/global.dart';

import 'business/home/bloc/bloc.dart';
import 'business/home/home_page.dart';
import 'business/home/searchbar/bloc/bloc.dart';
import 'consts/consts.dart';

class HomeBuilder extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeBuilderState();
  }
}

class _HomeBuilderState extends State<HomeBuilder> {
  SearchbarBloc searchBarBloc;
  HomeBloc homeBloc;

  DateTime _lastPressedAt;

  @override
  void initState() {
    super.initState();
    initBloc();
  }

  void initBloc() {
    searchBarBloc = SearchbarBloc();
    homeBloc = HomeBloc();
    searchBarBloc.homeBloc = homeBloc;
  }

  @override
  void dispose() {
    searchBarBloc.close();
    homeBloc.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    globalContext = context;
    appLocale = Localizations.localeOf(context);
    return Builder(
      key: Keys.mainContextKey,
      builder: (context) {
        return MultiBlocProvider(
          child: WillPopScope(
            onWillPop: () async {
              if (_lastPressedAt == null || DateTime.now().difference(_lastPressedAt) > Duration(seconds: 2)) {
                _lastPressedAt = DateTime.now();
                Fluttertoast.showToast(msg: S.of(context).click_again_to_exist_app);
                return false;
              }
              return true;
            },
            child: HomePage(),
          ),
          providers: [
            BlocProvider<SearchbarBloc>(builder: (context) => searchBarBloc..context = context),
            BlocProvider<HomeBloc>(builder: (context) => homeBloc..context = context),
            BlocProvider<ScaffoldMapBloc>(builder: (context) => ScaffoldMapBloc(context)),
            BlocProvider<DiscoverBloc>(builder: (context) => DiscoverBloc(context)),
          ],
        );
      },
    );
  }
}
