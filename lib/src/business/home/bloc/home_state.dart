import 'package:meta/meta.dart';
import 'package:titan/src/model/poi.dart';
import 'package:titan/src/widget/draggable_bottom_sheet_controller.dart';

import '../../../store.dart';

@immutable
abstract class HomeState {
  Map<String, dynamic> get store => getStoreOfGlobal('homeState');

  dynamic get selectedPoi => store['HomeState.selectedPoi'];

  set selectedPoi(dynamic poi) => store['HomeState.selectedPoi'] = poi;
}

class InitialHomeState extends HomeState {}

class HomeSearchState extends HomeState {
  HomeSearchState({
    bool isInSearchMode,
    bool isFetching,
    bool isSearchFault,
    String searchText,
    List<PoiEntity> searchResultItems,
  }) {
    if (isInSearchMode != null) store['HomeSearchState.isInSearchMode'] = isInSearchMode;
    if (isFetching != null) store['HomeSearchState.isFetching'] = isFetching;
    if (isFetching != null) store['HomeSearchState.isSearchFault'] = isSearchFault;
    if (searchText != null) store['HomeSearchState.searchText'] = searchText;
    if (searchResultItems != null) store['HomeSearchState.searchResultItems'] = searchResultItems;
  }

  bool get isInSearchMode => store['HomeSearchState.isInSearchMode'];

  bool get isFetching => store['HomeSearchState.isFetching'];

  String get searchText => store['HomeSearchState.searchText'];

  List<dynamic> get searchResultItems => store['HomeSearchState.searchResultItems'];

  bool get isSearchFault => store['HomeSearchState.isSearchFault'];

  @override
  Map<String, dynamic> get store => getStoreOfGlobal('home.search');
}

///bottom sheet state
class BottomSheetState extends HomeState {
  DraggableBottomSheetState get state => store['BottomSheetState.state'];

  bool get isFetchingPoiInfo => store['BottomSheetState.isFetchingPoiInfo'];

  bool get isFetchFault => store['BottomSheetState.isFetchFault'];

  BottomSheetState({DraggableBottomSheetState state, bool isFetchFault, bool isFetchingPoiInfo, dynamic activePoi}) {
    if (state != null) store['BottomSheetState.state'] = state;
    if (isFetchFault != null) store['BottomSheetState.isFetchFault'] = isFetchFault;
    if (isFetchingPoiInfo != null) store['BottomSheetState.isFetchingPoiInfo'] = isFetchingPoiInfo;
    if (activePoi != null) selectedPoi = activePoi;
  }
}
