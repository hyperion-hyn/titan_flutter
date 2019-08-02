import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/business/home/sheets/poi_bottom_sheet.dart';
import 'package:titan/src/business/home/sheets/search_fault_sheet.dart';
import 'package:titan/src/business/home/sheets/searching_sheet.dart';
import 'package:titan/src/widget/draggable_bottom_sheet.dart';
import 'package:titan/src/widget/draggable_bottom_sheet_controller.dart';

import 'bloc/bloc.dart';
import 'poi_list_sheet.dart';

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
    return BlocListener<SheetsBloc, SheetsState>(
      listener: (context, state) {
        if (state.nextSheetState != null &&
            (state.nextSheetState == DraggableBottomSheetState.HIDDEN ||
                widget.draggableBottomSheetController.getSheetState() == DraggableBottomSheetState.HIDDEN)) {
          widget.draggableBottomSheetController.setSheetState(state.nextSheetState);
        }
      },
      child: DraggableBottomSheet(
          controller: widget.draggableBottomSheetController,
          childScrollController: _bottomSheetScrollController,
          topPadding: 0,
          child: BlocBuilder<SheetsBloc, SheetsState>(
            builder: (context, state) {
              Widget sheet;
              if (state is LoadingPoiState) {
                sheet = SearchingBottomSheet();
              } else if (state is LoadFailState) {
                sheet = SearchFaultBottomSheet();
              } else if (state is PoiLoadedState) {
                sheet = PoiBottomSheet(state.poiEntity);
              } else if (state is HeavenPoiLoadedState) {
                //TODO
              } else if (state is ItemsLoadedState) {
                sheet = PoiListSheet(pois: state.items);
              }

              if (sheet == null) {
                sheet = SizedBox.shrink();
              }

              return Stack(
                children: <Widget>[sheet],
              );
            },
          )),
    );
  }
}
