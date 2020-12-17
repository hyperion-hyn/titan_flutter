import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/red_pocket/api/rp_api.dart';
import './bloc.dart';

class RedPocketBloc extends Bloc<RedPocketEvent, RedPocketState> {
  @override
  RedPocketState get initialState => InitialAtlasState();

  final RPApi _rpApi = RPApi();

  String get _addressStr => WalletInheritedModel.of(Keys.rootKey.currentContext)?.activatedWallet?.wallet?.getEthAccount()?.address ?? "";

  @override
  Stream<RedPocketState> mapEventToState(
    RedPocketEvent event,
  ) async* {
    try {
      if (event is UpdateMyLevelInfoEvent) {
        var _address = event.address;
        //print("[RedPocketBloc] UpdateMyLevelInfoEntityEvent, _address:$_address");
        if (_address?.isEmpty??true) {
          _address = _addressStr;
        }
        var _myLevelInfo = await _rpApi.getRPMyLevelInfo(_address);

        yield UpdateMyLevelInfoState(_myLevelInfo);
      } else if (event is UpdateStatisticsEvent) {
        var _address = event.address;
        //print("[RedPocketBloc] UpdateStatisticsEvent, _address:$_address");
        if (_address?.isEmpty??true) {
          _address = _addressStr;
        }
        var _statistics = await _rpApi.getRPStatistics(_address);
        yield UpdateStatisticsState(_statistics);
      }
    } catch (e) {
      yield UpdateFailState();
    }
  }
}
