import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:titan/env.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/components/inject/injector.dart';
import 'package:titan/src/global.dart';
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
        var injector = Injector.of(context);
        var channel = "";
        if (env.channel == BuildChannel.OFFICIAL) {
          channel = "official";
        } else if (env.channel == BuildChannel.STORE) {
          channel = "store";
        }

        var platform = "";
        if (Platform.isAndroid) {
          platform = "android";
        } else if (Platform.isIOS) {
          platform = "ios";
        }
        var versionModel = await injector.repository.checkNewVersion(channel, event.lang, platform);

        yield UpdateCheckState(isChecking: false, updateEntity: versionModel, isManual: event.isManual);
      } catch (err) {
        logger.e(err);
        yield UpdateCheckState(isError: true, isChecking: false, isManual: event.isManual);
      }
    }
  }
}
