import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/config.dart';
import 'package:titan/src/components/quotes/bloc/bloc.dart';
import 'package:titan/src/components/quotes/model.dart';
import 'package:titan/src/components/setting/model.dart';
import 'package:titan/src/config/consts.dart';

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
  Widget build(BuildContext context) {
    return BlocListener<SettingBloc, SettingState>(
      listener: (context, state) {
        if (state is UpdatedSettingState) {
          if (state.areaModel != null) {
            Config.updateConfig(state.areaModel);
          }
          if (state.quotesSign != null) {
            BlocProvider.of<QuotesCmpBloc>(context).add(UpdateQuotesSignEvent(sign: state.quotesSign));
          }

          /*if (state.languageModel != null) {
            //update current quotes by setting
            var quoteSign = SupportedQuoteSigns.of('USD');
            if (state.languageModel?.isZh() == true) {
              quoteSign = SupportedQuoteSigns.of('CNY');
            }
            BlocProvider.of<QuotesCmpBloc>(context).add(UpdateQuotesSignEvent(sign: quoteSign));
          }*/
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
          }

          return SettingInheritedModel(
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

class SettingInheritedModel extends InheritedModel<SettingAspect> {
  final LanguageModel languageModel;
  final AreaModel areaModel;

  SettingInheritedModel({
    @required this.languageModel,
    @required this.areaModel,
    Key key,
    @required Widget child,
  }) : super(key: key, child: child);

  String get languageCode {
    return languageModel?.locale?.languageCode;
  }

  String get netLanguageCode {
    var countryCode = languageModel.locale.countryCode??'';
    if(languageCode == "zh"){
      return "${languageCode}_$countryCode";
    }
    return languageCode;
  }


  @override
  bool updateShouldNotify(SettingInheritedModel oldWidget) {
    return languageModel != oldWidget.languageModel || areaModel != oldWidget.areaModel;
  }

  static SettingInheritedModel of(BuildContext context, {SettingAspect aspect}) {
    return InheritedModel.inheritFrom<SettingInheritedModel>(context, aspect: aspect);
  }

  @override
  bool updateShouldNotifyDependent(SettingInheritedModel oldWidget, Set<SettingAspect> dependencies) {
    return (languageModel != oldWidget.languageModel && dependencies.contains(SettingAspect.language) ||
        areaModel != oldWidget.areaModel && dependencies.contains(SettingAspect.area));
  }
}

