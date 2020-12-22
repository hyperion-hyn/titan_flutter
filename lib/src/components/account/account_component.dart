import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/components/account/bloc/bloc.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/pages/contribution/signal_scan/vo/check_in_model.dart';

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
          BlocProvider.of<AccountBloc>(context).add(UpdateMyCheckInInfoEvent(address: _address));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
      builder: (BuildContext context, AccountState state) {
        if (state is UpdateMyCheckInInfoState) {
          if (state.checkInModel != null) {
            _checkInModel = state.checkInModel;
          }
        } else if (state is ClearMyCheckInInfoState) {
          _checkInModel = null;
        }

        return AccountInheritedModel(
          checkInModel: _checkInModel,
          child: widget.child,
        );
      },
    );
  }
}

enum AccountAspect {
  checkInModel,
}

class AccountInheritedModel extends InheritedModel<AccountAspect> {
  final CheckInModel checkInModel;

  AccountInheritedModel({
    this.checkInModel,
    Key key,
    @required Widget child,
  }) : super(key: key, child: child);

  static AccountInheritedModel of(BuildContext context, {AccountAspect aspect}) {
    return InheritedModel.inheritFrom<AccountInheritedModel>(context, aspect: aspect);
  }

  @override
  bool updateShouldNotify(AccountInheritedModel oldWidget) {
    return checkInModel != oldWidget.checkInModel;
  }

  @override
  bool updateShouldNotifyDependent(AccountInheritedModel oldWidget, Set<AccountAspect> dependencies) {
    return (checkInModel != oldWidget.checkInModel && dependencies.contains(AccountAspect.checkInModel));
  }
}
