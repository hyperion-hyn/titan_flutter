import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nested/nested.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';

import 'app_lock_bloc.dart';

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

class _AppLockManagerState extends State<_AppLockManager> {
  LockStatus _lockStatus = LockStatus()..wallet = Wallet();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppLockBloc, AppLockState>(
      listener: (context, state) async {
        if (state is SetWalletLockState) {
          await WalletUtil.setWalletSafeLockEnable(
            state.walletAddress,
            state.isEnabled,
          );

          _lockStatus.wallet.isEnabled = state.isEnabled;

          ///set wallet on/off same as enabled
          _lockStatus.wallet.isOn = state.isEnabled;
        }
        if (state is LockWalletState) {
          _lockStatus.wallet.isOn = true;
        } else if (state is UnlockWalletState) {
          _lockStatus.wallet.isOn = false;
        }
        if (mounted) setState(() {});
      },
      child: BlocBuilder<AppLockBloc, AppLockState>(
        builder: (context, state) {
          return AppLockInheritedModel(
            lockStatus: _lockStatus,
            child: widget.child,
          );
        },
      ),
    );
  }
}

enum AppLockAspect { none }

class LockStatus {
  Wallet wallet = Wallet();
}

class Wallet {
  bool isEnabled = false;

  bool isOn = false;
}

class AppLockInheritedModel extends InheritedModel<AppLockAspect> {
  final LockStatus lockStatus;

  const AppLockInheritedModel({
    Key key,
    @required Widget child,
    @required this.lockStatus,
  }) : super(key: key, child: child);

  bool get isWalletLockOn {
    return lockStatus?.wallet?.isOn ?? false;
  }

  bool get isWalletLockEnable {
    return lockStatus?.wallet?.isEnabled ?? false;
  }

  @override
  bool updateShouldNotify(AppLockInheritedModel oldWidget) {
    return true;
  }

  static AppLockInheritedModel of(BuildContext context,
      {AppLockAspect aspect}) {
    return InheritedModel.inheritFrom<AppLockInheritedModel>(
      context,
      aspect: aspect,
    );
  }

  @override
  bool updateShouldNotifyDependent(
      AppLockInheritedModel oldWidget, Set<AppLockAspect> dependencies) {
    return lockStatus != oldWidget.lockStatus &&
        dependencies.contains(AppLockAspect.none);
  }
}
