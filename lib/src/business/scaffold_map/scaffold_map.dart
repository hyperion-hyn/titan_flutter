import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/widget/draggable_bottom_sheet.dart';
import 'package:titan/src/widget/draggable_bottom_sheet_controller.dart';

import 'bloc/bloc.dart';
import 'bottom_panels/common_panel.dart';
import 'bottom_panels/poi_panel.dart';
import 'map.dart';
import 'opt_bar.dart';
import 'search_bar.dart';
import 'top_bar.dart';
import 'route_bar.dart';

final kStyleZh = 'https://static.xuantu.mobi/maptiles/see-it-all-boundary-cdn-zh.json';
final kStyleEn = 'https://static.xuantu.mobi/maptiles/see-it-all-boundary-cdn-en.json';

typedef PanelBuilder = Widget Function<POI>(BuildContext context, POI poi);

class ScaffoldMap extends StatefulWidget {
  final Function onBack;
  final PanelBuilder panelBuilder;

  ScaffoldMap({this.onBack, this.panelBuilder});

  @override
  State<StatefulWidget> createState() {
    return _ScaffoldMapState();
  }
}

class _ScaffoldMapState extends State<ScaffoldMap> {
  DraggableBottomSheetController _draggableBottomSheetController = DraggableBottomSheetController();
  ScrollController _bottomChildScrollController = ScrollController();

  double getTopBarHeight() {
    return 0;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Platform.isAndroid ? Brightness.dark : Brightness.light,
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
    //6. bottom operation bar
    //logic:  use prop to update each scene. scene use bloc to update data/state.
    return BlocBuilder<ScaffoldMapBloc, ScaffoldMapState>(builder: (context, state) {
      print('bloc builder: $state');
      var languageCode = Localizations.localeOf(context).languageCode;

      //---------------------------
      //set map
      //---------------------------
      String style;
      if (languageCode == "zh") {
        style = kStyleZh;
      } else {
        style = kStyleEn;
      }
//        var mapState =
      if (state is InitialScaffoldMapState) {}

      //---------------------------
      //set topbar
      //---------------------------

      //---------------------------
      //set search bar
      //---------------------------

      //---------------------------
      //set route
      //---------------------------

      //---------------------------
      //set the bottom sheet
      //---------------------------
      double topPadding = 0;
      double topRadius = 0;
      bool draggable = false;
      Widget sheetPanel;

      DraggableBottomSheetState dragState = DraggableBottomSheetState.HIDDEN;

      if (state is InitialScaffoldMapState) {
        //nothing
      } else if (state is SearchingPoiState) {
        //搜索POI
        sheetPanel = LoadingPanel();
        dragState = DraggableBottomSheetState.COLLAPSED;
      } else if (state is ShowPoiState) {
        //显示poi
        draggable = true;
        topRadius = 16;
        topPadding = getTopBarHeight();
        sheetPanel = PoiPanel(
          scrollController: _bottomChildScrollController,
          selectedPoiEntity: state.getCurrentPoi(),
        );
        dragState = DraggableBottomSheetState.COLLAPSED;
      } else if (state is SearchPoiFailState) {
        //搜索poi失败
        sheetPanel = FailPanel(message: state.message);
        dragState = DraggableBottomSheetState.COLLAPSED;
      }

      _draggableBottomSheetController.setSheetState(dragState);
      _draggableBottomSheetController.collapsedHeight = 112;

      //---------------------------
      //set opt bar
      //---------------------------
      bool showOptBar = false;
      if (state is ShowPoiState) {
        showOptBar = true;
      }

      return Stack(
        children: <Widget>[
          MapContainer(
            bottomPanelController: _draggableBottomSheetController,
            style: style,
          ),
          TopBar(),
          SearchBar(),
          RouteBar(),
          /* bottom sheet */
          DraggableBottomSheet(
            draggable: draggable,
            topPadding: topPadding,
            topRadius: topRadius,
            controller: _draggableBottomSheetController,
            childScrollController: _bottomChildScrollController,
            child: sheetPanel ?? Container(),
          ),
          if (showOptBar)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: OperationBar(),
            ),
        ],
      );
    });
  }
}
