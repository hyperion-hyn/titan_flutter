import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/widget/draggable_bottom_sheet_controller.dart';

import 'bloc/bloc.dart';
import 'map.dart';
import 'search_bar.dart';
import 'poi_sheet.dart';
import 'top_bar.dart';
import 'route_bar.dart';

final kStyleZh = 'https://static.xuantu.mobi/maptiles/see-it-all-boundary-cdn-zh.json';
final kStyleEn = 'https://static.xuantu.mobi/maptiles/see-it-all-boundary-cdn-en.json';

class ScaffoldMap extends StatefulWidget {
  final Function onBack;

  ScaffoldMap({this.onBack});

  @override
  State<StatefulWidget> createState() {
    return _ScaffoldMapState();
  }
}

class _ScaffoldMapState extends State<ScaffoldMap> {
  DraggableBottomSheetController _draggableBottomSheetController = DraggableBottomSheetController();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness:
      Platform.isAndroid ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.grey,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    //scenes:
    //1. map
    //2. top navigation bar
    //3. search bar
    //4. route bar
    //5. bottom sheet
    //logic:  use prop to update each scene. scene use bloc to update data/state.
    return BlocListener<ScaffoldMapBloc, ScaffoldMapState>(
      listener: (context, state) {
        //TODO
      },
      child: BlocBuilder<ScaffoldMapBloc, ScaffoldMapState>(builder: (context, state) {
        var languageCode = Localizations.localeOf(context).languageCode;
        String style;
        if (languageCode == "zh") {
          style = kStyleZh;
        } else {
          style = kStyleEn;
        }
        return Stack(
          children: <Widget>[
            Map(
              style: style,
            ),
            TopBar(),
            SearchBar(),
            RouteBar(),
            PoiSheet(
              draggableBottomSheetController: _draggableBottomSheetController,
            ),
          ],
        );
      }),
    );
  }
}
