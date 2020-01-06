import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'route_handlers.dart';

class Routes {
  static const String root = "/";
  static const String wallet_manager = '/wallet/manager';

  static void configureRoutes(Router router) {
    router.notFoundHandler = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      print("ROUTE WAS NOT FOUND !!!");
      return Scaffold(body: Center(child: Text('404')));
    });

    router.define(root, handler: rootHandler);
    router.define(wallet_manager, handler: managerWalletHandler);
  }
}
