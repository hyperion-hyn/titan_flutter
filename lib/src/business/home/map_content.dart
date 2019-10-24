import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:titan/src/business/home/bloc/bloc.dart';
import 'package:titan/src/business/home/bootom_opt_bar_widget.dart';
import 'package:titan/src/business/home/bottom_fabs_widget.dart';
import 'package:titan/src/business/home/map/map_scenes.dart';
import 'package:titan/src/business/home/searchbar/searchbar.dart';
import 'package:titan/src/business/home/share_dialog.dart';
import 'package:titan/src/business/home/sheets/bloc/bloc.dart' as sheets;
import 'package:titan/src/business/home/sheets/sheets.dart';
import 'package:titan/src/business/search/search_page.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/model/poi.dart';
import 'package:titan/src/widget/draggable_bottom_sheet_controller.dart';

class MapContentWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MapContentState();
  }
}

class _MapContentState extends State<MapContentWidget> {
  DraggableBottomSheetController _draggableBottomSheetController = DraggableBottomSheetController();
  GlobalKey mapScenseKey = GlobalKey();

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

    return Builder(
        builder: (BuildContext context) => Stack(
              children: <Widget>[
                ///地图渲染
                MapScenes(
                  draggableBottomSheetController: _draggableBottomSheetController,
                  key: mapScenseKey,
                ),

                ///主要是支持drawer手势划出
                Container(
                  margin: EdgeInsets.only(top: 120),
                  decoration: BoxDecoration(color: Colors.transparent),
                  constraints: BoxConstraints.tightForFinite(width: 24.0),
                ),

                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                    child: Container(
                      decoration: BoxDecoration(color: Color(0xeeffffff), borderRadius: BorderRadius.circular(8)),
                      width: 45,
                      height: 45,
                      margin: EdgeInsets.only(top: 115, right: 20),
                      padding: EdgeInsets.all(6),
                      child:
                          SvgPicture.asset("res/drawable/map_layer.svg", color: Colors.grey[700], semanticsLabel: ''),
                    ),
                  ),
                ),

//                BottomFabsWidget(draggableBottomSheetController: _draggableBottomSheetController),

                ///bottom sheet
                Sheets(
                  draggableBottomSheetController: _draggableBottomSheetController,
                ),

                ///search bar
                SearchBarPresenter(
                  draggableBottomSheetController: _draggableBottomSheetController,
                  onMenu: () => Scaffold.of(context).openDrawer(),
                  backToPrvSearch: (String searchText) {
                    BlocProvider.of<HomeBloc>(context).add(SearchTextEvent(searchText: searchText));
                  },
                  onExistSearch: () => BlocProvider.of<HomeBloc>(context).add(ExistSearchEvent()),
                  onSearch: (searchText) async {
                    var mapScenseState = mapScenseKey.currentState as MapScenesState;
                    print("get mapScenseState ");
                    var camraPosition = await mapScenseState.mapboxMapController.getCameraPosition();
                    print("search center $camraPosition");
                    var center = camraPosition.target;
                    print("search center $center");
                    var searchResult = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SearchPage(
                                  searchCenter: center,
                                  searchText: searchText,
                                )));
                    if (searchResult is String) {
                      BlocProvider.of<HomeBloc>(context)
                          .add(SearchTextEvent(searchText: searchResult, center: center));
                    } else if (searchResult is PoiEntity) {
                      if (searchResult.address == null) {
                        //we need to full fil all properties
                        BlocProvider.of<HomeBloc>(context).add(SearchPoiEvent(poi: searchResult));
                      } else {
                        BlocProvider.of<HomeBloc>(context).add(ShowPoiEvent(poi: searchResult));
                      }
                    }
                  },
                ),

                ///opt area
                BlocBuilder<sheets.SheetsBloc, sheets.SheetsState>(
                  builder: (context, state) {
                    if (state is sheets.PoiLoadedState || state is sheets.HeavenPoiLoadedState) {
                      return BottomOptBarWidget(
                        onRouteTap: () {
//                                BlocProvider.of<HomeBloc>(context).add(RouteEvent());
                          eventBus.fire(RouteClickEvent());
                        },
                        onShareTap: () async {
                          var selectedPoi = BlocProvider.of<HomeBloc>(context).selectedPoi;
                          if (selectedPoi != null) {
                            var dat = await showDialog(
                                context: context,
                                builder: (context) {
                                  return ShareDialog(poi: selectedPoi);
                                });
                          }
                        },
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              ],
            ));
  }
}
