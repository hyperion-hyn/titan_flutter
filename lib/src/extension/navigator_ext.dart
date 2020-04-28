import 'package:flutter/widgets.dart';

extension NavigatorExt on NavigatorState {
  void popUntilRouteName<T extends Object>(String routeName, [T result, bool exactMatchRouteName = false]) {
    this.popUntil((route) {
      if (route.isFirst) {
        _setPopResult(route, result);
        return true;
      }

      if (routeName == route.settings?.name) {
        _setPopResult(route, result);
        return true;
      }

      if (!exactMatchRouteName) {
        var rNames = route.settings?.name?.split('?');
        if (rNames != null && rNames[0] == routeName) {
          _setPopResult(route, result);
          return true;
        }
      }
      return false;
    });
  }

  void _setPopResult(route, result) {
    print("[navigation] route.settings.arguments:${route.settings.arguments}, result:$result");
    var arguments = route.settings.arguments;
    if (arguments is Map) {
      (route.settings.arguments as Map)['result'] = result;
    }
  }
}
