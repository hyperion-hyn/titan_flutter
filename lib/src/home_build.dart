import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/src/business/discover/bloc/bloc.dart';
import 'package:titan/src/business/scaffold_map/bloc/bloc.dart';
import 'package:titan/src/global.dart';
import 'package:titan/generated/i18n.dart';
import 'business/home/bloc/bloc.dart';
import 'business/home/home_page.dart';
import 'business/home/map/bloc/bloc.dart';
import 'business/home/searchbar/bloc/bloc.dart';
import 'business/home/sheets/bloc/bloc.dart';
import 'consts/consts.dart';

class HomeBuilder extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeBuilderState();
  }
}

class _HomeBuilderState extends State<HomeBuilder> {
  SheetsBloc sheetsBloc;
  MapBloc mapBloc;
  SearchbarBloc searchBarBloc;
  HomeBloc homeBloc;

  DateTime _lastPressedAt;

  @override
  void initState() {
    super.initState();
    initBloc();
  }




  void initBloc() {
    sheetsBloc = SheetsBloc();
    mapBloc = MapBloc();
    searchBarBloc = SearchbarBloc();
    homeBloc = HomeBloc();
    homeBloc.mapBloc = mapBloc;
    homeBloc.searchBarBloc = searchBarBloc;
    homeBloc.sheetBloc = sheetsBloc;

    sheetsBloc.homeBloc = homeBloc;
    mapBloc.homeBloc = homeBloc;
    mapBloc.sheetsBloc = sheetsBloc;
    searchBarBloc.homeBloc = homeBloc;
  }

  @override
  void dispose() {
    sheetsBloc.close();
    mapBloc.close();
    searchBarBloc.close();
    homeBloc.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('[home] --> build, context:$context');

    return Builder(
      key: Keys.mainContextKey,
      builder: (context) {
        return MultiBlocProvider(
          child: WillPopScope(
            onWillPop: () async {
              if (_lastPressedAt == null ||
                  DateTime.now().difference(_lastPressedAt) >
                      Duration(seconds: 2)) {
                _lastPressedAt = DateTime.now();
                Fluttertoast.showToast(msg: S.of(globalContext).again_click_exit_app);
                return false;
              }
              return true;
            },
            child: HomePage(),
          ),
          providers: [
            BlocProvider<SheetsBloc>(
                builder: (context) => sheetsBloc..context = context),
            BlocProvider<MapBloc>(
                builder: (context) => mapBloc..context = context),
            BlocProvider<SearchbarBloc>(
                builder: (context) => searchBarBloc..context = context),
            BlocProvider<HomeBloc>(
                builder: (context) => homeBloc..context = context),
            BlocProvider<ScaffoldMapBloc>(
                builder: (context) => ScaffoldMapBloc(context)),
            BlocProvider<DiscoverBloc>(
                builder: (context) => DiscoverBloc(context)),
          ],
        );
      },
    );
  }
}
