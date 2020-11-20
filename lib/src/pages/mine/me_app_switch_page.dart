import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/main.dart' as Main;
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_http.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/pages/market/api/exchange_const.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import '../../../env.dart';
import '../../../main.dart';

class MeAppSwitchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MeAppSwitchState();
  }
}

class _MeAppSwitchState extends State<MeAppSwitchPage> {
  @override
  void initState() {
    super.initState();
  }

  String selectedAppArea;

  @override
  Widget build(BuildContext context) {
    if (selectedAppArea == null) {
      selectedAppArea = env.buildType == BuildType.DEV ? '测试环境' : '正式环境';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          '切换App环境',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(children: [
        _buildInfoContainer('测试环境'),
        _buildInfoContainer('正式环境'),
      ]),
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

  Widget _buildInfoContainer(String title) {
    return InkWell(
      onTap: () {
        selectedAppArea = title;

        if (title == '正式环境') {
          BuildEnvironment.switchEnv(channel: BuildChannel.OFFICIAL, buildType: BuildType.PROD);
        } else {
          BuildEnvironment.switchEnv(channel: BuildChannel.OFFICIAL, buildType: BuildType.DEV);
        }

        print("[$runtimeType] env.buildType:${env.buildType.toString()}");

        ExchangeConst.EXCHANGE_DOMAIN = Const.EXCHANGE_DOMAIN;
        ExchangeConst.WS_DOMAIN = Const.WS_DOMAIN;

        AtlasHttpCore.clearInstance();
        AtlasHttpCoreNoLog.clearInstance();
        ExchangeHttp.clearInstance();
        WalletConfig.clearNetType();
        ExchangeApi().init();


        Keys.componentKey = GlobalKey(debugLabel: '__component__');
        Keys.materialAppKey = GlobalKey(debugLabel: '__app__');


        Navigator.pop(context);

        RestartWidget.restartApp(context);
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
                    title,
                    style: TextStyle(color: HexColor("#333333"), fontSize: 16),
                  ),
                ),
                Spacer(),
                Visibility(
                  visible: selectedAppArea == title,
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
