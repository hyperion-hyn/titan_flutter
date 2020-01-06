import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class WalletPageBloc extends Bloc<WalletPageEvent, WalletPageState> {
  @override
  WalletPageState get initialState => InitialWalletPageState();

  @override
  Stream<WalletPageState> mapEventToState(WalletPageEvent event) async* {
    // TODO: Add Logic
  }
}
