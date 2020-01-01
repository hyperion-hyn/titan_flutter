import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:titan/src/business/position/api/position_api.dart';
import './bloc.dart';

class PositionBloc extends Bloc<PositionEvent, PositionState> {

  PositionApi _positionApi= PositionApi();

  @override
  PositionState get initialState => InitialPositionState();

  @override
  Stream<PositionState> mapEventToState(
    PositionEvent event,
  ) async* {
    if(event is AddPositionEvent){
      yield AddPositionState();
    }else if(event is SelectCategoryLoadingEvent){
      yield SelectCategoryLoadingState();
    }else if(event is SelectCategoryResultEvent){
      var categoryList = await _positionApi.getCategoryList(event.searchText);

      yield SelectCategoryResultState(categoryList: categoryList);
    }
  }
}
