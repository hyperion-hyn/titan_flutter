import 'dart:async';

import 'package:flutter/material.dart';
import 'package:titan/src/business/login/login_bus_event.dart';
import 'package:titan/src/business/login/login_page.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/home_build.dart';

import 'global.dart';

class GuidePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GuildState();
  }
}

class _GuildState extends State<GuidePage> {
  UserService _userService = UserService();

  StreamSubscription _eventBusSubscription;

  @override
  void initState() {
    _checkLoginStatus();
    _listenEventBus();
  }

  @override
  Widget build(BuildContext context) {
    print("LOGIN_STATUS:$LOGIN_STATUS");
    if (LOGIN_STATUS == 1) {
      return LoginPage();
    } else if (LOGIN_STATUS == 2) {
      return HomeBuilder();
    } else {
      return Container();
    }
  }

  Future _checkLoginStatus() async {
    var userToken = await _userService.getUserTokenFromSharedpref();
    if (userToken == null) {
      LOGIN_STATUS = 1;
    } else {
      LOGIN_STATUS = 2;
    }
    setState(() {});
  }

  void _listenEventBus() {
    _eventBusSubscription = eventBus.on().listen((event) async {
      print("event:$event");
      if (event is ReloginBusEvent) {
        Navigator.popUntil(context, (r) => r.isFirst);
        await _userService.signOut();
        _checkLoginStatus();
      } else if (event is LoginSuccessBusEvent) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _eventBusSubscription?.cancel();
    super.dispose();
  }
}
