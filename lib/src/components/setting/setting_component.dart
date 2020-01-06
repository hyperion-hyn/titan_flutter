import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/config.dart';
import 'package:titan/src/components/quotes/bloc/bloc.dart';
import 'package:titan/src/components/quotes/model.dart';
import 'package:titan/src/components/setting/model.dart';
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

class _SettingManagerState extends State<_SettingManager> {
  LanguageModel languageModel;
  AreaModel areaModel;

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
            .add(UpdateLanguageEvent(languageModel: SupportedLanguage.defaultModel(Keys.homePageKey.currentContext)));
      }
      var areaModelStr = await AppCache.getValue<String>(PrefsKey.SETTING_AREA);
      if (areaModelStr != null) {
        var areaModel = AreaModel.fromJson(json.decode(areaModelStr));
        BlocProvider.of<SettingBloc>(context).add(UpdateAreaEvent(areaModel: areaModel));
      } else {
        BlocProvider.of<SettingBloc>(context)
            .add(UpdateAreaEvent(areaModel: SupportedArea.defaultModel(Keys.homePageKey.currentContext)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingBloc, SettingState>(
      listener: (context, state) {
        if (state is UpdateAreaState) {
          Config.updateConfig(state.areaModel);
        } else if (state is UpdateLanguageState) {
          //update current quotes
          var sign = SupportedQuotes.of('USD');
          if (languageModel?.locale?.languageCode == 'zh') {
            sign = SupportedQuotes.of('CNY');
          }
          BlocProvider.of<QuotesCmpBloc>(context).add(UpdateQuotesSignEvent(sign: sign));
        }
      },
      child: BlocBuilder(
        builder: (context, state) {
          if (state is UpdateAreaState) {
            areaModel = state.areaModel;
          } else if (state is UpdateLanguageState) {
            languageModel = state.languageModel;
          }

          return SettingViewModel(
            areaModel: areaModel,
            languageModel: languageModel,
            child: widget.child,
          );
        },
      ),
    );
  }
}

enum SettingAspect { language, area, sign }

class SettingViewModel extends InheritedModel<SettingAspect> {
  final LanguageModel languageModel;
  final AreaModel areaModel;

  SettingViewModel({
    @required this.languageModel,
    @required this.areaModel,
    Key key,
    @required Widget child,
  }) : super(key: key, child: child);

  String get languageCode {
    return languageModel?.locale?.languageCode;
  }

  @override
  bool updateShouldNotify(SettingViewModel oldWidget) {
    return languageModel != oldWidget.languageModel || areaModel != oldWidget.areaModel;
  }

  static SettingViewModel of(BuildContext context, {SettingAspect aspect}) {
    return InheritedModel.inheritFrom<SettingViewModel>(context, aspect: aspect);
  }

  @override
  bool updateShouldNotifyDependent(SettingViewModel oldWidget, Set<SettingAspect> dependencies) {
    return (languageModel != oldWidget.languageModel && dependencies.contains(SettingAspect.language) ||
        areaModel != oldWidget.areaModel && dependencies.contains(SettingAspect.area));
  }
}
