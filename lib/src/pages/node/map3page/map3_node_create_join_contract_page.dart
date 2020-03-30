import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/node/map3page/map3_node_product_page.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';

class Map3NodeCreateJoinContractPage extends StatefulWidget {
  static const String CONTRACT_PAGE_TYPE_CREATE = "contract_page_type_create";
  static const String CONTRACT_PAGE_TYPE_JOIN = "contract_page_type_join";
  String pageType;

  Map3NodeCreateJoinContractPage(this.pageType);

  @override
  _Map3NodeCreateJoinContractState createState() =>
      new _Map3NodeCreateJoinContractState();
}

class _Map3NodeCreateJoinContractState
    extends State<Map3NodeCreateJoinContractPage> {
  TextEditingController _joinCoinController = new TextEditingController();
  final _joinCoinFormKey = GlobalKey<FormState>();
  String pageTitle = "";
  String managerTitle = "";

  @override
  void initState() {
    if (widget.pageType ==
        Map3NodeCreateJoinContractPage.CONTRACT_PAGE_TYPE_CREATE) {
      pageTitle = "创建Map3抵押合约";
      managerTitle = "获得管理费（HYN）：";
    } else {
      pageTitle = "参与Map3节点抵押";
      managerTitle = "应付管理费（HYN）：";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(pageTitle)),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _pageView(context),
        ),
      ),
    );
  }

  List<Widget> _pageView(BuildContext context) {
    return [
      Container(
          color: Colors.white,
          child: getMap3NodeProductItem(context, showButton: false)),
      Container(
        height: 5,
        color: DefaultColors.colorf5f5f5,
      ),
      if (widget.pageType ==
          Map3NodeCreateJoinContractPage.CONTRACT_PAGE_TYPE_JOIN)
        startAccount(),
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text("投入数量  （Moo钱包HYN余额 10,000）", style: TextStyles.textC333S14),
      ),
      Container(
          padding: const EdgeInsets.only(left: 30.0, right: 30, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Text(
                      "HYN",
                      style: TextStyles.textC333S14,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Form(
                      key: _joinCoinFormKey,
                      child: TextFormField(
                          controller: _joinCoinController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                          onChanged: (textStr){

                          },
                          decoration: InputDecoration(
                            hintStyle: TextStyles.textC9b9b9bS14,
                            labelStyle: TextStyles.textC333S14,
                            hintText: "投入量，不少于20,000",
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                          ),
                          validator: (textStr) {
                            return textStr.length != 0 &&
                                    int.parse(textStr) > 20000
                                ? null
                                : "不能少于20,000HYN";
                          }),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: FlatButton(
                      color: HexColor("#d2e5fb"),
                      child: Text(
                        "20,000HYN",
                        style: TextStyles.textC333S12,
                      ),
                      onPressed: () {},
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: FlatButton(
                      color: HexColor("#d2e5fb"),
                      child: Text("40,000HYN", style: TextStyles.textC333S12),
                      onPressed: () {},
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: FlatButton(
                      color: HexColor("#d2e5fb"),
                      child: Text("60,000HYN", style: TextStyles.textC333S12),
                      onPressed: () {},
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                child: RichText(
                  text: TextSpan(
                      text: "期满共产生（HYN）：",
                      style: TextStyles.textC9b9b9bS12,
                      children: [
                        TextSpan(
                          text: "21000",
                          style: TextStyles.textC333S14,
                        )
                      ]),
                ),
              ),
              RichText(
                text: TextSpan(
                    text: managerTitle,
                    style: TextStyles.textC9b9b9bS12,
                    children: [
                      TextSpan(
                        text: "1000",
                        style: TextStyles.textC333S14,
                      )
                    ]),
              ),
            ],
          )),
      Container(
        height: 2,
        color: DefaultColors.colorf5f5f5,
        margin: EdgeInsets.only(top: 15.0, bottom: 15, left: 10, right: 10),
      ),
      Container(
        padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("·  请确保阿克苏就离开房间啊来解放拉萨就", style: TextStyles.textCf29a6eS14),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 10),
              child: Text(
                  "·  请确保阿克苏就离开房间啊来解放拉萨就请确保阿克苏就离开房间啊来解放拉萨就请确保阿克苏就离开房间啊来解放拉萨就请确保阿克苏就离开房间啊来解放拉萨就",
                  style: TextStyles.textC9b9b9bS14),
            ),
            Text("·  请确保阿克苏就离开房间啊来解放拉萨就", style: TextStyles.textC9b9b9bS14),
          ],
        ),
      ),
      Container(
        margin: EdgeInsets.only(top: 10, bottom: 10),
        padding: EdgeInsets.symmetric(horizontal: 30),
        constraints: BoxConstraints.expand(height: 48),
        child: RaisedButton(
            textColor: Colors.white,
            color: DefaultColors.color0F95B0,
            shape: RoundedRectangleBorder(
                side: BorderSide(color: Theme.of(context).primaryColor),
                borderRadius: BorderRadius.circular(36)),
            child: Text("确定"),
            onPressed: () {
              setState(() {
                _joinCoinFormKey.currentState.validate();
                var activatedWalletVo =
                    WalletInheritedModel.of(context).activatedWallet;
                Application.router.navigateTo(
                    context,
                    Routes.map3node_send_confirm_page +
                        "?coinVo=${FluroConvertUtils.object2string(activatedWalletVo.coins[1].toJson())}" +
                        "&transferAmount=${_joinCoinController.text}&receiverAddress=055weffsfsfgsd");
              });
            }),
      )
    ];
  }

  Widget startAccount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text("发起账号"),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 15),
              child: Image.asset("res/drawable/hyn.png", width: 40, height: 40),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Moo", style: TextStyles.textC333S14),
                Text("ljaslfkjasldkjsldj", style: TextStyles.textC9b9b9bS12)
              ],
            )
          ],
        ),
        SizedBox(
          height: 15,
        ),
        Container(
          height: 5,
          color: DefaultColors.colorf5f5f5,
        ),
      ],
    );
  }

  int _getManagerPrice(int joinPrice) {}
}
