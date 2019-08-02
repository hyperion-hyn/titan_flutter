import 'package:meta/meta.dart';
import 'package:titan/src/model/poi.dart';
import 'package:titan/src/widget/draggable_bottom_sheet_controller.dart';

import '../../../../store.dart';

@immutable
abstract class SheetsState {
  static Map<String, dynamic> get store => getStoreOfGlobal('sheetState');

  static DraggableBottomSheetState get sheetState => store['SheetsState.sheetState'];

  static set sheetState(DraggableBottomSheetState state) => store['SheetsState.sheetState'] = state;

  final DraggableBottomSheetState nextSheetState;

  SheetsState({this.nextSheetState}) {
    if (nextSheetState != null) {
      sheetState = nextSheetState;
    }
  }
}

class InitialSheetsState extends SheetsState {}

class LoadingPoiState extends SheetsState {
  LoadingPoiState({DraggableBottomSheetState nextSheetState}) : super(nextSheetState: nextSheetState);
}

class PoiLoadedState extends SheetsState {
  final PoiEntity poiEntity;

  PoiLoadedState({this.poiEntity, DraggableBottomSheetState nextSheetState}) : super(nextSheetState: nextSheetState);
}

class HeavenPoiLoadedState extends SheetsState {
  final dynamic poi;

  HeavenPoiLoadedState({this.poi, DraggableBottomSheetState nextSheetState}) : super(nextSheetState: nextSheetState);
}

class LoadFailState extends SheetsState {
  final String message;

  LoadFailState({this.message});
}

class ItemsLoadedState extends SheetsState {
  final List<dynamic> items;

  ItemsLoadedState({this.items, DraggableBottomSheetState nextSheetState}) : super(nextSheetState: nextSheetState);
}

class CloseSheetState extends SheetsState {
  CloseSheetState() : super(nextSheetState: DraggableBottomSheetState.HIDDEN);
}
