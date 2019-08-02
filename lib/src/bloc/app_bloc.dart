import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import './bloc.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final BuildContext context;

  AppBloc({this.context});


  @override
  AppState get initialState => InitialAppState();

  @override
  Stream<AppState> mapEventToState(AppEvent event) async* {
    // TODO: Add Logic
  }
}
