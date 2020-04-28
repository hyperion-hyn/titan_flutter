import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:titan/src/pages/contribution/add_poi/api/position_api.dart';
import 'bloc.dart';

class NcovBloc extends Bloc<NcovEvent, NcovState> {
  PositionApi _positionApi = PositionApi();

  @override
  NcovState get initialState => InitialNcovState();

  @override
  Stream<NcovState> mapEventToState(
    NcovEvent event,
  ) async* {
    if (event is ShowPoiPanelEvent) {
      yield LoadPoiPanelState(event.ncovPoiEntity);

      var _ncovDataList = await _positionApi.mapGetNcovUserPoiData(event.ncovPoiEntity.id);
      if (_ncovDataList.length > 0) {
        var fullInfomationPoi = _ncovDataList[0];
        yield ShowPoiPanelState(fullInfomationPoi);
      } else {
        yield LoadPoiPanelState(null);
      }
    } else if (event is ClearSelectPoiEvent) {
      yield ClearSelectPoiState();
    }
  }
}
