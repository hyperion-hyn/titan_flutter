import 'package:flutter/widgets.dart';

extension NavigatorExt on NavigatorState {
  void popUntilRouteName<T extends Object>(String routeName, [T result, bool exactMatchRouteName = false]) {
    this.popUntil((r) {
      if (r.isFirst) {
        _setPopResult(r, result);
        return true;
      }

      if (routeName == r.settings?.name) {
        _setPopResult(r, result);
        return true;
      }

      if (!exactMatchRouteName) {
        var rNames = r.settings?.name?.split('?');
        if (rNames != null && rNames[0] == routeName) {
          _setPopResult(r, result);
          return true;
        }
      }
      return false;
    });
  }

  void _setPopResult(route, result) {
    if (route.settings.arguments is Map) {
      (route.settings.arguments as Map)['result'] = result;
    }
  }
}
