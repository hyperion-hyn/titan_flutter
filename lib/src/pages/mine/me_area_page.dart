import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/components/setting/bloc/bloc.dart';
import 'package:titan/src/components/setting/model.dart';
import 'package:titan/src/components/setting/setting_component.dart';

class MeAreaPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MeAreaState();
  }
}

class _MeAreaState extends State<MeAreaPage> {
  @override
  void initState() {
    super.initState();
  }

  var selectedAppArea;

  @override
  Widget build(BuildContext context) {
    if (selectedAppArea == null) {
      selectedAppArea = SettingInheritedModel.of(context, aspect: SettingAspect.area).areaModel;
    }

    Widget _dividerWidget() {
      return Padding(
        padding: const EdgeInsets.only(left: 16,),
        child: Container(
          height: 0.8,
          color: HexColor('#F8F8F8'),
        ),
      );
    }

    var areas = SupportedArea.all();

    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: S.of(context).language,
        backgroundColor: Colors.white,
        showBottom: true,
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              BlocProvider.of<SettingBloc>(context).add(UpdateSettingEvent(areaModel: selectedAppArea));
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
          _buildInfoContainer(areas[0]),
          _dividerWidget(),
          _buildInfoContainer(areas[1]),
        ],
      ),
    );
  }


  Widget _buildInfoContainer(AreaModel areaModel) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedAppArea = areaModel;
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
                    areaModel.name(context),
                    style: TextStyle(color: HexColor("#333333"), fontSize: 14),
                  ),
                ),
                Spacer(),
                Visibility(
                  visible: selectedAppArea.id == areaModel.id,
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
