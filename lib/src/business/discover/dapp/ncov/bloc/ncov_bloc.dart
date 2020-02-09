import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class NcovBloc extends Bloc<NcovEvent, NcovState> {
  @override
  NcovState get initialState => InitialNcovState();

  @override
  Stream<NcovState> mapEventToState(
    NcovEvent event,
  ) async* {
    // TODO: Add Logic
  }
}
