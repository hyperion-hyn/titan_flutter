import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/auth/bloc/auth_bloc.dart';
import 'package:titan/src/components/auth/bloc/auth_state.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/pages/red_pocket/api/rp_api.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_my_level_info.dart';

import 'bloc/bloc.dart';

class RedPocketComponent extends StatelessWidget {
  final Widget child;

  RedPocketComponent({@required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RedPocketBloc>(
      create: (ctx) => RedPocketBloc(),
      child: _RedPocketManager(child: child),
    );
  }
}

class _RedPocketManager extends StatefulWidget {
  final Widget child;

  _RedPocketManager({@required this.child});

  @override
  State<StatefulWidget> createState() {
    return _RedPocketState();
  }
}

class _RedPocketState extends BaseState<_RedPocketManager> {
  RpMyLevelInfo _myLevelInfo;

  @override
  void onCreated() {
    super.onCreated();

    _initData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RedPocketBloc, RedPocketState>(
      listener: (context, state) {
        if (state is UpdateMyLevelInfoEntityState) {
          _myLevelInfo = state.rpMyLevelInfo;
        }
      },
      child: BlocBuilder<RedPocketBloc, RedPocketState>(
        builder: (context, state) {
          return RedPocketInheritedModel(
            rpMyLevelInfo: _myLevelInfo,
            child: widget.child,
          );
        },
      ),
    );
  }

  _initData() {
    if (context != null) {
      BlocProvider.of<RedPocketBloc>(context).add(UpdateMyLevelInfoEntityEvent());
    }
  }
}

enum RedPocketAspect { account }

class RedPocketInheritedModel extends InheritedModel<RedPocketAspect> {
  final RpMyLevelInfo rpMyLevelInfo;

  const RedPocketInheritedModel({
    Key key,
    @required this.rpMyLevelInfo,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(RedPocketInheritedModel oldWidget) {
    return true;
  }

  static RedPocketInheritedModel of(BuildContext context, {RedPocketAspect aspect}) {
    return InheritedModel.inheritFrom<RedPocketInheritedModel>(
      context,
      aspect: aspect,
    );
  }

  @override
  bool updateShouldNotifyDependent(RedPocketInheritedModel oldWidget, Set<RedPocketAspect> dependencies) {
    return rpMyLevelInfo != oldWidget.rpMyLevelInfo && dependencies.contains(RedPocketAspect.account);
  }
}
