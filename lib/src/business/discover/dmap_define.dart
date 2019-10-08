import 'package:flutter/widgets.dart';

import 'dapp/embassy/embassy.dart';
import 'dapp/nightlife/nightlife.dart';
import 'dapp/police_service/police_service.dart';

typedef CreateDAppWidgetFunction = Widget Function(BuildContext context);

class DMapDefine {
  static Map<String, CreateDAppWidgetFunction> kMapList = {
    'embassy': (context) {
      return Embassy();
    },
    'nightlife': (context) {
      return NightLife();
    },
    'policeService': (context) {
      return PoliceService();
    },
  };
}