import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import './bloc.dart';

class ScaffoldMapBloc extends Bloc<ScaffoldMapEvent, ScaffoldMapState> {
  final BuildContext context;

  ScaffoldMapBloc(this.context);

  @override
  ScaffoldMapState get initialState => InitialScaffoldMapState();

  @override
  Stream<ScaffoldMapState> mapEventToState(ScaffoldMapEvent event) async* {

  }
}
