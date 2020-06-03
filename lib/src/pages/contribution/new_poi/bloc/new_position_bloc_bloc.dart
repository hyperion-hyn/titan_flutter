import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class NewPositionBlocBloc extends Bloc<NewPositionBlocEvent, NewPositionBlocState> {
  @override
  NewPositionBlocState get initialState => InitialNewPositionBlocState();

  @override
  Stream<NewPositionBlocState> mapEventToState(
    NewPositionBlocEvent event,
  ) async* {
    // TODO: Add Logic
  }
}
