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
import 'package:titan/src/components/setting/model.dart';
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

  @override
  void onCreated() {
    _setupData();
  }

  _setupData() async {
    selectedModel = await SupportedTheme.defaultModel();
    setState(() {});
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
        baseTitle: S.of(context).theme,
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
        children: SupportedTheme.all.map((model) {
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
  final List<Color> btnColors;

  ThemeModel({
    this.name,
    this.color,
    this.theme,
    this.btnColors,
  });
}
