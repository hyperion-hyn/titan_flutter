import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/inject/injector.dart';
import 'package:titan/src/widget/draggable_bottom_sheet_controller.dart';
import './bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  @override
  HomeState get initialState => InitialHomeState();

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    if (event is SelectedPoiEvent) {
      yield BottomSheetState(
        state: DraggableBottomSheetState.COLLAPSED,
        isFetchFault: false,
        isFetchingPoiInfo: false,
        activePoi: event.selectedPoi,
      );
    } else if (event is ClosePoiBottomSheetEvent) {
      yield BottomSheetState(state: DraggableBottomSheetState.HIDDEN);
    } else if (event is SearchPoiListEvent) {
      try {
        var injector = Injector.of(Keys.materialAppKey.currentContext);
        var homeState =
            HomeSearchState(isInSearchMode: true, isFetching: true, isSearchFault: false, searchText: event.searchText);

        yield homeState;

        var items = await injector.searchInteractor.searchPoiByMapbox(event.searchText, event.center, event.language);
        //if is not cancelled
        if (homeState.isInSearchMode) {
          yield BottomSheetState(state: DraggableBottomSheetState.ANCHOR_POINT);
          yield HomeSearchState(isFetching: false, searchResultItems: items);
        }
      } catch (err) {
        print(err.toString());
        yield HomeSearchState(isFetching: false, isSearchFault: true);
      }
    } else if (event is ClearSearchMode) {
      yield BottomSheetState(state: DraggableBottomSheetState.HIDDEN);
      yield HomeSearchState(isInSearchMode: false);
    }
  }
}
