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
  ContractNodeItem contractNodeItem;

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
    if(activityWallet != null) {
      Wallet wallet = WalletInheritedModel
          .of(context)
          .activatedWallet
          .wallet;
      bool isFromOwn = wallet
          .getEthAccount()
          .address == widget.contractNodeItem.owner;
      NodeShareEntity nodeShareEntity = NodeShareEntity(wallet
          .getEthAccount()
          .address, "detail", isFromOwn);
      String encodeStr = FormatUtil.encodeBase64(json.encode(nodeShareEntity));
      shareData = "${widget.contractNodeItem.shareUrl}&key=$encodeStr";
    }else{
      shareData = "${widget.contractNodeItem.shareUrl}";
    }
    super.onCreated();
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
                  height: 234,
                  decoration: BoxDecoration(
                    color: HexColor("#fffef8"),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(60),bottomRight: Radius.circular(60),), // 也可控件一边圆角大小
                  ),
                ),
                Image.asset("res/drawable/ic_map3_node_item_2_big.png",width: 200,height: 184,),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top:31.0,bottom: 30),
              child: Text("节点创建成功！",style: TextStyle(fontSize: 30, color:Colors.white, fontWeight: FontWeight.bold),),
            ),
            Padding(
              padding: const EdgeInsets.only(left:30,right:30.0),
              child: Text("    ${widget.contractNodeItem.ownerName}在titan地图上创建了Map3节点抵押合约，年化奖励${FormatUtil.formatPercent(widget.contractNodeItem.contract.annualizedYield)}，"
                  + "周期${widget.contractNodeItem.contract.duration}天，合约马上启动，邀请你前往围观！",style: TextStyle( color:Colors.white, fontSize: 16),textAlign: TextAlign.center,),
            ),
            Padding(
              padding: const EdgeInsets.only(top:50.0,bottom: 30),
              child: Container(
                color: Colors.white,
                child: QrImage(
                  data: shareData,
                  size: 131,
                ),
              ),
            ),
            Text("长按图片识别二维码查看详情",style: TextStyle( color:Colors.white, fontSize: 15),),
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
