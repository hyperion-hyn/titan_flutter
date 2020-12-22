import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/contribution/signal_scan/vo/check_in_model.dart';
import 'package:titan/src/pages/mine/api/contributions_api.dart';
import 'bloc.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  var _api = ContributionsApi();
  String get _addressStr =>
      WalletInheritedModel.of(Keys.rootKey.currentContext)?.activatedWallet?.wallet?.getEthAccount()?.address ?? "";

  @override
  AccountState get initialState => InitialAccountState();

  @override
  Stream<AccountState> mapEventToState(AccountEvent event) async* {
    try {
      if (event is UpdateMyCheckInInfoEvent) {
        var _address = event.address;
        if (_address?.isEmpty ?? true) {
          _address = _addressStr;
        }
        CheckInModel checkInTask = await _api.checkInCountV3(_address);

        yield UpdateMyCheckInInfoState(checkInModel: checkInTask);
      } else if (event is ClearMyCheckInInfoEvent) {
        yield ClearMyCheckInInfoState();
      }
    } catch (e) {
      yield UpdateFailState();
    }
  }
}
