import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:titan/src/business/position/api/position_api.dart';
import 'package:titan/src/global.dart';
import './bloc.dart';

class PositionBloc extends Bloc<PositionEvent, PositionState> {
  PositionApi _positionApi = PositionApi();

  @override
  PositionState get initialState => InitialPositionState();

  @override
  Stream<PositionState> mapEventToState(
    PositionEvent event,
  ) async* {
    if (event is AddPositionEvent) {
      yield AddPositionState();
    } else if (event is SelectCategoryLoadingEvent) {
      yield SelectCategoryLoadingState();
    } else if (event is SelectCategoryResultEvent) {
      var address = currentWalletVo.accountList[0].account.address;
      var categoryList =
          await _positionApi.getCategoryList(event.searchText, address);
      yield SelectCategoryResultState(categoryList: categoryList);
    } else if (event is SelectCategoryClearEvent) {
      yield SelectCategoryClearState();
    } else if (event is ConfirmPositionLoadingEvent) {
      yield ConfirmPositionLoadingState();
    } else if (event is ConfirmPositionResultEvent) {
      yield ConfirmPositionResultState();
    }
  }
}
