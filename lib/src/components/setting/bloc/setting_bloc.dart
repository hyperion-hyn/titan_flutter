import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/components/quotes/model.dart';
import 'package:titan/src/components/setting/model.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/api/api.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import '../system_config_entity.dart';
import './bloc.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {

  Api api = Api();
  final BuildContext context;
  SettingBloc({this.context});

  @override
  SettingState get initialState => InitialSettingState();

  @override
  Stream<SettingState> mapEventToState(SettingEvent event) async* {
    if (event is UpdateSettingEvent) {
      if (event.languageModel != null) {
        _saveLanguage(event.languageModel);
      }
      if (event.areaModel != null) {
        _saveAreaModel(event.areaModel);
      }
      if (event.quotesSign != null) {
        _saveQuoteSign(event.quotesSign);
      }
      yield UpdatedSettingState(languageModel: event.languageModel, areaModel: event.areaModel, quotesSign: event.quotesSign);
    }else if(event is SystemConfigEvent){
//      Future.delayed(Duration(milliseconds: 2000)).then((value) async* {
//        SystemConfigEntity systemConfigEntity = await api.getSystemConfigData();
//        yield SystemConfigState(systemConfigEntity);
//      });
      SystemConfigEntity systemConfigEntity = await api.getSystemConfigData();
      yield SystemConfigState(systemConfigEntity);
    }
  }

  Future<bool> _saveLanguage(LanguageModel languageModel) {
    var modelStr = json.encode(languageModel.toJson());
    return AppCache.saveValue(PrefsKey.SETTING_LANGUAGE, modelStr);
  }

  Future<bool> _saveAreaModel(AreaModel areaModel) {
    var modelStr = json.encode(areaModel.toJson());
    return AppCache.saveValue(PrefsKey.SETTING_AREA, modelStr);
  }

  Future<bool> _saveQuoteSign(QuotesSign quotesSign) {
    var modelStr = json.encode(quotesSign.toJson());
    return AppCache.saveValue(PrefsKey.SETTING_QUOTE_SIGN, modelStr);
  }
}
