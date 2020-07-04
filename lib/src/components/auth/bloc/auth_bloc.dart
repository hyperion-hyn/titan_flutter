import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:titan/src/components/auth/model.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import './bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {

  @override
  AuthState get initialState => InitialAuthState();

  @override
  Stream<AuthState> mapEventToState(
    AuthEvent event,
  ) async* {
    // TODO: Add Logic
    if (event is InitAuthConfigEvent) {
      yield InitAuthConfigState(authConfigModel: event.authConfigModel);
    } else if (event is SaveAuthConfigEvent) {
      yield SaveAuthConfigState(event.walletFileName, event.authConfigModel);
    } else if (event is SetBioAuthEvent) {
      yield SetBioAuthState(event.value, event.walletFileName);
    }  else if (event is RefreshBioAuthConfigEvent) {
      yield RefreshBioAuthConfigState(event.walletFileName);
    }
  }
}
