import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:titan/env.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/components/inject/injector.dart';
import 'bloc.dart';

class UpdateBloc extends Bloc<UpdateEvent, UpdateState> {
  @override
  UpdateState get initialState => InitialAppState();

  @override
  Stream<UpdateState> mapEventToState(UpdateEvent event) async* {
    if (event is CheckUpdate) {
      yield UpdateCheckState(isChecking: true);
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

        yield UpdateCheckState(isChecking: false, updateEntity: versionModel, isManual: event.isManual);
      } catch (err) {
        yield UpdateCheckState(isError: true, isChecking: false, isManual: event.isManual);
      }
    }
  }
}
