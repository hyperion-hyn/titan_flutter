import 'package:bloc/bloc.dart';

import '../../global.dart';

class AppBlocDelegate extends BlocDelegate {

  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print('onEvent ${event.toString()}');
  }

  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    logger.e(error);
  }
}
