import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/business/home/map/bloc/bloc.dart';
import 'package:titan/src/business/home/sheets/heven_poi_bottom_sheet.dart';
import 'package:titan/src/business/home/sheets/poi_bottom_sheet.dart';
import 'package:titan/src/business/home/sheets/search_fault_sheet.dart';
import 'package:titan/src/business/home/sheets/searching_sheet.dart';
import 'package:titan/src/widget/draggable_bottom_sheet.dart';
import 'package:titan/src/widget/draggable_bottom_sheet_controller.dart';

import 'bloc/bloc.dart';
import 'poi_list_sheet.dart';
import 'route_sheet.dart';

class Sheets extends StatefulWidget {
  final DraggableBottomSheetController draggableBottomSheetController;

  Sheets({this.draggableBottomSheetController});

  @override
  State<StatefulWidget> createState() {
    return _SheetState();
  }
}

class _SheetState extends State<Sheets> {
  ScrollController _bottomSheetScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    Widget sheet = SizedBox.shrink();

    return MultiBlocListener(
      listeners: [
        BlocListener<SheetsBloc, SheetsState>(listener: (context, state) {
          if (state is PoiLoadedState) {
            widget.draggableBottomSheetController.anchorHeight = kAnchorPoiHeight;
          } else if (state is HeavenPoiLoadedState) {
            widget.draggableBottomSheetController.anchorHeight = kAnchorPoiHeight;
          } else {
            widget.draggableBottomSheetController.anchorHeight = kAnchorSearchHeight;
          }

          if (state.nextSheetState !=
                  null /*&&
              (state.nextSheetState == DraggableBottomSheetState.HIDDEN ||
                  widget.draggableBottomSheetController.getSheetState() == DraggableBottomSheetState.HIDDEN ||
                  widget.draggableBottomSheetController.getSheetState() == DraggableBottomSheetState.EXPANDED)*/
              ) {
            widget.draggableBottomSheetController.setSheetState(state.nextSheetState);
          }
        }),
        BlocListener<MapBloc, MapState>(
          listener: (context, state) {
            if (state is RouteSceneState) {
              widget.draggableBottomSheetController.collapsedHeight = 110;
              widget.draggableBottomSheetController.setSheetState(DraggableBottomSheetState.COLLAPSED);
            }
          },
        )
      ],
      child: BlocBuilder<SheetsBloc, SheetsState>(
        builder: (context, state) {
          if (state is LoadingPoiState) {
            sheet = SearchingBottomSheet();
          } else if (state is LoadFailState) {
            sheet = SearchFaultBottomSheet();
          } else if (state is PoiLoadedState) {
            sheet = PoiBottomSheet(
              selectedPoiEntity: state.poiEntity,
              scrollController: _bottomSheetScrollController,
            );
          } else if (state is HeavenPoiLoadedState) {
            sheet = HeavenPoiBottomSheet(
              selectedPoiEntity: state.poi,
              scrollController: _bottomSheetScrollController,
            );
          } else if (state is ItemsLoadedState) {
            sheet = PoiListSheet(
              pois: state.items,
              scrollController: _bottomSheetScrollController,
              listHeight: kAnchorSearchHeight,
            );
          }

          var draggable = state is PoiLoadedState || state is HeavenPoiLoadedState;

          return BlocBuilder<MapBloc, MapState>(
            builder: (context, state) {
              if (state is RouteSceneState) {
                sheet = RouteSheet();
              }
              return DraggableBottomSheet(
                draggable: draggable,
                controller: widget.draggableBottomSheetController,
                childScrollController: _bottomSheetScrollController,
                topRadius: 16,
                //paddingtop + search height + paddingbottom - draggable height - threshold
                topPadding: (MediaQuery.of(context).padding.top + 48 + 8 - 12 - 4),
                child: Stack(
                  children: <Widget>[sheet],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
