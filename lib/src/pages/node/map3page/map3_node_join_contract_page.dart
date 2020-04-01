import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/map3page/map3_node_product_page.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/node_item.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';

import 'map3_node_create_contract_page.dart';

class Map3NodeJoinContractPage extends StatefulWidget {
  String pageType = Map3NodeCreateContractPage.CONTRACT_PAGE_TYPE_JOIN;
  String contractId;

  Map3NodeJoinContractPage(this.contractId);

  @override
  _Map3NodeJoinContractState createState() =>
      new _Map3NodeJoinContractState();
}

class _Map3NodeJoinContractState
    extends State<Map3NodeJoinContractPage> {
  TextEditingController _joinCoinController = new TextEditingController();
  final _joinCoinFormKey = GlobalKey<FormState>();
  String pageTitle = "";
  String managerTitle = "";
  AllPageState currentState = LoadingState();
  NodeApi _nodeApi = NodeApi();
  ContractNodeItem contractNodeItem;
  PublishSubject<String> _filterSubject = PublishSubject<String>();
  String endProfit = "";
  String spendManager = "";

  @override
  void initState() {
    pageTitle = "参与Map3节点抵押";
    managerTitle = "应付管理费（HYN）：";
    _joinCoinController.addListener(textChangeListener);

    _filterSubject.debounceTime(Duration(seconds: 2)).listen((text) {
      getCurrentSpend(text);
//      widget.fieldCallBack(text);
    });

    getNetworkData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(pageTitle)),
      backgroundColor: Colors.white,
      body: _pageView(context),
    );
  }

  void getNetworkData() async {
    try{
      contractNodeItem = await _nodeApi.getContractInstanceItem(widget.contractId);
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          currentState = null;
        });
      });
    }catch(e){
      setState(() {
        currentState = LoadFailState();
      });
    }
  }

  void textChangeListener(){
    _filterSubject.sink.add(_joinCoinController.text);
  }

  void getCurrentSpend(String inputText){
    if(contractNodeItem == null){
      return;
    }
    if(inputText == null || inputText == ""){
      setState(() {
        endProfit = "";
        spendManager = "";
      });
      return;
    }
    double inputValue = double.parse(inputText);
    double doubleEndProfit = inputValue * contractNodeItem.contract.annualizedYield * contractNodeItem.contract.duration / 12;
    double doubleSpendManager = inputValue * contractNodeItem.contract.commission / 12;
    endProfit = FormatUtil.formatNumDecimal(doubleEndProfit);
    spendManager = FormatUtil.formatNumDecimal(doubleSpendManager);

    setState(() {
      _joinCoinController.value = TextEditingValue(
      // 设置内容
      text: inputText,
      // 保持光标在最后
      selection: TextSelection.fromPosition(TextPosition(
      affinity: TextAffinity.downstream,
      offset: inputText.length)));
    });
  }

//  void pressJoinSuggest(int joinNum){
//    _joinCoinController.text = joinNum.toString();
//    _joinCoinController.selection
//    getCurrentSpend(joinNum.toString());
//  }

  @override
  void dispose() {
    _filterSubject.close();
    super.dispose();
  }

  Widget _pageView(BuildContext context) {
    if(currentState != null || contractNodeItem.contract == null){
      return AllPageStateContainer(currentState,(){
        setState(() {
          currentState = LoadingState();
        });
        getNetworkData();
      });
    }

    List<int> suggestList = contractNodeItem.contract.suggestQuantity.split(",").map(
            (suggest)=>int.parse(suggest)
    ).toList();
    double minTotal = contractNodeItem.contract.minTotalDelegation * contractNodeItem.contract.ownerMinDelegationRate;

    var activatedWallet = WalletInheritedModel.of(context).activatedWallet;
    var walletName = activatedWallet.wallet.keystore.name;
    var balance = WalletInheritedModel.of(context).activatedWallet.coins[1].balance;
    return SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          color: Colors.white,
          child: getMap3NodeProductItem(context, contractNodeItem.contract, showButton: false, )),
      Container(
        height: 5,
        color: DefaultColors.colorf5f5f5,
      ),
      startAccount(),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top:10.0, left:10),
            child: Text("节点配置"),
          ),
          Padding(
            padding: const EdgeInsets.only(top:15.0, left:20),
            child: Row(
              children: <Widget>[
                Container(
                    width: 100,
                    child: Text("服务商",style:TextStyles.textC9b9b9bS14)),
                new Text("阿里云",style: TextStyles.textC333S14)
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top:15.0, left:20),
            child: Row(
              children: <Widget>[
                Container(
                    width: 100,
                    child: Text("节点位置",style:TextStyles.textC9b9b9bS14)),
                new Text("中国深圳",style: TextStyles.textC333S14)
              ],
            ),
          ),
        ],
      ),
      Container(
        height: 5,
        margin: const EdgeInsets.only(top:15.0),
        color: DefaultColors.colorf5f5f5,
      ),
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text("投入数量  （$walletName钱包HYN余额 ${FormatUtil.formatNumDecimal(balance)}）", style: TextStyles.textC333S14),
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
                          inputFormatters: [
                            WhitelistingTextInputFormatter.digitsOnly
                          ],
                          onChanged: (textStr) {
                            _filterSubject.sink.add(textStr);
                          },
                          decoration: InputDecoration(
                            hintStyle: TextStyles.textC9b9b9bS14,
                            labelStyle: TextStyles.textC333S14,
                            hintText: "投入量，不少于${FormatUtil.formatNumDecimal(minTotal)}",
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                          ),
                          validator: (textStr) {
                            if(textStr.length == 0 || int.parse(textStr) < minTotal){
                              return "不能少于${FormatUtil.formatNumDecimal(minTotal)}HYN";
                            }else if(int.parse(textStr) > balance){
//                              return "HYN余额不足";
                              return null;
                            }else{
                              return null;
                            }
                          }),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              if(suggestList.length == 3)
                Row(
                  children: <Widget>[
                    Expanded(
                      child: FlatButton(
                        color: HexColor("#d2e5fb"),
                        child: Text(
                          "${FormatUtil.formatNum(suggestList[0])}HYN",
                          style: TextStyles.textC333S12,
                        ),
                        onPressed: () {
                          getCurrentSpend(suggestList[0].toString());
                        },
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: FlatButton(
                        color: HexColor("#d2e5fb"),
                        child: Text("${FormatUtil.formatNum(suggestList[1])}HYN", style: TextStyles.textC333S12),
                        onPressed: () {
                          getCurrentSpend(suggestList[1].toString());
                        },
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: FlatButton(
                        color: HexColor("#d2e5fb"),
                        child: Text("${FormatUtil.formatNum(suggestList[2])}HYN", style: TextStyles.textC333S12),
                        onPressed: () {
                          getCurrentSpend(suggestList[2].toString());
                        },
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
                          text: "$endProfit",
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
                        text: "$spendManager",
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
            Text("·  请确保钱包账户（$walletName）的ETH GAS费充足", style: TextStyles.textCf29a6eS14),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 10),
              child: Text(
                  "·  投入后，若在规定期限内Map3节点抵押合约不能积攒够启动所需HYN，则本次合约启动失败。投入HYN的钱包账户可提取自己投入的HYN资金。",
                  style: TextStyles.textC9b9b9bS14),
            ),
            Text("·  投入Map3节点后不可撤销。", style: TextStyles.textC9b9b9bS14),
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
                if(!_joinCoinFormKey.currentState.validate()){
                  return;
                }
                Application.router.navigateTo(
                    context,
                    Routes.map3node_send_confirm_page +
                        "?coinVo=${FluroConvertUtils.object2string(activatedWallet.coins[1].toJson())}" +
                        "&transferAmount=${_joinCoinController.text}&receiverAddress=${contractNodeItem.owner}" +
                "&pageType=${widget.pageType}" +
                "&contractId=${widget.contractId}");
              });
            }),
      )
    ]));
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
                Text("${contractNodeItem.ownerName}", style: TextStyles.textC333S14),
                Text("${contractNodeItem.owner}", style: TextStyles.textC9b9b9bS12)
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

}
