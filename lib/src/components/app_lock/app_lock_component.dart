import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nested/nested.dart';
import 'package:titan/src/app.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';

import 'app_lock_bloc.dart';
import 'entity/app_lock_config.dart';

class AppLockComponent extends SingleChildStatelessWidget {
  AppLockComponent({
    Key key,
    Widget child,
  }) : super(key: key, child: child);

  @override
  Widget buildWithChild(BuildContext context, Widget child) {
    return BlocProvider<AppLockBloc>(
      create: (ctx) => AppLockBloc(),
      child: _AppLockManager(child: child),
    );
  }
}

class _AppLockManager extends StatefulWidget {
  final Widget child;

  _AppLockManager({
    @required this.child,
  });

  @override
  State<StatefulWidget> createState() {
    return _AppLockManagerState();
  }
}

class _AppLockManagerState extends BaseState<_AppLockManager> {
  AppLockConfig _appLockConfig = AppLockConfig.fromDefault();
  Timer _awayTimer;
  int _currentAwayTime = 0;

  @override
  void onCreated() async {
    BlocProvider.of<AppLockBloc>(context).add(LoadAppLockConfigEvent());
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  _cancelTimer() {
    if (_awayTimer != null) {
      if (_awayTimer.isActive) {
        _awayTimer.cancel();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppLockBloc, AppLockState>(
      listener: (context, state) async {
        if (state is LoadAppLockConfigState) {
          var configCache = await _loadAppLockConfig();
          if (configCache != null) {
            _appLockConfig = configCache;

            ///if enabled, default on when app opens
            _appLockConfig.walletLock.isOn = true;
          }
        } else if (state is SetWalletLockState) {
          ///set on/off same as enabled
          _appLockConfig?.walletLock?.isEnabled = state.isEnabled;
          _appLockConfig?.walletLock?.isOn = state.isEnabled;

          await _saveAppLockConfig();
        } else if (state is SetWalletLockAwayTimeState) {
          _appLockConfig?.walletLock?.awayTime = state.awayTime;
          await _saveAppLockConfig();
        } else if (state is SetWalletLockBioAuthState) {
          _appLockConfig?.walletLock?.isBioAuthEnabled = state.isEnabled;
          await _saveAppLockConfig();
        } else if (state is SetWalletLockCountDownState) {
          if (state.isStop) {
            _currentAwayTime = 0;
            _cancelTimer();
          } else {
            ///only count-down if wallet-lock is enable but not on
            if (AppLockInheritedModel.of(Keys.rootKey.currentContext).isWalletNotActive)
              _awayTimer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
                _currentAwayTime++;
                //print(' WalletLock awayTime $_currentAwayTime');
                if (_currentAwayTime > (_appLockConfig?.walletLock?.awayTime ?? 0)) {
                  _appLockConfig?.walletLock?.isOn = true;
                  _cancelTimer();
                }
              });
          }
        } else if (state is LockWalletState) {
          _appLockConfig?.walletLock?.isOn = true;
        } else if (state is UnlockWalletState) {
          _appLockConfig?.walletLock?.isOn = false;
        }
        if (mounted) setState(() {});
      },
      child: BlocBuilder<AppLockBloc, AppLockState>(
        builder: (context, state) {
          return AppLockInheritedModel(
            appLockConfig: _appLockConfig,
            child: widget.child,
          );
        },
      ),
    );
  }

  _saveAppLockConfig() async {
    await AppCache.secureSaveValue(
      SecurePrefsKey.APP_LOCK_CONFIG,
      json.encode(_appLockConfig.toJson()),
    );
  }

  Future<AppLockConfig> _loadAppLockConfig() async {
    var jsonStr = await AppCache.secureGetValue(
      SecurePrefsKey.APP_LOCK_CONFIG,
    );
    return AppLockConfig.fromJson(json.decode(jsonStr));
  }
}

enum AppLockAspect { none }

class AppLockInheritedModel extends InheritedModel<AppLockAspect> {
  final AppLockConfig appLockConfig;

  const AppLockInheritedModel({
    Key key,
    @required Widget child,
    @required this.appLockConfig,
  }) : super(key: key, child: child);

  bool get isWalletLockActive {
    return (appLockConfig?.walletLock?.isEnabled ?? false) &&
        (appLockConfig?.walletLock?.isOn ?? false);
  }

  bool get isWalletNotActive {
    return (appLockConfig?.walletLock?.isEnabled ?? false) &&
        !(appLockConfig?.walletLock?.isOn ?? false);
  }

  bool get isWalletLockOn {
    return appLockConfig?.walletLock?.isOn ?? false;
  }

  bool get isWalletLockEnable {
    return appLockConfig?.walletLock?.isEnabled ?? false;
  }

  int get walletLockAwayTime {
    return appLockConfig?.walletLock?.awayTime ?? 0;
  }

  bool get isWalletLockBioAuthEnabled {
    return appLockConfig?.walletLock?.isBioAuthEnabled ?? false;
  }

  @override
  bool updateShouldNotify(AppLockInheritedModel oldWidget) {
    return true;
  }

  static AppLockInheritedModel of(BuildContext context, {AppLockAspect aspect}) {
    return InheritedModel.inheritFrom<AppLockInheritedModel>(
      context,
      aspect: aspect,
    );
  }

  @override
  bool updateShouldNotifyDependent(
      AppLockInheritedModel oldWidget, Set<AppLockAspect> dependencies) {
    return appLockConfig != oldWidget.appLockConfig && dependencies.contains(AppLockAspect.none);
  }
}
