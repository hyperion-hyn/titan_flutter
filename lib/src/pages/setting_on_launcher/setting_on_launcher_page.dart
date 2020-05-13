import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/components/quotes/model.dart';
import 'package:titan/src/components/root_page_control_component/bloc/bloc.dart';
import 'package:titan/src/components/setting/bloc/bloc.dart';
import 'package:titan/src/components/setting/model.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/app_tabbar/app_tabbar_page.dart';
import 'package:titan/src/utils/utile_ui.dart';

class SettingOnLauncherPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SettingOnLauncherPageState();
  }
}

class SettingOnLauncherPageState extends State<SettingOnLauncherPage> {
  AreaModel _currentArea;
  LanguageModel _currentLanguage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentArea = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).selected_area),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  S.of(context).language,
                  style: TextStyle(fontSize: 16),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: DropdownButton(
                    items: SupportedLanguage.all.map<DropdownMenuItem<LanguageModel>>(((language) {
                      return DropdownMenuItem<LanguageModel>(
                        value: language,
                        child: Text(
                          language.name,
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      );
                    })).toList(),
                    onChanged: (value) {
                      _currentLanguage = value;
                      BlocProvider.of<SettingBloc>(context).add(UpdateSettingEvent(languageModel: value));
                    },
                    value: SettingInheritedModel.of(context, aspect: SettingAspect.language).languageModel,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24.0, top: 56, bottom: 16),
              child: Text(
                S.of(context).what_region_use_titan(S.of(context).app_name),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
              ),
            ),
            ListView(
              shrinkWrap: true,
              children: SupportedArea.all().map((area) {
                if (area == SettingInheritedModel.of(context, aspect: SettingAspect.area).areaModel) {
                  _currentArea = area;
                }
                return RadioListTile<AreaModel>(
                  title: Text(
                    area.name(context),
                    style: TextStyle(fontSize: 16),
                  ),
                  value: area,
                  onChanged: (AreaModel value) {
                    BlocProvider.of<SettingBloc>(context).add(UpdateSettingEvent(areaModel: value));
                    _currentArea = value;
                  },
                  groupValue: SettingInheritedModel.of(context, aspect: SettingAspect.area).areaModel,
                );
              }).toList(),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40, left: 24.0, right: 24, bottom: 16),
                    child: Builder(
                      builder: (context) {
                        return OutlineButton(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                          textColor: Theme.of(context).primaryColor,
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                          onPressed: () async {
                            if (_currentArea == null) {
                              UiUtil.showSnackBar(context, S.of(context).select_region_tip);
                              return;
                            }

                            //setting quote sign
                            if(_currentLanguage == null){
                              _currentLanguage = SettingInheritedModel.of(context, aspect: SettingAspect.language).languageModel;
                            }
                            var quoteSign = SupportedQuoteSigns.of('USD');
                            if (_currentLanguage.isZh() == true) {
                              quoteSign = SupportedQuoteSigns.of('CNY');
                            }
                            BlocProvider.of<SettingBloc>(context).add(UpdateSettingEvent(quotesSign: quoteSign));

                            var prefs = await SharedPreferences.getInstance();
                            await prefs.setBool(PrefsKey.FIRST_TIME_LAUNCHER_KEY, true);
                            BlocProvider.of<RootPageControlBloc>(context).add(SetRootPageEvent(page: AppTabBarPage()));
                          },
                          child: Text('${S.of(context).enter} ${S.of(context).app_name}'),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
