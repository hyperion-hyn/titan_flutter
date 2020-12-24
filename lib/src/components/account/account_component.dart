import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/components/account/bloc/bloc.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/pages/contribution/signal_scan/vo/check_in_model.dart';
import 'package:titan/src/pages/mine/model/user_info.dart';

class AccountComponent extends StatelessWidget {
  final Widget child;

  AccountComponent({@required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AccountBloc>(
      create: (ctx) => AccountBloc(),
      child: _AccountManager(child: child),
    );
  }
}

class _AccountManager extends StatefulWidget {
  final Widget child;

  _AccountManager({@required this.child});

  @override
  State<StatefulWidget> createState() {
    return _AccountManagerState();
  }
}

class _AccountManagerState extends State<_AccountManager> {
  CheckInModel _checkInModel;
  UserInfo _userInfoModel;
  @override
  void initState() {
    super.initState();

    _initData();
  }

  _initData() {
    BlocProvider.of<WalletCmpBloc>(context).listen((state) {
      if (state is ActivatedWalletState) {
        var _activatedWallet = state.walletVo;
        var _address = _activatedWallet?.wallet?.getAtlasAccount()?.address ?? '';
        print("[AccountComponent] ActivatedWalletState, _address:$_address");

        if (context != null) {
          BlocProvider.of<AccountBloc>(context).add(UpdateCheckInInfoEvent(address: _address));
          BlocProvider.of<AccountBloc>(context).add(UpdateUserInfoEvent(address: _address));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
      builder: (BuildContext context, AccountState state) {
        if (state is UpdateCheckInInfoState) {
          if (state.checkInModel != null) {
            _checkInModel = state.checkInModel;
          }
        } else if (state is UpdateUserInfoState) {
          if (state.userInfo != null) {
            _userInfoModel = state.userInfo;
          }
        } else if (state is ClearDataState) {
          _checkInModel = null;
        }

        return AccountInheritedModel(
          checkInModel: _checkInModel,
          userInfoModel: _userInfoModel,
          child: widget.child,
        );
      },
    );
  }
}

enum AccountAspect {
  checkIn,
  userInfo,
}

class AccountInheritedModel extends InheritedModel<AccountAspect> {
  final CheckInModel checkInModel;
  final UserInfo userInfoModel;

  AccountInheritedModel({
    this.checkInModel,
    this.userInfoModel,
    Key key,
    @required Widget child,
  }) : super(key: key, child: child);

  static AccountInheritedModel of(BuildContext context, {AccountAspect aspect}) {
    return InheritedModel.inheritFrom<AccountInheritedModel>(context, aspect: aspect);
  }

  @override
  bool updateShouldNotify(AccountInheritedModel oldWidget) {
    return (checkInModel != oldWidget.checkInModel) || (userInfoModel != oldWidget.userInfoModel);
  }

  @override
  bool updateShouldNotifyDependent(AccountInheritedModel oldWidget, Set<AccountAspect> dependencies) {
    return (checkInModel != oldWidget.checkInModel && dependencies.contains(AccountAspect.checkIn)) ||
        (userInfoModel != oldWidget.userInfoModel && dependencies.contains(AccountAspect.userInfo));
  }
}
