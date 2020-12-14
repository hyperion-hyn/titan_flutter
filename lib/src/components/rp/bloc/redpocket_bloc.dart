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

  @override
  Stream<RedPocketState> mapEventToState(
    RedPocketEvent event,
  ) async* {

    if (event is UpdateMyLevelInfoEntityEvent) {
      try {
        var _address = WalletInheritedModel.of(Keys.rootKey.currentContext)?.activatedWallet?.wallet?.getAtlasAccount()?.address ?? '';
        var _myLevelInfo = await _rpApi.getRPMyLevelInfo(_address);

        yield UpdateMyLevelInfoEntityState(_myLevelInfo);
      } catch (e) {
        yield UpdateFailMyLevelInfoEntityState();
      }
    }

  }
}
