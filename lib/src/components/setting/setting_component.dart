import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/components/setting/model.dart';
import 'package:titan/src/consts/consts.dart';
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

class _SettingManagerState extends State<_SettingManager> {
  @override
  void initState() {
    super.initState();
    //do logic here
    _initSetting();
  }

  _initSetting() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var languageStr = await AppCache.getValue<String>(PrefsKey.SETTING_LANGUAGE);
      if (languageStr != null) {
        var languageModel = LanguageModel.fromJson(json.decode(languageStr));
        BlocProvider.of<SettingBloc>(context).add(UpdateLanguageEvent(languageModel: languageModel));
      } else {
        BlocProvider.of<SettingBloc>(context)
            .add(UpdateLanguageEvent(languageModel: SupportedLanguage.defaultModel(Keys.mainPageKey.currentContext)));
      }
      var areaModelStr = await AppCache.getValue<String>(PrefsKey.SETTING_AREA);
      if (areaModelStr != null) {
        var areaModel = AreaModel.fromJson(json.decode(areaModelStr));
        BlocProvider.of<SettingBloc>(context).add(UpdateAreaEvent(areaModel: areaModel));
      } else {
        BlocProvider.of<SettingBloc>(context)
            .add(UpdateAreaEvent(areaModel: SupportedArea.defaultModel(Keys.mainPageKey.currentContext)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingBloc, SettingState>(
      builder: (ctx, state) {
        var languageMode = (state is UpdateSettingState) ? state.languageModel : null;
        var areaModel = (state is UpdateSettingState) ? state.areaModel : null;
        return SettingViewModel(areaModel: areaModel, languageModel: languageMode, child: widget.child);
      },
    );
  }
}

enum SettingProps { language, area }

class SettingViewModel extends InheritedModel<SettingProps> {
  final LanguageModel languageModel;
  final AreaModel areaModel;

  SettingViewModel({
    @required this.languageModel,
    @required this.areaModel,
    Key key,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(SettingViewModel oldWidget) {
    return languageModel != oldWidget.languageModel || areaModel != oldWidget.areaModel;
  }

  static SettingViewModel of(BuildContext context, {String aspect}) {
    return InheritedModel.inheritFrom<SettingViewModel>(context, aspect: aspect);
  }

  @override
  bool updateShouldNotifyDependent(SettingViewModel oldWidget, Set<SettingProps> dependencies) {
    return (languageModel != oldWidget.languageModel && dependencies.contains(SettingProps.language) ||
        areaModel != oldWidget.areaModel && dependencies.contains(SettingProps.area));
  }
}
