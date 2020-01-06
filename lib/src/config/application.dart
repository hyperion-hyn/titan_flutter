import 'package:event_bus/event_bus.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';

class Application {
  static Router router;

  static RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  /// The global [EventBus] object.
  static EventBus eventBus = EventBus();
}
