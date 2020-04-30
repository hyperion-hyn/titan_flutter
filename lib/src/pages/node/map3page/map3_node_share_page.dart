import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/pages/node/model/node_share_entity.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/utils/format_util.dart';

import 'dart:typed_data';

import 'package:titan/src/widget/widget_shot.dart';

class Map3NodeSharePage extends StatefulWidget {
  final ContractNodeItem contractNodeItem;

  Map3NodeSharePage(this.contractNodeItem);

  @override
  _Map3NodeSharePageState createState() => new _Map3NodeSharePageState();
}

class _Map3NodeSharePageState extends BaseState<Map3NodeSharePage> {
  final ShotController _shotController = new ShotController();
  List<String> imagesList = [];
  var shareAppImage = "res/drawable/location_privacy.jpeg";
  var shareData = "";

  @override
  void onCreated() {
    var activityWallet = WalletInheritedModel.of(context).activatedWallet;
    if (activityWallet != null) {
      Wallet wallet = WalletInheritedModel.of(context).activatedWallet.wallet;
      bool isFromOwn = wallet.getEthAccount().address == widget.contractNodeItem.owner;
      NodeShareEntity nodeShareEntity = NodeShareEntity(wallet.getEthAccount().address, "detail", isFromOwn);
      String encodeStr = FormatUtil.encodeBase64(json.encode(nodeShareEntity));
      shareData = "${widget.contractNodeItem.shareUrl}&key=$encodeStr";
    } else {
      shareData = "${widget.contractNodeItem.shareUrl}";
    }
    super.onCreated();

    Future.delayed(Duration(milliseconds: 500)).then((_) {
      _shareQr(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "分享合约",
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            color: Colors.white,
            tooltip: S.of(context).share,
            onPressed: () {
              _shareQr(context);
            },
          ),
        ],
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
//    var userInfo = AccountInheritedModel.of(context, aspect: AccountAspect.userInfo).userInfo;

   print("[map3]  shareData:$shareData");

    var wallet = WalletInheritedModel.of(context).activatedWallet;
    return WidgetShot(
      controller: _shotController,
      child: Container(
        decoration: BoxDecoration(
          gradient: new LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [
            HexColor("#1095b0"),
            HexColor("#137291"),
          ]),
        ),
        child: Column(
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: HexColor("#FFFFFEF8"),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ), // 也可控件一边圆角大小
                  ),
                ),
                Image.asset(
                  "res/drawable/ic_map3_node_item_2.png",
                  width: 200,
                  height: 180,
                ),
                Positioned(
                  left: 16,
                  top: 16,
                  child: Image.asset(
                    "res/drawable/ic_logo.png",
                    width: 40,
                    height: 40,
                    //color: Color(0xFFD9AC43),
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24.0, top: 40),
              child: Text(
                S.of(context).contract_share_content(
                    wallet?.wallet?.keystore?.name ?? '',
                    S.of(context).app_name,
                    widget.contractNodeItem.contract.nodeName,
                    FormatUtil.formatPercent(widget.contractNodeItem.contract.annualizedYield),
                    widget.contractNodeItem.contract.duration.toString()),
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40.0, bottom: 32),
              child: Container(
                color: Colors.white,
                child: QrImage(
                  data: shareData,
                  size: 131,
                ),
              ),
            ),
            Text(
              "扫描二维码查看详情",
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  void _shareQr(BuildContext context) async {
    Uint8List imageByte = await _shotController.makeImageUint8List();
    await Share.file(S.of(context).nav_share_app, 'app.png', imageByte, 'image/png');
  }
}
