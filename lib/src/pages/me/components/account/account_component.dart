import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/pages/contribution/signal_scan/vo/check_in_model.dart';
import 'package:titan/src/pages/me/components/account/bloc/bloc.dart';
import 'package:titan/src/pages/me/model/user_info.dart';
import 'package:titan/src/pages/me/model/user_token.dart';

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
  UserInfo _userInfo;
  UserToken _userToken;
  CheckInModel _checkInModel;

  @override
  void initState() {
    super.initState();
    _loadLocaleAccount();
  }

  void _loadLocaleAccount() async {
    var useTokenStr = await AppCache.getValue(PrefsKey.SHARED_PREF_USER_TOKEN_KEY);
    var userInfoStr = await AppCache.getValue(PrefsKey.SHARED_PREF_USER_INFO_KEY);
    setState(() {
      if (useTokenStr != null) {
        this._userToken = UserToken.fromJson(json.decode(useTokenStr));
      }
      if (userInfoStr != null) {
        this._userInfo = UserInfo.fromJson(json.decode(userInfoStr));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
      builder: (BuildContext context, AccountState state) {
        if (state is UserUpdateState) {
          if (state.userInfo != null) {
            _userInfo = state.userInfo;
          }
          if (state.userToken != null) {
            _userToken = state.userToken;
          }
        } else if (state is LogoutState) {
          _userInfo = null;
          _userToken = null;
        } else if (state is UpdateCheckInState) {
          _checkInModel = state.checkInModel;
        }

        return AccountInheritedModel(
          userInfo: _userInfo,
          userToken: _userToken,
          child: widget.child,
        );
      },
    );
  }
}

enum AccountAspect {
  userInfo,
  userToken,
  checkInModel,
}

class AccountInheritedModel extends InheritedModel<AccountAspect> {
  final UserInfo userInfo;
  final UserToken userToken;
  final CheckInModel checkInModel;

  AccountInheritedModel({
    this.userInfo,
    this.userToken,
    this.checkInModel,
    Key key,
    @required Widget child,
  }) : super(key: key, child: child);

  static AccountInheritedModel of(BuildContext context, {AccountAspect aspect}) {
    return InheritedModel.inheritFrom<AccountInheritedModel>(context, aspect: aspect);
  }

  @override
  bool updateShouldNotify(AccountInheritedModel oldWidget) {
    return userInfo != oldWidget.userInfo || userToken != oldWidget.userToken || checkInModel != oldWidget.checkInModel;
  }

  @override
  bool updateShouldNotifyDependent(AccountInheritedModel oldWidget, Set<AccountAspect> dependencies) {
    return ((userInfo != oldWidget.userInfo && dependencies.contains(AccountAspect.userInfo)) ||
        (userToken != oldWidget.userToken && dependencies.contains(AccountAspect.userToken)) ||
        (checkInModel != oldWidget.checkInModel && dependencies.contains(AccountAspect.checkInModel)));
  }
}
