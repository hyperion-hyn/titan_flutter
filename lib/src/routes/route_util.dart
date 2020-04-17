import 'package:flutter/cupertino.dart';

class RouteUtil {
  static String encodeRouteNameWithoutParams(BuildContext context) {
    var route = ModalRoute.of(context);
    return Uri.encodeComponent(route.settings?.name?.split('?')[0] ?? '/');
  }
}
