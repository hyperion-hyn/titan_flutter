import 'package:bloc/bloc.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:titan/src/components/socket/bloc/bloc.dart';

import '../../../env.dart';
import '../../global.dart';

class AppBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);

    if (ReceivedDataEvent != event.runtimeType) {
      print('onEvent ${event.toString()}');
    }
  }

  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);

    if (![ReceivedDataSuccessState, ChannelKLine24HourState, HeartSuccessState].contains(transition.currentState.runtimeType)) {
      print(transition);
    }
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    if (env.buildType == BuildType.PROD) {
      FlutterBugly.uploadException(message: error.toString(), detail: stacktrace?.toString() ?? error.toString());
    }
    logger.e(error);
  }
}
