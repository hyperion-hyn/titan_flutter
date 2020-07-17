import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class SocketBloc extends Bloc<SocketEvent, SocketState> {
  @override
  SocketState get initialState => InitialSocketState();

  @override
  Stream<SocketState> mapEventToState(
    SocketEvent event,
  ) async* {
    // TODO: Add Logic
  }
}
