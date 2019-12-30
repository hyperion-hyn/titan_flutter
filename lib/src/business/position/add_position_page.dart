import 'dart:async';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/utils/styles.dart';
import 'package:titan/src/basic/widget/input_view.dart';
import 'package:titan/src/business/home/contribution_page.dart';
import 'package:titan/src/business/position/bloc/bloc.dart';
import 'package:titan/src/business/wallet/service/wallet_service.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:titan/src/utils/utils.dart';
import '../wallet/wallet_create_new_account_page.dart';
import 'package:titan/src/business/wallet/wallet_import_account_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/business/wallet/wallet_bloc/wallet_bloc.dart';
import 'package:titan/src/business/wallet/wallet_bloc/wallet_event.dart';
import 'package:titan/src/business/wallet/wallet_bloc/wallet_state.dart';
import 'package:titan/src/global.dart';
import '../wallet/wallet_manager/wallet_manager.dart';

class AddPositionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddPositionState();
  }
}

class _AddPositionState extends State<AddPositionPage> {
  PositionBloc _positionBloc = PositionBloc();
  TextEditingController _positionSiteName = TextEditingController();

  @override
  void initState() {
    _positionBloc.add(AddPositionEvent());

//    _eventbusSubcription = eventBus.on().listen((event) {
//      if (event is ScanWalletEvent) {
//        _walletBloc.add(ScanWalletEvent());
//      }
//    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          S.of(context).data_position_adding,
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: <Widget>[
          InkWell(
            onTap: () {
//              switchLanguage(selectedLocale);
//              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              alignment: Alignment.centerRight,
              child: Text(
                S.of(context).data_save,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          )
        ],
      ),
      body: _buildView(context),
    );
  }

  Widget _buildView(BuildContext context) {
    return BlocBuilder<PositionBloc, PositionState>(
      bloc: _positionBloc,
      builder: (BuildContext context, PositionState state) {
        if (state is InitialPositionState) {
//          return _walletTipsView();
          // todo
          return _buildLoading(context);
        } else if (state is AddPositionState) {
//          return _listView();
          return _buildBody();
        } else if (state is ScanWalletLoadingState) {
//          return _buildLoading(context);
          // todo
          return _buildLoading(context);
        } else {
          return Container(
            width: 0.0,
            height: 0.0,
          );
        }
      },
    );
  }

  Widget _buildLoading(context) {
    return Center(
      child: SizedBox(
        height: 40,
        width: 40,
        child: CircularProgressIndicator(
          strokeWidth: 3,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _positionBloc.close();
    super.dispose();
  }

  /*Widget _buildBody() {
    return Padding(
        padding: const EdgeInsets.only(top: 26, left: 15, right: 15),
        child: ListView(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start, // // 主轴方向（横向）对齐方式
                crossAxisAlignment: CrossAxisAlignment.center, // 交叉轴（竖直）对其方式
                children: <Widget>[
                  Text('类别', style: TextStyle(color: Colors.black)),
                  SizedBox(
                      width: 10,
                      height: 10,
                      child: Text('*', style: TextStyle(color: Colors.red))),
                  Text('书店', style: TextStyle(color: Colors.grey)),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                  )
                ],
              ),
              Gaps.line,
              TextFieldItem(
                  title: "联系方式",
                  hintText: "请输入联系人电话",
                  keyboardType: TextInputType.phone,
                  maxLength: 11)
            ]));
  }*/

  Widget _buildBody() {
    return Container(
        decoration: new BoxDecoration(color: Color(0xfff8f8f8)),
        padding: const EdgeInsets.only(top: 26),
        child: ListView(
//            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  height: 40,
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  decoration: new BoxDecoration(color: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    // // 主轴方向（横向）对齐方式
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // 交叉轴（竖直）对其方式
                    children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Text('类别',
                              style: TextStyle(color: Colors.black))),
                      Expanded(
                          child: SizedBox(
                              width: 10,
                              height: 10,
                              child: Text('*',
                                  style: TextStyle(color: Colors.red)))),
                      Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text('书店',
                              style:
                              TextStyle(color: Colors.grey, fontSize: 14))),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.grey,
                      )
                    ],
                  )),
              Container(
                  height: 42,
                  padding:
                  const EdgeInsets.only(left: 15, right: 15, bottom: 6),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      // // 主轴方向（横向）对齐方式
                      crossAxisAlignment: CrossAxisAlignment.end,
                      // 交叉轴（竖直）对其方式
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Text('地点名',
                                style: TextStyle(color: Colors.black))),
                        SizedBox(
                            width: 10,
                            height: 15,
                            child:
                            Text('*', style: TextStyle(color: Colors.red)))
                      ]
                  )
              ),
              Container(
                  height: 40,
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  decoration: new BoxDecoration(color: Colors.white),
                  child: TextFormField(
                    controller: _positionSiteName,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '该地点名称'
                    ),
                    /*validator: (value) {
                          RegExp reg = new RegExp(r'^\d{11}$');
                          if (!reg.hasMatch(value)) {
                            return '请输入地点名称';
                          }
                          return null;
                        },*/
                    keyboardType: TextInputType.text,
                  )
              ),
              _titleWidget("abc",true,true,14)
            ]
        )
    );
  }

  Widget _titleWidget(String titleName,bool hasRedPoint,bool hasIcon,double textSize){
    var redPoint;
    if(hasRedPoint){
      redPoint = SizedBox(
          width: 10,
          height: 15,
          child:
          Text('*', style: TextStyle(color: Colors.red))
      );
    }else{
      redPoint = null;
    }

    return Container(
        height: 42,
        padding:
        const EdgeInsets.only(left: 15, right: 15, bottom: 6),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            // // 主轴方向（横向）对齐方式
            crossAxisAlignment: CrossAxisAlignment.end,
            // 交叉轴（竖直）对其方式

            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Text(titleName,
                      style: TextStyle(color: Colors.black,fontSize: textSize))),
              redPoint
            ]

        )
    );
  }



}
