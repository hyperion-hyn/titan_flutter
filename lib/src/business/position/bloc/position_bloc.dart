import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:titan/src/business/position/api/position_api.dart';
import 'package:titan/src/business/position/model/poi_data.dart';
import 'package:titan/src/global.dart';
import './bloc.dart';

class PositionBloc extends Bloc<PositionEvent, PositionState> {
  PositionApi _positionApi = PositionApi();

  @override
  PositionState get initialState => InitialPositionState();

  @override
  Stream<PositionState> mapEventToState(PositionEvent event,) async* {
    if (event is AddPositionEvent) {
      yield AddPositionState();
    } else if (event is SelectCategoryInitEvent) {
      yield SelectCategoryInitState();
    } else if (event is SelectCategoryLoadingEvent) {
      yield SelectCategoryLoadingState();
    } else if (event is SelectCategoryResultEvent) {
      var address = currentWalletVo.accountList[0].account.address;
      var categoryList =
      await _positionApi.getCategoryList(event.searchText, address);
      yield SelectCategoryResultState(categoryList: categoryList);
    } else if (event is SelectCategoryClearEvent) {
      yield SelectCategoryClearState();
    } else if (event is GetOpenCageEvent) {
      var userPosition = event.userPosition;
      var query = "${userPosition.latitude},${userPosition.longitude}";
      var language = (appLocale??defaultLocale).languageCode;
      var _openCageData = await _positionApi.getOpenCageData(query, lang: language);
      yield GetOpenCageState(_openCageData);
    } else if (event is StartPostPoiDataEvent) {
      await _uploadPoiData(event.poiDataModel);
      yield StartPostPoiDataState();
    } else if (event is LoadingPostPoiDataEvent) {
      yield LoadingPostPoiDataState(event.progress);
    } else if (event is SuccessPostPoiDataEvent) {
      yield SuccessPostPoiDataState();
    } else if (event is FailPostPoiDataEvent) {
      yield FailPostPoiDataState();
    } else if (event is ConfirmPositionLoadingEvent) {
      yield ConfirmPositionLoadingState();
    } else if (event is ConfirmPositionPageEvent) {
      var userPosition = event.userPosition;
      var language = (appLocale??defaultLocale).languageCode;
      var _confirmPoiItem = await _positionApi.getConfirmData(userPosition.longitude,userPosition.latitude,lang: language);
      yield ConfirmPositionPageState(_confirmPoiItem);
    } else if (event is ConfirmPositionResultEvent) {
      try{
        var confirmResult = await _positionApi.postConfirmPoiData(event.answer,event.confirmPoiItem);
        print("[PositionBloc] poi confirm result = $confirmResult");
        yield ConfirmPositionResultState(true);
      }catch(code,message){
        yield ConfirmPositionResultState(false);
      }
    }else if (event is ConfirmPositionResultLoadingEvent){
      yield ConfirmPositionResultLoadingState();
    }
  }


  Future _uploadPoiData(PoiDataModel model) async {
    var address = currentWalletVo.accountList[0].account.address;
    bool isFinish = await _positionApi.postPoiCollector(model.listImagePaths, address, model.poiCollector, (int count, int total) {
      double progress = count * 100.0 / total;
      //print('[upload] total:$total, count:$count, progress:$progress%');
      add(LoadingPostPoiDataEvent(progress));
    });

    if (isFinish) {
      add(SuccessPostPoiDataEvent());
    } else {
      add(FailPostPoiDataEvent());
    }
  }

}
