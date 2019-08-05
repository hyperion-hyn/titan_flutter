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
                widget.draggableBottomSheetController.getSheetState() == DraggableBottomSheetState.HIDDEN ||
                widget.draggableBottomSheetController.getSheetState() == DraggableBottomSheetState.EXPANDED)) {
          widget.draggableBottomSheetController.setSheetState(state.nextSheetState);
        }
      },
      child: DraggableBottomSheet(
          controller: widget.draggableBottomSheetController,
          childScrollController: _bottomSheetScrollController,
          //paddingtop + search height + paddingbottom - draggable height - threshold
          topPadding: (MediaQuery.of(context).padding.top + 48 + 8 - 12 - 4),
          child: BlocBuilder<SheetsBloc, SheetsState>(
            builder: (context, state) {
              Widget sheet;
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
                //TODO
              } else if (state is ItemsLoadedState) {
                sheet = PoiListSheet(pois: state.items, scrollController: _bottomSheetScrollController,);
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
