import 'package:meta/meta.dart';
import 'package:titan/src/business/discover/dapp/ncov/model/ncov_poi_entity.dart';

@immutable
abstract class NcovEvent {}

class ShowPoiPanelEvent extends NcovEvent {
  NcovPoiEntity ncovPoiEntity;
  ShowPoiPanelEvent(this.ncovPoiEntity);
}

class ClearSelectPoiEvent extends NcovEvent {
}


