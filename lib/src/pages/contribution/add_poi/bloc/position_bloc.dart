import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/entity/poi/user_contribution_poi.dart';
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
        if (event.language.startsWith('zh')) event.language = "zh-Hans";
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String countryCode = prefs.getString(PrefsKey.mapboxCountryCode) ?? "CN";
        var categoryList =
        await _positionApi.getCategoryList("", event.address, lang: event.language, countryCode: countryCode);

        yield SelectCategoryInitState(categoryList);
      } else if (event is SelectCategoryLoadingEvent) {
        yield SelectCategoryLoadingState();
      } else if (event is SelectCategoryResultEvent) {
        if (event.language.startsWith('zh')) event.language = "zh-Hans";
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String countryCode = prefs.getString(PrefsKey.mapboxCountryCode) ?? "CN";
        var categoryList = await _positionApi.getCategoryList(event.searchText, event.address,
            lang: event.language, countryCode: countryCode);
        yield SelectCategoryResultState(categoryList: categoryList);
      } else if (event is SelectCategoryClearEvent) {
        yield SelectCategoryClearState();
      } else if (event is GetOpenCageEvent) {
        yield GetOpenCageLoadingState();

        var userPosition = event.userPosition;
        var query = "${userPosition.latitude},${userPosition.longitude}";
//        var language = (appLocale ?? defaultLocale).languageCode;
        if (event.language != null && event.language.startsWith('zh')) event.language = "zh-Hans";
        var _openCageData = await _positionApi.getOpenCageData(query, lang: event.language);
        yield GetOpenCageState(_openCageData);
      }

      // poi
      else if (event is StartPostPoiDataEvent) {
        await _uploadPoiData(event.poiDataModel, event.address);
        yield StartPostPoiDataState();
      } else if (event is LoadingPostPoiDataEvent) {
        yield LoadingPostPoiDataState(event.progress);
      } else if (event is SuccessPostPoiDataEvent) {
        yield SuccessPostPoiDataState();
      } else if (event is FailPostPoiDataEvent) {
        yield FailPostPoiDataState(event.code);
      }

      // poi v2
      else if (event is PostPoiDataV2Event) {
        yield PostPoiDataV2LoadingState();

        var model = event.poiDataModel;
        int code = await _positionApi.postPoiV2Collector(
            model.outListImagePaths, model.inListImagePaths, event.address, model.poiCollector, (int count, int total) {
          double progress = count * 100.0 / total;
          //print("[PoiBloc] progress:$progress");

          //add(LoadingPostPoiDataEvent(progress));
        });

        if (code == 0) {
          yield PostPoiDataV2ResultSuccessState();
        } else {
          yield PostPoiDataV2ResultFailState(code: code);
        }
      }

      // getConfirmData
      else if (event is GetConfirmPoiDataEvent) {
        yield GetConfirmPoiDataLoadingState();

        var userPosition = event.userPosition;
        if (event.language.startsWith('zh')) event.language = "zh-Hans";
        var _confirmPoiItem = await _positionApi.getConfirmData(
            event.address, userPosition.longitude, userPosition.latitude,
            lang: event.language, id: event.id);
        if (_confirmPoiItem == null) {
          yield GetConfirmPoiDataResultFailState();
        } else {
          yield GetConfirmPoiDataResultSuccessState(_confirmPoiItem);
        }
      }

      // PostConfirmPoiDataEvent
      else if (event is PostConfirmPoiDataEvent) {
        yield PostConfirmPoiDataLoadingState();

        var confirmResult = await _positionApi.postConfirmPoiData(event.address, event.answer, event.confirmPoiItem,
            detail: event.detail);
        print("[PositionBloc] poi confirm result = $confirmResult");

        if (confirmResult) {
          yield PostConfirmPoiDataResultSuccessState();
        } else {
          yield PostConfirmPoiDataResultFailState();
        }
      }

      // getConfirmDataV2
      else if (event is GetConfirmPoiDataV2Event) {
        yield GetConfirmDataV2LoadingState();

        var userPosition = event.userPosition;
        if (event.language.startsWith('zh')) event.language = "zh-Hans";
        var res =
            await _positionApi.getConfirmV2Data(userPosition.longitude, userPosition.latitude, lang: event.language);

        var responseEntity = ResponseEntity<UserContributionPois>.fromJson(res,
            factory: EntityFactory((json){
            return UserContributionPois.fromJson(json);
            }));
        if (responseEntity.data == null || responseEntity.code != 0) {
          yield GetConfirmDataV2ResultFailState(code: responseEntity.code, message: responseEntity.msg);
        } else {
          var _confirmPoiItem = responseEntity.data;
          yield GetConfirmDataV2ResultSuccessState(_confirmPoiItem);
        }
      }

      // postConfirmPoiDataV2
      else if (event is PostConfirmPoiDataV2Event) {
        yield PostConfirmPoiDataV2LoadingState();

        var res = await _positionApi.postConfirmPoiV2Data(event.answers, event.contributionPois);
        var responseEntity = ResponseEntity<List<String>>.fromJson(res, factory: EntityFactory((json) {
          var list = (json as List).map((item) {
            return "$item";
          }).toList();
          print("[PositionApi] postConfirmPoiDataV2, json:$json, list:$list");

          return list;
        }));

        print("[PositionBloc] postConfirmPoiDataV2, result = ${responseEntity.data}");

        if (responseEntity.data == null || responseEntity.code != 0) {
          yield PostConfirmPoiDataV2ResultFailState(code: responseEntity.code, message: responseEntity.msg);
        } else {
          yield PostConfirmPoiDataV2ResultSuccessState(responseEntity.data);
        }
      } else if (event is ConfirmPositionResultLoadingEvent) {
        yield ConfirmPositionResultLoadingState();
      }
      // update
      else if (event is UpdateConfirmPoiDataPageEvent) {
        yield UpdateConfirmPoiDataPageState();
      }
      // poi ncov
      else if (event is StartPostPoiNcovDataEvent) {
        await _uploadPoiNcovData(event.poiDataModel, event.address);
        yield StartPostPoiNcovDataState();
      } else if (event is LoadingPostPoiNcovDataEvent) {
        yield LoadingPostPoiNcovDataState(event.progress);
      } else if (event is SuccessPostPoiNcovDataEvent) {
        yield SuccessPostPoiNcovDataState();
      } else if (event is FailPostPoiNcovDataEvent) {
        yield FailPostPoiNcovDataState(event.code);
      }
    } catch (code, message) {
      yield LoadFailState(message: S.of(Keys.rootKey.currentContext).net_error_hint);
    }
  }

  Future _uploadPoiData(PoiDataModel model, String address) async {
    int code =
    await _positionApi.postPoiCollector(model.listImagePaths, address, model.poiCollector, (int count, int total) {
      double progress = count * 100.0 / total;
      add(LoadingPostPoiDataEvent(progress));
    });

    if (code == 0) {
      add(SuccessPostPoiDataEvent());
    } else {
      add(FailPostPoiDataEvent(code));
    }
  }

  Future _uploadPoiNcovData(PoiNcovDataModel model, String address) async {
//    var address = currentWalletVo.accountList[0].account.address;
    int code = await _positionApi.postPoiNcovCollector(model.listImagePaths, address, model.poiCollector,
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
