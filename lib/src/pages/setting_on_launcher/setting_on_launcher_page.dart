import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/src/components/root_page_control_component/bloc/bloc.dart';
import 'package:titan/src/components/setting/model.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/pages/app_tabbar/app_tabbar_page.dart';

class SettingOnLauncherPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SettingOnLauncherPageState();
  }
}

class SettingOnLauncherPageState extends State<SettingOnLauncherPage> {
  AreaModel selectedArea;
  LanguageModel selectedLanguage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 200.0),
        child: Column(
          children: <Widget>[
            DropdownButton(
              items: SupportedLanguage.all().map<DropdownMenuItem<LanguageModel>>(((language) {
                return DropdownMenuItem<LanguageModel>(
                  value: language,
                  child: Text(language.name),
                );
              })).toList(),
              onChanged: (value) {
                setState(() {
                  selectedLanguage = value;
                });
              },
              value: selectedLanguage,
            ),
            Text('你在什么地区使用titan?'),
            ListView(
              shrinkWrap: true,
              children: SupportedArea.all(context).map((area) {
                return RadioListTile<AreaModel>(
                  title: Text(area.name),
                  value: area,
                  onChanged: (AreaModel value) {
                    setState(() {
                      selectedArea = value;
                    });
                  },
                  groupValue: selectedArea,
                );
              }).toList(),
            ),
            RaisedButton(
              onPressed: () async {
                var prefs = await SharedPreferences.getInstance();
                await prefs.setBool(PrefsKey.FIRST_TIME_LAUNCHER_KEY, true);

                BlocProvider.of<RootPageControlBloc>(context).add(SetRootPageEvent(page: AppTabBarPage()));
              },
              child: Text('进入titan'),
            ),
          ],
        ),
      ),
    );
  }
}
