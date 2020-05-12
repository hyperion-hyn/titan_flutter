import 'dart:io';

import 'package:event_bus/event_bus.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/routes/routes.dart';

class Application {
  //-----------------
  // route
  //-----------------
  static MyRouter router;
  static RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  /// The global [EventBus] object.
  static EventBus eventBus = EventBus();

  //-----------------
  //app global vars
  //-----------------
  //default set to guangzhou tower center
  static LatLng recentlyLocation = LatLng(23.10901, 113.31799);

  //-----------------
  // Announce
  //-----------------
  static bool isUpdateAnnounce = false;
}

class ClearBadgeEvent {}
