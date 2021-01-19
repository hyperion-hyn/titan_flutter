import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/setting/bloc/bloc.dart';
import 'package:titan/src/components/setting/model.dart';
import 'package:titan/src/components/setting/setting_component.dart';

class MeLanguagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LanguageState();
  }
}

class _LanguageState extends BaseState<MeLanguagePage> {
  LanguageModel selectedLanguageModel;


  @override
  void onCreated() {
    selectedLanguageModel = SettingInheritedModel.of(context, aspect: SettingAspect.language).languageModel;
  }


  @override
  Widget build(BuildContext context) {

    var languages = SupportedLanguage.all;

    Widget _dividerWidget() {
      return Padding(
        padding: const EdgeInsets.only(left: 16,),
        child: Container(
          height: 0.8,
          color: HexColor('#F8F8F8'),
        ),
      );
    }

    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: S.of(context).language,
        backgroundColor: Colors.white,
        showBottom: true,
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              BlocProvider.of<SettingBloc>(context).add(UpdateSettingEvent(languageModel: selectedLanguageModel));
              Navigator.pop(context);
            },
            child: Text(
              S.of(context).confirm,
              style: TextStyle(
                color: HexColor("#1F81FF"),
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _buildInfoContainer(languages[0]),
          _dividerWidget(),
          _buildInfoContainer(languages[1]),
          _dividerWidget(),
          _buildInfoContainer(languages[2]),
          _dividerWidget(),
          _buildInfoContainer(languages[3]),
        ],
      ),
    );
  }


  Widget _buildInfoContainer(LanguageModel languageModel) {

    var _visible = false;
    if (selectedLanguageModel.locale.languageCode == 'zh') {
      _visible = (selectedLanguageModel.locale.countryCode == languageModel.locale.countryCode);
      //print('[language] --> countryCode:${locale.countryCode}, selectedLocale.countryCode:${selectedLocale.countryCode}');
    } else {
      _visible = (selectedLanguageModel.locale.languageCode == languageModel.locale.languageCode);
      //print('[language] --> language:${locale.languageCode}, selectedLocale.languageCode:${selectedLocale.languageCode}');
    }
    
    return InkWell(
      onTap: () {
        print("$selectedLanguageModel  $languageModel");
        setState(() {
          selectedLanguageModel = languageModel;
        });
      },
      child: Column(
        children: <Widget>[
          Container(
            height: 56,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 15, 15, 13),
                  child: Text(
                    languageModel.name,
                    style: TextStyle(color: HexColor("#333333"), fontSize: 14),
                  ),
                ),
                Spacer(),
                Visibility(
                  visible: _visible,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 15, 15, 13),
                    child: Icon(
                      Icons.check,
                      color: Colors.green,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
