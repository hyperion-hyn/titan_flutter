import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/config.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/model.dart';
import 'package:titan/src/components/setting/model.dart';
import 'package:titan/src/components/setting/system_config_entity.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';

import 'bloc/bloc.dart';

class SettingComponent extends StatelessWidget {
  final Widget child;

  SettingComponent({@required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingBloc>(
      create: (ctx) => SettingBloc(),
      child: _SettingManager(child: child),
    );
  }
}

class _SettingManager extends StatefulWidget {
  final Widget child;

  _SettingManager({@required this.child});

  @override
  State<StatefulWidget> createState() {
    return _SettingManagerState();
  }
}

class _SettingManagerState extends BaseState<_SettingManager> {
  LanguageModel languageModel;
  AreaModel areaModel;
  SystemConfigEntity systemConfigEntity = SystemConfigEntity.def();

  @override
  void onCreated() async {
    var systemConfigStr =
        await AppCache.getValue<String>(PrefsKey.SETTING_SYSTEM_CONFIG);
    if (systemConfigStr != null) {
      systemConfigEntity =
          SystemConfigEntity.fromJson(json.decode(systemConfigStr));
    }
    super.onCreated();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingBloc, SettingState>(
      listener: (context, state) {
        if (state is UpdatedSettingState) {
          if (state.areaModel != null) {
            Config.updateConfig(state.areaModel);
          }
        }
      },
      child: BlocBuilder<SettingBloc, SettingState>(
        builder: (context, state) {
          if (state is UpdatedSettingState) {
            if (state.languageModel != null) {
              languageModel = state.languageModel;
            }
            if (state.areaModel != null) {
              areaModel = state.areaModel;
            }
          } else if (state is SystemConfigState) {
            systemConfigEntity = state.systemConfigEntity;
          }

          return SettingInheritedModel(
            areaModel: areaModel,
            languageModel: languageModel,
            systemConfigEntity: systemConfigEntity,
            child: widget.child,
          );
        },
      ),
    );
  }
}

enum SettingAspect { language, area, sign, systemConfig }

class SettingInheritedModel extends InheritedModel<SettingAspect> {
  final LanguageModel languageModel;
  final AreaModel areaModel;
  final SystemConfigEntity systemConfigEntity;

  SettingInheritedModel({
    @required this.languageModel,
    @required this.areaModel,
    @required this.systemConfigEntity,
    Key key,
    @required Widget child,
  }) : super(key: key, child: child);

  String get languageCode {
    return languageModel?.locale?.languageCode??'zh';
  }

  String get netLanguageCode {
    var countryCode = languageModel?.locale?.countryCode ?? 'zh';
    if (languageCode == "zh") {
      return "${languageCode}_$countryCode";
    }
    return languageCode;
  }

  @override
  bool updateShouldNotify(SettingInheritedModel oldWidget) {
    return languageModel != oldWidget.languageModel ||
        areaModel != oldWidget.areaModel ||
        systemConfigEntity != oldWidget.systemConfigEntity;
  }

  static SettingInheritedModel of(BuildContext context,
      {SettingAspect aspect}) {
    return InheritedModel.inheritFrom<SettingInheritedModel>(context,
        aspect: aspect);
  }

  static SettingInheritedModel ofConfig(BuildContext context) {
    return InheritedModel.inheritFrom<SettingInheritedModel>(context,
        aspect: SettingAspect.systemConfig);
  }

  @override
  bool updateShouldNotifyDependent(
      SettingInheritedModel oldWidget, Set<SettingAspect> dependencies) {
    return ((languageModel != oldWidget.languageModel &&
            dependencies.contains(SettingAspect.language)) ||
        (areaModel != oldWidget.areaModel &&
            dependencies.contains(SettingAspect.area)) ||
        (systemConfigEntity != oldWidget.systemConfigEntity &&
            dependencies.contains(SettingAspect.systemConfig)));
  }
}
