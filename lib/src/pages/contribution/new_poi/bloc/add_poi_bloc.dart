import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class AddPoiBloc extends Bloc<AddPoiBlocEvent, AddPoiBlocState> {
  @override
  AddPoiBlocState get initialState => InitialNewPositionBlocState();

  @override
  Stream<AddPoiBlocState> mapEventToState(
    AddPoiBlocEvent event,
  ) async* {
    // TODO: Add Logic
  }
}
