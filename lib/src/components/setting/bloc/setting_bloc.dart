import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/components/wallet/model.dart';
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
      yield UpdatedSettingState(
          languageModel: event.languageModel, areaModel: event.areaModel);
    } else if (event is SystemConfigEvent) {
      var systemConfigStr = await AppCache.getValue<String>(PrefsKey.SETTING_SYSTEM_CONFIG);

      SystemConfigEntity netSystemConfigEntity = await api.getSystemConfigData();
      if(systemConfigStr != json.encode(netSystemConfigEntity.toJson())){
        _saveSystemConfig(netSystemConfigEntity);
        yield SystemConfigState(netSystemConfigEntity);
      }
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



  Future<bool> _saveSystemConfig(SystemConfigEntity systemConfigEntity) {
    var modelStr = json.encode(systemConfigEntity.toJson());
    return AppCache.saveValue(PrefsKey.SETTING_SYSTEM_CONFIG, modelStr);
  }
}
