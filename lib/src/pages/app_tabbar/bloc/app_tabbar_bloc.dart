import 'dart:async';
import 'package:bloc/bloc.dart';
import 'bloc.dart';

class AppTabBarBloc extends Bloc<AppTabBarEvent, AppTabBarState> {
  @override
  AppTabBarState get initialState => InitialAppTabBarState();

  @override
  Stream<AppTabBarState> mapEventToState(AppTabBarEvent event) async* {
    // TODO: Add Logic
  }
}
