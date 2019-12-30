import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/components/setting/model.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import './bloc.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  final BuildContext context;

  SettingBloc({this.context});

  LanguageModel languageModel;
  AreaModel areaModel;

  @override
  SettingState get initialState => InitialSettingState();

  @override
  Stream<SettingState> mapEventToState(SettingEvent event) async* {
    if (event is UpdateAreaEvent) {
      this.areaModel = event.areaModel;
      await _saveAreaModel(this.areaModel);
      yield UpdateSettingState(languageModel: this.languageModel, areaModel: event.areaModel);
    } else if (event is UpdateLanguageEvent) {
      this.languageModel = event.languageModel;
      await _saveLanguage(languageModel);
      yield UpdateSettingState(languageModel: event.languageModel, areaModel: this.areaModel);
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
