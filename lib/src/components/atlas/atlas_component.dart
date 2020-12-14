import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/auth/bloc/auth_bloc.dart';
import 'package:titan/src/components/auth/bloc/auth_state.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_home_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/committee_info_entity.dart';

class AtlasComponent extends StatelessWidget {
  final Widget child;

  AtlasComponent({@required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (ctx) => AuthBloc(),
      child: _AtlasManager(child: child),
    );
  }
}

class _AtlasManager extends StatefulWidget {
  final Widget child;

  _AtlasManager({@required this.child});

  @override
  State<StatefulWidget> createState() {
    return _AtlasManagerState();
  }
}

class _AtlasManagerState extends BaseState<_AtlasManager> {
  Timer _timer;
  AtlasHomeEntity _atlasHomeEntity;
  AtlasApi _atlasApi = AtlasApi();

  @override
  void onCreated() {
    super.onCreated();
    _initTimer();
  }

  @override
  void dispose() {
    if (_timer != null && _timer.isActive) {
      _timer.cancel();
      _timer = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {},
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return AtlasInheritedModel(
            atlasHomeEntity: _atlasHomeEntity,
            child: widget.child,
          );
        },
      ),
    );
  }

  _initTimer() {
    ///refresh epoch
    ///
    _timer = Timer.periodic(Duration(seconds: 7), (t) {
      _updateAtlasHome();
    });
  }

  _updateAtlasHome() async {
    try {
      _atlasHomeEntity = await _atlasApi.postAtlasHome(
        WalletInheritedModel.of(context)
                ?.activatedWallet
                ?.wallet
                ?.getAtlasAccount()
                ?.address ??
            '',
      );
      //print('[AtlasComponent] ${_atlasHomeEntity.toJson()}');
      setState(() {});
    } catch (e) {}
  }
}

enum AtlasAspect { home }

class AtlasInheritedModel extends InheritedModel<AtlasAspect> {
  final AtlasHomeEntity atlasHomeEntity;

  const AtlasInheritedModel({
    Key key,
    @required this.atlasHomeEntity,
    @required Widget child,
  }) : super(key: key, child: child);

  CommitteeInfoEntity get committeeInfo {
    return atlasHomeEntity?.info;
  }

  int get currentEpoch {
    return atlasHomeEntity?.info?.epoch ?? 0;
  }

  int get remainBlockTillNextEpoch {
    var _blocksPerEpoch = atlasHomeEntity?.info?.blockHeight ?? 0;
    var _currentBlockNum = atlasHomeEntity?.info?.blockNum ?? 0;
    var _epochStartBlockNum = atlasHomeEntity?.info?.blockNumStart ?? 0;

    return (_blocksPerEpoch - (_currentBlockNum - _epochStartBlockNum));
  }

  int get remainSecTillNextEpoch {
    var _secPerBlock = atlasHomeEntity?.info?.secPerBlock ?? 0;
    var _blocksPerEpoch = atlasHomeEntity?.info?.blockHeight ?? 0;
    var _currentBlockNum = atlasHomeEntity?.info?.blockNum ?? 0;
    var _epochStartBlockNum = atlasHomeEntity?.info?.blockNumStart ?? 0;

    ///remain time: remainBlockCount * secPerBlock
    ///remainBlockCount = blocksPerEpoch - (currentBlockNum - startBlockNum)
    ///
    var _remainTime = _secPerBlock *
        (_blocksPerEpoch - (_currentBlockNum - _epochStartBlockNum));
    return _remainTime;
  }

  int get secPerEpoch {
    var _blocksPerEpoch = atlasHomeEntity?.info?.blockHeight ?? 0;
    var _secPerBlock = atlasHomeEntity?.info?.secPerBlock ?? 0;

    ///total time of 1 epoch:  blocksPerEpoch * secPerBlock
    ///
    return _blocksPerEpoch * _secPerBlock;
  }

  @override
  bool updateShouldNotify(AtlasInheritedModel oldWidget) {
    return true;
  }

  static AtlasInheritedModel of(BuildContext context, {AtlasAspect aspect}) {
    return InheritedModel.inheritFrom<AtlasInheritedModel>(
      context,
      aspect: aspect,
    );
  }

  @override
  bool updateShouldNotifyDependent(
      AtlasInheritedModel oldWidget, Set<AtlasAspect> dependencies) {
    return atlasHomeEntity != oldWidget.atlasHomeEntity &&
        dependencies.contains(AtlasAspect.home);
  }
}
