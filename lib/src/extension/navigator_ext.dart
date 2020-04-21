import 'package:flutter/widgets.dart';

extension NavigatorExt on NavigatorState {
  void popUntilRouteName<T extends Object>(String routeName, [T result, bool exactMatchRouteName = false]) {
    this.popUntil((r) {
      if (r.isFirst) {
        return true;
      }
      print("[navigation] -------1, routeName$routeName, result:$result");

      if (routeName == r.settings?.name) {
        if (r.settings.arguments is Map) {
          print("[navigation] -------2, routeName$routeName, result:$result");
          (r.settings.arguments as Map)['result'] = result;
        }
        return true;
      }

      if (!exactMatchRouteName) {
        var rNames = r.settings?.name?.split('?');
        if (rNames != null && rNames[0] == routeName) {
          if (r.settings.arguments is Map) {
            print("[navigation] -------3, routeName$routeName, result:$result");

            (r.settings.arguments as Map)['result'] = result;
          }
          return true;
        }
      }
      return false;
    });
  }
}
