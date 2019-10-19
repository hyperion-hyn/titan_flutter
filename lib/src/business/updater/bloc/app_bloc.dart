import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:titan/env.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/inject/injector.dart';
import './bloc.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  @override
  AppState get initialState => InitialAppState();

  @override
  Stream<AppState> mapEventToState(AppEvent event) async* {
    if (event is CheckUpdate) {
      yield UpdateState(isChecking: true);
      try {
        var injector = Injector.of(Keys.materialAppKey.currentContext);
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

        yield UpdateState(isChecking: false, updateEntity: versionModel, isManual: event.isManual);
      } catch (err) {
        yield UpdateState(isError: true, isChecking: false, isManual: event.isManual);
      }
    }
  }
}
