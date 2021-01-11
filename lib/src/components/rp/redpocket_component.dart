import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_my_level_info.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_promotion_rule_entity.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_share_config_entity.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_statistics.dart';
import 'bloc/bloc.dart';
import 'package:nested/nested.dart';

class RedPocketComponent extends SingleChildStatelessWidget {
  RedPocketComponent({Key key, Widget child}) : super(key: key, child: child);

  @override
  Widget buildWithChild(BuildContext context, Widget child) {
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
  RPStatistics _rpStatistics;
  RpPromotionRuleEntity _rpPromotionRule;
  RpShareConfigEntity _rpShareConfig;

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
        if (state is UpdateMyLevelInfoState) {
          _myLevelInfo = state.rpMyLevelInfo;
        } else if (state is UpdateStatisticsState) {
          _rpStatistics = state.rpStatistics;
        }else if (state is UpdatePromotionRuleState) {
          _rpPromotionRule = state.rpPromotionRule;
        } else if (state is UpdateShareConfigState) {
          _rpShareConfig = state.rpShareConfig;
        } else if (state is ClearMyLevelInfoState) {
          _myLevelInfo = null;
        }
      },
      child: BlocBuilder<RedPocketBloc, RedPocketState>(
        builder: (context, state) {
          return RedPocketInheritedModel(
            rpMyLevelInfo: _myLevelInfo,
            rpStatistics: _rpStatistics,
            rpPromotionRule: _rpPromotionRule,
            rpShareConfig: _rpShareConfig,
            child: widget.child,
          );
        },
      ),
    );
  }

  _initData() {
    BlocProvider.of<WalletCmpBloc>(context).listen((state) {
      if (state is ActivatedWalletState) {
        var _activatedWallet = state.walletVo;
        var _address =
            _activatedWallet?.wallet?.getAtlasAccount()?.address ?? '';
        //print("[RedPocketComponent] ActivatedWalletState, _address:$_address");

        if (context != null) {
          BlocProvider.of<RedPocketBloc>(context)
              .add(UpdateMyLevelInfoEvent(address: _address));
        }

        if (context != null) {
          BlocProvider.of<RedPocketBloc>(context)
              .add(UpdateStatisticsEvent(address: _address));
        }

        if (context != null) {
          BlocProvider.of<RedPocketBloc>(context)
              .add(UpdatePromotionRuleEvent(address: _address));
        }

        if (context != null) {
          BlocProvider.of<RedPocketBloc>(context)
              .add(UpdateShareConfigEvent(address: _address));
        }
      }
    });

    if (context != null) {
      BlocProvider.of<RedPocketBloc>(context).add(UpdateStatisticsEvent());
    }
  }
}

enum RedPocketAspect {
  levelInfo,
  statistics,
  promotion,
  config,
}

class RedPocketInheritedModel extends InheritedModel<RedPocketAspect> {
  final RpMyLevelInfo rpMyLevelInfo;
  final RPStatistics rpStatistics;
  final RpPromotionRuleEntity rpPromotionRule;
  final RpShareConfigEntity rpShareConfig;

  const RedPocketInheritedModel({
    Key key,
    @required this.rpMyLevelInfo,
    @required this.rpStatistics,
    @required this.rpPromotionRule,
    @required this.rpShareConfig,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(RedPocketInheritedModel oldWidget) {
    return true;
  }

  static RedPocketInheritedModel of(BuildContext context,
      {RedPocketAspect aspect}) {
    return InheritedModel.inheritFrom<RedPocketInheritedModel>(
      context,
      aspect: aspect,
    );
  }

  @override
  bool updateShouldNotifyDependent(
      RedPocketInheritedModel oldWidget, Set<RedPocketAspect> dependencies) {
    return (rpMyLevelInfo != oldWidget.rpMyLevelInfo &&
            dependencies.contains(RedPocketAspect.levelInfo)) ||
        (rpStatistics != oldWidget.rpStatistics &&
            dependencies.contains(RedPocketAspect.statistics)) ||
        (rpPromotionRule != oldWidget.rpPromotionRule &&
            dependencies.contains(RedPocketAspect.promotion)) ||
        (rpShareConfig != oldWidget.rpShareConfig &&
            dependencies.contains(RedPocketAspect.config));
  }
}
