import 'package:titan/src/business/scaffold_map/dapp/dapp_define.dart';
import 'package:titan/src/model/poi_interface.dart';

class ScaffoldMapStore {
  IPoi currentPoi;
  List<IPoi> searchPoiList = [];
  DAppDefine dapp = DAppDefine.NONE;

  ScaffoldMapStore._();

  static final ScaffoldMapStore shared = ScaffoldMapStore._();


}