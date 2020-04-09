import 'package:meta/meta.dart';
import 'package:titan/src/pages/discover/dapp/ncov/model/ncov_poi_entity.dart';

@immutable
abstract class NcovState {}

class InitialNcovState extends NcovState {}

class LoadPoiPanelState extends NcovState {
  NcovPoiEntity ncovPoiEntity;
  LoadPoiPanelState(this.ncovPoiEntity);
}

class ShowPoiPanelState extends NcovState {
  NcovPoiEntity ncovPoiEntity;
  ShowPoiPanelState(this.ncovPoiEntity);
}

class ClearSelectPoiState extends NcovState {
}
