import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/components/setting/model.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import './bloc.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
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

      yield UpdatedSettingState(languageModel: event.languageModel, areaModel: event.areaModel);
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
}
