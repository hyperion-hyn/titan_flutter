import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/pages/contribution/add_poi/api/position_api.dart';
import 'package:titan/src/pages/contribution/add_poi/model/poi_data.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';
import 'bloc.dart';

class PositionBloc extends Bloc<PositionEvent, AllPageState> {
  PositionApi _positionApi = PositionApi();

  @override
  PositionState get initialState => InitialPositionState();

  @override
  Stream<AllPageState> mapEventToState(
    PositionEvent event,
  ) async* {
    try {
      if (event is AddPositionEvent) {
        yield AddPositionState();
      }
      // category
      else if (event is SelectCategoryInitEvent) {
        yield SelectCategoryLoadingState(isShowSearch: false);
//        var address = currentWalletVo.accountList[0].account.address;
//        var language = (appLocale ?? defaultLocale).languageCode;
        if (event.language.startsWith('zh')) event.language = "zh-Hans";
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String countryCode =
            prefs.getString(PrefsKey.mapboxCountryCode) ?? "CN";
        var categoryList = await _positionApi.getCategoryList("", event.address,
            lang: event.language, countryCode: countryCode);

        yield SelectCategoryInitState(categoryList);
      } else if (event is SelectCategoryLoadingEvent) {
        yield SelectCategoryLoadingState();
      } else if (event is SelectCategoryResultEvent) {
//        var address = currentWalletVo.accountList[0].account.address;
//        var language = (appLocale ?? defaultLocale).languageCode;
        if (event.language.startsWith('zh')) event.language = "zh-Hans";
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String countryCode =
            prefs.getString(PrefsKey.mapboxCountryCode) ?? "CN";
        var categoryList = await _positionApi.getCategoryList(
            event.searchText, event.address,
            lang: event.language, countryCode: countryCode);
        yield SelectCategoryResultState(categoryList: categoryList);
      } else if (event is SelectCategoryClearEvent) {
        yield SelectCategoryClearState();
      } else if (event is GetOpenCageEvent) {
        var userPosition = event.userPosition;
        var query = "${userPosition.latitude},${userPosition.longitude}";
//        var language = (appLocale ?? defaultLocale).languageCode;
        if (event.language != null && event.language.startsWith('zh')) event.language = "zh-Hans";
        var _openCageData =
            await _positionApi.getOpenCageData(query, lang: event.language);
        yield GetOpenCageState(_openCageData);
      }
      // poi
      else if (event is StartPostPoiDataEvent) {
        await _uploadPoiData(event.poiDataModel,event.address);
        yield StartPostPoiDataState();
      } else if (event is LoadingPostPoiDataEvent) {
        yield LoadingPostPoiDataState(event.progress);
      } else if (event is SuccessPostPoiDataEvent) {
        yield SuccessPostPoiDataState();
      } else if (event is FailPostPoiDataEvent) {
        yield FailPostPoiDataState(event.code);
      } else if (event is ConfirmPositionLoadingEvent) {
        yield ConfirmPositionLoadingState();
      } else if (event is ConfirmPositionPageEvent) {
        var userPosition = event.userPosition;
//        var language = (appLocale ?? defaultLocale).languageCode;
        if (event.language.startsWith('zh')) event.language = "zh-Hans";
        var _confirmPoiItem = await _positionApi.getConfirmData(event.address,
            userPosition.longitude, userPosition.latitude,
            lang: event.language);
        yield ConfirmPositionPageState(_confirmPoiItem);
      } else if (event is ConfirmPositionResultEvent) {
        var confirmResult = await _positionApi.postConfirmPoiData(event.address,
            event.answer, event.confirmPoiItem);
        print("[PositionBloc] poi confirm result = $confirmResult");
        yield ConfirmPositionResultState(true, "");
      } else if (event is ConfirmPositionResultLoadingEvent) {
        yield ConfirmPositionResultLoadingState();
      }
      // poi ncov
      else if (event is StartPostPoiNcovDataEvent) {
        await _uploadPoiNcovData(event.poiDataModel,event.address);
        yield StartPostPoiNcovDataState();
      } else if (event is LoadingPostPoiNcovDataEvent) {
        yield LoadingPostPoiNcovDataState(event.progress);
      } else if (event is SuccessPostPoiNcovDataEvent) {
        yield SuccessPostPoiNcovDataState();
      } else if (event is FailPostPoiNcovDataEvent) {
        yield FailPostPoiNcovDataState(event.code);
      }
    } catch (code, message) {
      yield LoadFailState();
    }
  }

  Future _uploadPoiData(PoiDataModel model,String address) async {
//    var address = currentWalletVo.accountList[0].account.address;
    int code = await _positionApi
        .postPoiCollector(model.listImagePaths, address, model.poiCollector,
            (int count, int total) {
      double progress = count * 100.0 / total;
      //print('[upload] total:$total, count:$count, progress:$progress%');
      add(LoadingPostPoiDataEvent(progress));
    });

    if (code == 0) {
      add(SuccessPostPoiDataEvent());
    } else {
      add(FailPostPoiDataEvent(code));
    }
  }

  Future _uploadPoiNcovData(PoiNcovDataModel model,String address) async {
//    var address = currentWalletVo.accountList[0].account.address;
    int code = await _positionApi
        .postPoiNcovCollector(model.listImagePaths, address, model.poiCollector,
            (int count, int total) {
          double progress = count * 100.0 / total;
          //print('[upload] total:$total, count:$count, progress:$progress%');
          add(LoadingPostPoiNcovDataEvent(progress));
        });

    if (code == 0) {
      add(SuccessPostPoiNcovDataEvent());
    } else {
      add(FailPostPoiNcovDataEvent(code));
    }
  }

}
