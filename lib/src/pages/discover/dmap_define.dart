import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/pages/discover/dapp/encrypt_share/encrypt_share.dart';
import 'package:titan/src/components/scaffold_map/dmap/dmap.dart';
import 'package:titan/src/pages/global_data/global_data.dart';

import '../../pages/discover/dapp/embassy/embassy.dart';
import '../../pages/discover/dapp/nightlife/nightlife.dart';
import '../../pages/discover/dapp/police_service/police_service.dart';

typedef CreateDAppWidgetFunction = Widget Function(BuildContext context);

class DMapCreationModel {
  final CreateDAppWidgetFunction createDAppWidgetFunction;
  final DMapConfigModel dMapConfigModel;

  DMapCreationModel({
    this.createDAppWidgetFunction,
    this.dMapConfigModel,
  });
}

class DMapDefine {
  static Map<String, DMapCreationModel> kMapList = {
    'embassy': DMapCreationModel(
      dMapConfigModel: embassyDMapConfigModel,
      createDAppWidgetFunction: (context) => Embassy(),
    ),
    'nightlife': DMapCreationModel(
      dMapConfigModel: nightLifeDMapConfigModel,
      createDAppWidgetFunction: (context) => NightLife(),
    ),
    'policeStation': DMapCreationModel(
      dMapConfigModel: policeDMapConfigModel,
      createDAppWidgetFunction: (context) => PoliceService(),
    ),
    'encryptShare': DMapCreationModel(
      dMapConfigModel: encryptShareDMapConfigModel,
      createDAppWidgetFunction: (context) => EncryptShare(),
    ),
    'poi': DMapCreationModel(
      dMapConfigModel: poiDMapConfigModel,
      createDAppWidgetFunction: (context) => EncryptShare(),
    )
  };
}
