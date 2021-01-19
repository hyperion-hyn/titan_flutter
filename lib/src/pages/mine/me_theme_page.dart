import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/setting/bloc/bloc.dart';
import 'package:titan/src/components/setting/bloc/setting_event.dart';
import 'package:titan/src/components/style/theme.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';

class MeThemePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MeThemeState();
  }
}

class _MeThemeState extends BaseState<MeThemePage> {
  ThemeModel selectedModel;

  List<ThemeModel> get themeList {
    List<ThemeModel> themes = [];
    var themeName = '默认';
    ThemeData themeData;
    Color color;
    for (int i = 0; i < 2; i++) {
      int value = 0;
      switch (i) {
        case 0:
          themeName = '默认';
          themeData = appThemeDefault;
          color = Theme.of(context).primaryColor;
          break;

        case 1:
          themeName = '深红';
          themeData = appThemeDeepRed;
          color = Colors.redAccent;
          break;

        case 2:
          value = 400;
          break;

        case 3:
          value = 700;
          break;
      }
      var model = ThemeModel(name: themeName, color: color, theme: themeData);
      themes.add(model);
    }
    return themes;
  }

  @override
  void onCreated() {
    _setupData();
  }

  _setupData() async {
    var name = await AppCache.getValue(PrefsKey.SETTING_SYSTEM_THEME);
    if (name != null) {
      var jsonName = json.decode(name);
      for (var item in themeList) {
        if (item.name == jsonName) {
          setState(() {
            selectedModel = item;
          });
          break;
        }
      }
    } else {
      selectedModel = themeList[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget _dividerWidget() {
      return Padding(
        padding: const EdgeInsets.only(
          left: 16,
        ),
        child: Container(
          height: 0.8,
          color: HexColor('#F8F8F8'),
        ),
      );
    }

    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: '主题',
        backgroundColor: Colors.white,
        showBottom: true,
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              BlocProvider.of<SettingBloc>(context).add(UpdateSettingEvent(themeModel: selectedModel));
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
        children: themeList.map((model) {
          return Container(
            child: Column(
              children: [
                _buildInfoContainer(model),
                _dividerWidget(),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInfoContainer(ThemeModel model) {
    var _visible = (selectedModel?.name ?? '') == model.name;

    return InkWell(
      onTap: () {
        print("$selectedModel  ${model.name}");
        setState(() {
          selectedModel = model;
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
                    model.name,
                    style: TextStyle(color: HexColor("#333333"), fontSize: 14),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Container(
                    height: 25,
                    width: 100,
                    color: model.theme.primaryColor,
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

class ThemeModel {
  final String name;
  final Color color;
  final ThemeData theme;

  ThemeModel({
    this.name,
    this.color,
    this.theme,
  });
}
