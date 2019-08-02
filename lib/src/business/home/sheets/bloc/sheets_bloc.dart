import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/model/poi.dart';
import 'package:titan/src/widget/draggable_bottom_sheet_controller.dart';
import './bloc.dart';

class SheetsBloc extends Bloc<SheetsEvent, SheetsState> {
  final BuildContext context;

  SheetsBloc({this.context});

  @override
  SheetsState get initialState => InitialSheetsState();

  @override
  Stream<SheetsState> mapEventToState(SheetsEvent event) async* {
    if (event is ShowLoadingEvent) {
      yield LoadingPoiState(nextSheetState: DraggableBottomSheetState.COLLAPSED);
    } else if (event is ShowPoiEvent) {
      if (event.poi is PoiEntity) {
        yield PoiLoadedState(poiEntity: event.poi, nextSheetState: DraggableBottomSheetState.COLLAPSED);
      }
      //TODO add heaven poi info
    } else if (event is ShowSearchItemsEvent) {
      yield ItemsLoadedState(items: event.items, nextSheetState: DraggableBottomSheetState.COLLAPSED);
    } else if (event is ShowLoadFailEvent) {
      yield LoadFailState(message: event.message);
    } else if (event is CloseSheetEvent) {
      yield CloseSheetState();
    }
  }
}
