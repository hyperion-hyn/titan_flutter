import 'dart:async';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/home/contribution_page.dart';
import 'package:titan/src/business/position/bloc/bloc.dart';
import 'package:titan/src/business/position/model/business_time.dart';
import 'package:titan/src/business/wallet/service/wallet_service.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/open_location_code.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/RoundCheckBox.dart';
import '../wallet/wallet_create_new_account_page.dart';
import 'package:titan/src/business/wallet/wallet_import_account_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/business/wallet/wallet_bloc/wallet_bloc.dart';
import 'package:titan/src/business/wallet/wallet_bloc/wallet_event.dart';
import 'package:titan/src/business/wallet/wallet_bloc/wallet_state.dart';
import 'package:titan/src/global.dart';
import '../wallet/wallet_manager/wallet_manager.dart';
import 'model/category_item.dart';

class BusinessTimePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BusinessTimeState();
  }
}

class _BusinessTimeState extends State<BusinessTimePage> {
  PositionBloc _positionBloc = PositionBloc();
  TextEditingController _timeController = TextEditingController();
  List<CategoryItem> categoryList = [];
  String selectCategory = "";
  List<BusinessDayItem> _dayList;
  BusinessTimeItem currentTime;
  List<String> _dayLabel = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"];
  List<String> _timeLabel = [
    "全天（24小时）",
    "07:00-23:00",
    "08:00-18:00",
    "08:00-18:30",
    "08:30-17:30",
    "09:00-18:00",
    "09:30-22:00",
    "09:00-22:00",
    "10:00-20:00",
    "10:00-21:00"
  ];
  List<BusinessTimeItem> _timeList;

  @override
  void initState() {
    _dayList =
        _dayLabel.map((labelStr) => BusinessDayItem(label: labelStr)).toList();
    _timeList = _timeLabel
        .map((labelStr) => BusinessTimeItem(label: labelStr))
        .toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          '营业时间',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: <Widget>[
          InkWell(
            onTap: () {
              bool hasCheck = false;
              String customTime = _timeController.text;
              _dayList.forEach((item) => {
                    if (item.isCheck) {hasCheck = true}
                  });
              if (!hasCheck || (currentTime == null && customTime.isEmpty)) {
                Fluttertoast.showToast(msg: "请选择营业时间");
                return;
              }

              if (currentTime == null && isRightTime(customTime)) {
                currentTime = BusinessTimeItem();
                currentTime.label = customTime;
              } else if (currentTime == null && !isRightTime(customTime)){
                Fluttertoast.showToast(msg: "请输入正确的时间，例如 07:00-23:00");
                return;
              }

              BusinessInfo businessInfo =
                  BusinessInfo(dayList: _dayList, timeStr: currentTime.label);
              Navigator.pop(context, businessInfo);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              alignment: Alignment.centerRight,
              child: Text(
                '完成',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          )
        ],
      ),
      body: _buildView(context),
    );
  }

  bool isRightTime(String customTime) {
    return RegExp("([0-1]?[0-9]|2[0-3]):([0-5][0-9])-([0-1]?[0-9]|2[0-3]):([0-5][0-9])").hasMatch(customTime);
  }

  Widget _buildView(BuildContext context) {
    return BlocBuilder<PositionBloc, PositionState>(
      bloc: _positionBloc,
      builder: (BuildContext context, PositionState state) {
        if (state is InitialPositionState) {
          return _buildBody();
        } else {
          return Container(
            width: 0.0,
            height: 0.0,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _positionBloc.close();
    super.dispose();
  }

  Widget _buildTimeItem(BusinessTimeItem timeItem) {
    TextStyle textStyle =
        timeItem.isCheck ? TextStyles.textC333S14 : TextStyles.textC777S14;
    String imagePath = timeItem.isCheck
        ? "res/drawable/ic_business_time_switch_on.png"
        : "res/drawable/ic_business_time_switch_off.png";
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15),
      height: 41,
      child: Row(
        children: <Widget>[
          Text(
            timeItem.label,
            style: textStyle,
          ),
          Spacer(),
          Image.asset(imagePath, width: 24, height: 15)
          /*Switch(value: timeItem.isCheck,
            activeColor: Colors.blue,
            onChanged: (bool val){

            })*/
        ],
      ),
    );
  }

  Widget _buildBody() {
    return ListView(padding: EdgeInsets.only(top: 20), children: <Widget>[
      Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _buildDayView()),
      Padding(
          padding: EdgeInsets.only(left: 15),
          child: Text("营业时间", style: TextStyles.textC333S14)),
      Column(children: _buildBusinessTime()),
      _buildCustomTime()
//    getabc()
    ]);
  }

  List<Widget> _buildDayView() {
    return _dayList
        .map((item) => InkWell(
              onTap: () {
                item.isCheck = !item.isCheck;
                setState(() {});
              },
              child: Column(children: <Widget>[
                Text(item.label, style: TextStyles.textC333S14),
                RoundCheckBox(value: item.isCheck, onChanged: null)
              ]),
            ))
        .toList();
  }

  List<Widget> _buildBusinessTime() {
    return _timeList
        .map(
          (item) => InkWell(
              onTap: () {
                if (currentTime != null) {
                  currentTime.isCheck = false;
                }
                item.isCheck = !item.isCheck;
                currentTime = item;
                setState(() {});
              },
              child: _buildTimeItem(item)),
        )
        .toList();
  }

  Widget _buildCustomTime() {
    return Stack(
        alignment: AlignmentDirectional.centerStart,
        children: <Widget>[
          Container(
            color: HexColor("#f8f8f8"),
            height: 40,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Image.asset("res/drawable/ic_business_time_add_custom.png",
                    width: 15, height: 15),
                SizedBox(width: 10, height: 1),
                Expanded(
                  child: TextField(
                      controller: _timeController,
                      decoration: new InputDecoration(
                        border: InputBorder.none,
//                  contentPadding: const EdgeInsets.all(10.0),
                        hintStyle: TextStyles.textCaaaS14,
                        hintText: '添加时间',
                      )),
                )
              ],
            ),
          )
        ]);
  }
}
