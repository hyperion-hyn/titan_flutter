import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:titan/env.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/components/inject/injector.dart';
import 'package:titan/src/data/entity/update.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'bloc.dart';

class UpdateBloc extends Bloc<UpdateEvent, UpdateState> {
  BuildContext context;

  UpdateBloc({this.context});

  @override
  UpdateState get initialState => InitialAppState();

  @override
  Stream<UpdateState> mapEventToState(UpdateEvent event) async* {
    if (event is CheckUpdate) {
      yield UpdateCheckState(isChecking: true);
      try {
        var appUpdateInfo;
        try {
          appUpdateInfo = await AtlasApi.checkUpdate();
        } catch (e) {}
        yield UpdateCheckState(
          isChecking: false,
          appUpdateInfo: appUpdateInfo,
          isManual: event.isManual,
        );
      } catch (err) {
        logger.e(err);
        yield UpdateCheckState(
          isError: true,
          isChecking: false,
          isManual: event.isManual,
        );
      }
    }
  }
}
