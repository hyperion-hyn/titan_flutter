import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  @override
  AppState get initialState => InitialAppState();

  @override
  Stream<AppState> mapEventToState(AppEvent event) async* {
    // TODO: Add Logic
  }
}
