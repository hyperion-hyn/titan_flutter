import 'package:flutter/widgets.dart';

extension NavigatorExt on NavigatorState {
  void popUntilRouteName<T extends Object>(String routeName, [T result, bool exactMatchRouteName = false]) {
    this.popUntil((r) {
      if (routeName == r.settings?.name) {
        if (r.settings.arguments is Map) {
          (r.settings.arguments as Map)['result'] = result;
        }
        return true;
      }

      if (!exactMatchRouteName) {
        var rNames = r.settings?.name?.split('?');
        if (rNames != null && rNames[0] == routeName) {
          if (r.settings.arguments is Map) {
            (r.settings.arguments as Map)['result'] = result;
          }
          return true;
        }
      }
      return false;
    });
  }
}
