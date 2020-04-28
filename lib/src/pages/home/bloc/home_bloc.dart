import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';

import 'bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  BuildContext context;
  HomeBloc(this.context);

  @override
  HomeState get initialState => InitialHomeState();

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
  }

}
