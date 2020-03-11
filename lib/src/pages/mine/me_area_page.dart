import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          S.of(context).app_area_setting,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        actions: <Widget>[
          InkWell(
            onTap: () {
              BlocProvider.of<SettingBloc>(context).add(UpdateSettingEvent(areaModel: selectedAppArea));
//              switchAppArea(selectedAppArea);
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              alignment: Alignment.centerRight,
              child: Text(
                S.of(context).confirm,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          )
        ],
      ),
      body: ListView(
          children: SupportedArea.all().map<Widget>((areaModel) {
        return _buildInfoContainer(areaModel);
      }).toList()),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1.0,
        color: HexColor('#D7D7D7'),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 15, 15, 13),
                  child: Text(
                    areaModel.name(context),
                    style: TextStyle(color: HexColor("#333333"), fontSize: 16),
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
          _divider()
        ],
      ),
    );
  }
}
