import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/node_item.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';

class Map3NodeCreateContractPage extends StatefulWidget {
  static const String CONTRACT_PAGE_TYPE_CREATE = "contract_page_type_create";
  static const String CONTRACT_PAGE_TYPE_JOIN = "contract_page_type_join";
  static const String CONTRACT_PAGE_TYPE_COLLECT = "contract_page_type_collect";

  String pageType = CONTRACT_PAGE_TYPE_CREATE;
  String contractId;

  Map3NodeCreateContractPage(this.contractId);

  @override
  _Map3NodeCreateContractState createState() =>
      new _Map3NodeCreateContractState();
}

class _Map3NodeCreateContractState extends State<Map3NodeCreateContractPage> {
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
  var selectServerItemValue;
  var selectNodeItemValue;
  List<DropdownMenuItem> serverList;
  List<DropdownMenuItem> nodeList;

  @override
  void initState() {
    pageTitle = "创建Map3抵押合约";
    managerTitle = "获得管理费（HYN）：";
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
//      appBar: AppBar(centerTitle: true, title: Text(pageTitle)),
      backgroundColor: Colors.white,
      body: _pageView(context),
    );
  }

  void getNetworkData() async {
    try {
      contractNodeItem = await _nodeApi.getContractItem(widget.contractId);

      List<String> serverListStr = ["亚马逊云（推荐）", "阿里云", "华为云"];
      serverList = new List();
      serverListStr.forEach((value) {
        DropdownMenuItem item = new DropdownMenuItem(
            value: value,
            child: new Text(
              value,
              style: TextStyles.textC333S14,
            ));
        serverList.add(item);
      });
      selectServerItemValue = serverList[0].value;

      List<String> nodeListStr = ["中国深圳（推荐）", "香港", "新加坡"];
      nodeList = new List();
      nodeListStr.forEach((value) {
        DropdownMenuItem item = new DropdownMenuItem(
            value: value,
            child: new Text(value, style: TextStyles.textC333S14));
        nodeList.add(item);
      });
      selectNodeItemValue = nodeList[0].value;

      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          currentState = null;
        });
      });
    } catch (e) {
      setState(() {
        currentState = LoadFailState();
      });
    }
  }

  void textChangeListener() {
    _filterSubject.sink.add(_joinCoinController.text);
  }

  void getCurrentSpend(String inputText) {
    if (contractNodeItem == null) {
      return;
    }
    if (inputText == null || inputText == "") {
      setState(() {
        endProfit = "";
        spendManager = "";
      });
      return;
    }
    double inputValue = double.parse(inputText);
    double doubleEndProfit = inputValue *
            contractNodeItem.contract.annualizedYield *
            contractNodeItem.contract.duration /
            365 +
        inputValue;
    double doubleSpendManager =
        (double.parse(contractNodeItem.contract.minTotalDelegation) -
                inputValue) *
            contractNodeItem.contract.annualizedYield *
            contractNodeItem.contract.duration /
            365 *
            contractNodeItem.contract.commission;
    endProfit = FormatUtil.formatNumDecimal(doubleEndProfit);
    spendManager = FormatUtil.formatNumDecimal(doubleSpendManager);

    setState(() {
      _joinCoinController.value = TextEditingValue(
          // 设置内容
          text: inputText,
          // 保持光标在最后
          selection: TextSelection.fromPosition(TextPosition(
              affinity: TextAffinity.downstream, offset: inputText.length)));
    });
  }

  @override
  void dispose() {
    _filterSubject.close();
    super.dispose();
  }

  Widget _pageView(BuildContext context) {
    if (currentState != null || contractNodeItem.contract == null) {
      return AllPageStateContainer(currentState, () {
        setState(() {
          currentState = LoadingState();
        });
        getNetworkData();
      });
    }

    var activatedWallet = WalletInheritedModel.of(context).activatedWallet;
    var walletName = activatedWallet.wallet.keystore.name;

    return SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      getMap3NodeProductHeadItem(context, contractNodeItem.contract),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Row(
              children: <Widget>[
                Container(
                    width: 100,
                    child: Text("节点版本",
                        style: TextStyle(
                            fontSize: 14, color: HexColor("#92979a")))),
                Text("${contractNodeItem.contract.nodeName}",
                    style: TextStyles.textC333S14),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 18.0, left: 15),
            child: Row(
              children: <Widget>[
                Container(
                    width: 100,
                    child: Text("服务商",
                        style: TextStyle(
                            fontSize: 14, color: HexColor("#92979a")))),
                DropdownButtonHideUnderline(
                  child: Container(
                    height: 30,
                    child: DropdownButton(
                      value: selectServerItemValue,
                      items: serverList,
                      onChanged: (value) {
                        setState(() {
                          selectServerItemValue = value;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 18.0, left: 15),
            child: Row(
              children: <Widget>[
                Container(
                    width: 100,
                    child: Text("节点位置",
                        style: TextStyle(
                            fontSize: 14, color: HexColor("#92979a")))),
                DropdownButtonHideUnderline(
                  child: Container(
                    height: 30,
                    child: DropdownButton(
                      value: selectNodeItemValue,
                      items: nodeList,
                      onChanged: (value) {
                        setState(() {
                          selectNodeItemValue = value;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      Container(
        height: 10,
        margin: const EdgeInsets.only(top: 16.0),
        color: DefaultColors.colorf5f5f5,
      ),
      getHoldInNum(context, contractNodeItem, _joinCoinFormKey,
          _joinCoinController, endProfit, spendManager, false, (textStr) {
        _filterSubject.sink.add(textStr);
      }, (textStr) {
        getCurrentSpend(textStr);
      }),
      /*Padding(
        padding: const EdgeInsets.only(left: 15.0, top: 13, bottom: 15),
        child: Text(
            "抵押HYN数量  （$walletName钱包HYN余额 ${FormatUtil.formatNumDecimal(balance)}）",
            style: TextStyles.textC333S14),
      ),
      Container(
          padding: const EdgeInsets.only(left: 15.0, right: 30, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "HYN",
                    style: TextStyle(fontSize: 18, color: HexColor("#35393E")),
                  ),
                  SizedBox(
                    width: 11,
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
                            hintText:
                                "最低买入${FormatUtil.formatNumDecimal(minTotal)}",
                          ),
                          validator: (textStr) {
                            if (textStr.length == 0 ||
                                int.parse(textStr) < minTotal) {
                              return "不能少于${FormatUtil.formatNumDecimal(minTotal)}HYN";
                            } else if (int.parse(textStr) > balance) {
//                              return "HYN余额不足";
                              return null;
                            } else {
                              return null;
                            }
                          }),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 17,
              ),
              if (suggestList.length == 3)
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 49,
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: FlatButton(
                                  color: HexColor("#FFFBED"),
                                  child: Text(
                                    "${FormatUtil.formatNum(suggestList[0])}HYN",
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: HexColor("#5C4304")),
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
                                  color: HexColor("#FFFBED"),
                                  child: Text(
                                      "${FormatUtil.formatNum(suggestList[1])}HYN",
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: HexColor("#5C4304"))),
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
                                  color: HexColor("#FFFBED"),
                                  child: Text(
                                      "${FormatUtil.formatNum(suggestList[2])}HYN",
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: HexColor("#5C4304"))),
                                  onPressed: () {
                                    getCurrentSpend(suggestList[2].toString());
                                  },
                                ),
                              )
                            ],
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 10.0, bottom: 10),
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
                      ),
                    ),
                  ],
                ),
            ],
          )),*/
      Container(
        height: 10,
        color: DefaultColors.colorf5f5f5,
        margin: EdgeInsets.only(top: 15.0, bottom: 15),
      ),
      Container(
        padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("·  请确保钱包账户（$walletName）的ETH GAS费充足",
                style: TextStyles.textC999S12),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 10),
              child: Text(
                  "·  创建后，若7天内没能积攒足够启动所需HYN，则本次Map3节点抵押合约启动失败。投入HYN的钱包账户可提取自己投入的HYN资金。",
                  style: TextStyles.textC999S12),
            ),
            Text("·  Map3节点抵押合约创建后不可撤销。", style: TextStyles.textC999S12),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 10),
              child: Text(
                  "·  创建节点需要暂时冻结500U账户余额，用于支付直推人的贡献奖励。直推人及奖励收取节点总收益的5%。",
                  style: TextStyles.textC999S12),
            ),
          ],
        ),
      ),
      Container(
        margin: EdgeInsets.only(top: 10, bottom: 10),
        padding: EdgeInsets.symmetric(horizontal: 30),
        constraints: BoxConstraints.expand(height: 48),
        child: RaisedButton(
            textColor: Colors.white,
            color: DefaultColors.color0f95b0,
            shape: RoundedRectangleBorder(
                side: BorderSide(color: Theme.of(context).primaryColor),
                borderRadius: BorderRadius.circular(36)),
            child: Text("确定"),
            onPressed: () {
              setState(() {
                if (!_joinCoinFormKey.currentState.validate()) {
                  return;
                }
                Application.router.navigateTo(
                    context,
                    Routes.map3node_send_confirm_page +
                        "?coinVo=${FluroConvertUtils.object2string(activatedWallet.coins[1].toJson())}" +
                        "&contractNodeItem=${FluroConvertUtils.object2string(contractNodeItem.toJson())}" +
                        "&transferAmount=${_joinCoinController.text}&receiverAddress=${WalletConfig.map3ContractAddress}" +
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
                Text("${contractNodeItem.ownerName}",
                    style: TextStyles.textC333S14),
                Text("${contractNodeItem.owner}",
                    style: TextStyles.textC9b9b9bS12)
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

Widget getHoldInNum(
    BuildContext context,
    ContractNodeItem contractNodeItem,
    GlobalKey<FormState> formKey,
    TextEditingController textEditingController,
    String endProfit,
    String spendManager,
    bool isJoin,
    Function onChangeFuntion,
    Function onPressFunction,
    {Function joinEnougnFunction}) {
  List<int> suggestList = contractNodeItem.contract.suggestQuantity
      .split(",")
      .map((suggest) => int.parse(suggest))
      .toList();
  double minTotal = isJoin
      ? double.parse(contractNodeItem.contract.minTotalDelegation) *
          contractNodeItem.contract.minDelegationRate
      : double.parse(contractNodeItem.contract.minTotalDelegation) *
          contractNodeItem.contract.ownerMinDelegationRate;
  var walletName =
      WalletInheritedModel.of(context).activatedWallet.wallet.keystore.name;
  var balance =
      WalletInheritedModel.of(context).activatedWallet.coins[1].balance;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(left: 15.0, top: 13, bottom: 15),
        child: Text(
            "抵押HYN数量  （$walletName钱包HYN余额 ${FormatUtil.formatNumDecimal(balance)}）",
            style: TextStyles.textC333S14),
      ),
      Container(
          padding: const EdgeInsets.only(left: 15.0, right: 30, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "HYN",
                    style: TextStyle(fontSize: 18, color: HexColor("#35393E")),
                  ),
                  SizedBox(
                    width: 11,
                  ),
                  Expanded(
                    child: Form(
                      key: formKey,
                      child: TextFormField(
                          controller: textEditingController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            WhitelistingTextInputFormatter.digitsOnly
                          ],
                          onChanged: (textStr) {
                            onChangeFuntion(textStr);
//                            _filterSubject.sink.add(textStr);
                          },
                          decoration: InputDecoration(
                            hintStyle: TextStyles.textC9b9b9bS14,
                            labelStyle: TextStyles.textC333S14,
                            hintText:
                                "最低买入${FormatUtil.formatNumDecimal(minTotal)}",
                          ),
                          validator: (textStr) {
                            if (textStr.length == 0 ||
                                int.parse(textStr) < minTotal) {
                              return "不能少于${FormatUtil.formatNumDecimal(minTotal)}HYN";
                            } else if (int.parse(textStr) > balance) {
//                              return "HYN余额不足";
                              return null;
                            } else {
                              return null;
                            }
                          }),
                    ),
                  ),
                  if (isJoin)
                    SizedBox(
                        height: 22,
                        width: 70,
                        child: FlatButton(
                          padding: const EdgeInsets.all(0),
                          color: HexColor("#FFDE64"),
                          onPressed: () {
                            joinEnougnFunction();
                          },
                          child: Text("足额买入",
                              style: TextStyle(
                                  fontSize: 12, color: HexColor("#5C4304"))),
                        ))
                ],
              ),
              SizedBox(
                height: 17,
              ),
              if (suggestList.length == 3)
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 49,
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: FlatButton(
                                  color: HexColor("#FFFBED"),
                                  padding: const EdgeInsets.all(0),
                                  child: Text(
                                    "${FormatUtil.formatNum(suggestList[0])}HYN",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: HexColor("#5C4304")),
                                  ),
                                  onPressed: () {
                                    onPressFunction(suggestList[0].toString());
//                                    getCurrentSpend(suggestList[0].toString());
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: FlatButton(
                                  color: HexColor("#FFFBED"),
                                  padding: const EdgeInsets.all(0),
                                  child: Text(
                                      "${FormatUtil.formatNum(suggestList[1])}HYN",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: HexColor("#5C4304"))),
                                  onPressed: () {
                                    onPressFunction(suggestList[1].toString());
//                                    getCurrentSpend(suggestList[1].toString());
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: FlatButton(
                                  color: HexColor("#FFFBED"),
                                  padding: const EdgeInsets.all(0),
                                  child: Text(
                                      "${FormatUtil.formatNum(suggestList[2])}HYN",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: HexColor("#5C4304"))),
                                  onPressed: () {
                                    onPressFunction(suggestList[2].toString());
//                                    getCurrentSpend(suggestList[2].toString());
                                  },
                                ),
                              )
                            ],
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 10.0, bottom: 10),
                            child: RichText(
                              text: TextSpan(
                                  text: "期满共产生(HYN)：",
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
                                text: isJoin ? "应付管理费(HYN)：" : "获得管理费(HYN)：",
                                style: TextStyles.textC9b9b9bS12,
                                children: [
                                  TextSpan(
                                    text: "$spendManager",
                                    style: TextStyles.textC333S14,
                                  )
                                ]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          )),
    ],
  );
}

Widget getMap3NodeProductHeadItem(BuildContext context, NodeItem nodeItem,
    {isJoin = false}) {
  return Stack(
    children: <Widget>[
      Container(
        height: 280,
        color: Colors.blue,
      ),
//      Image.asset("res/drawable/ic_map3_node_head.png",height:280,),
      InkWell(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 40.0, left: 15),
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: Text(
            isJoin ? "参与Map3节点抵押" : "创建Map3抵押合约",
            style: TextStyles.textCfffS17,
          ),
        ),
      ),
      Align(
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 80,
            ),
            RichText(
                text: TextSpan(
                    text:
                        "${FormatUtil.formatTenThousandNoUnit(nodeItem.minTotalDelegation)}",
                    style: TextStyles.textCfffS46,
                    children: <TextSpan>[
                  TextSpan(
                    text:
                        "万/${FormatUtil.formatPercent(nodeItem.annualizedYield)}",
                    style: TextStyles.textCfffS24,
                  )
                ])),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 20),
              child:
                  Text("共需投入资金(HYN) / 期满年化奖励", style: TextStyles.textCccfffS12),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                isJoin
                    ? Column(
                        children: <Widget>[
                          Text("最低投入", style: TextStyles.textCccfffS12),
                          Text(
                              "${FormatUtil.formatPercent(nodeItem.minDelegationRate)}",
                              style: TextStyles.textCfffS14)
                        ],
                      )
                    : Column(
                        children: <Widget>[
                          Text("创建最低投入", style: TextStyles.textCccfffS12),
                          Text(
                              "${FormatUtil.formatPercent(nodeItem.ownerMinDelegationRate)}",
                              style: TextStyles.textCfffS14)
                        ],
                      ),
                Container(
                  margin: const EdgeInsets.only(left: 10.0, right: 20),
                  width: 1,
                  height: 50,
                  color: Colors.white,
                ),
                Column(
                  children: <Widget>[
                    Text("合约期限", style: TextStyles.textCccfffS12),
                    Text("${nodeItem.duration}天", style: TextStyles.textCfffS14)
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(left: 20.0, right: 10),
                  width: 1,
                  height: 50,
                  color: Colors.white,
                ),
                Column(
                  children: <Widget>[
                    Text("管理费", style: TextStyles.textCccfffS12),
                    Text("${FormatUtil.formatPercent(nodeItem.commission)}收益",
                        style: TextStyles.textCfffS14)
                  ],
                ),
              ],
            ),
            _getHeadItemCard(nodeItem)
          ],
        ),
      )
    ],
  );
}

Widget _getHeadItemCard(NodeItem nodeItem) {
  var currentTime = new DateTime.now().millisecondsSinceEpoch;
  var durationTime = nodeItem.duration * 3600 * 24 * 1000;
  var tempHalfTime = durationTime / 2 + currentTime;
  int halfTime = int.parse(tempHalfTime.toStringAsFixed(0));
  var endTime = durationTime + currentTime;

  if (nodeItem.halfCollected) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      color: Colors.white,
      margin: const EdgeInsets.only(left: 14.0, right: 14, bottom: 16, top: 16),
      child: Padding(
          padding:
              const EdgeInsets.only(left: 22.0, right: 22, top: 21, bottom: 21),
          child: Stack(alignment: Alignment.topCenter, children: <Widget>[
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Container(
                            width: 13,
                            height: 13,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(
                                    color: HexColor("#322300"), width: 2)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 9.0, bottom: 9),
                            child: Text(
                              "今日加入",
                              style: TextStyle(
                                  fontSize: 12, color: HexColor("#4b4b4b")),
                            ),
                          ),
                          Text(
                              "${FormatUtil.formatDateCircle(currentTime, isSecond: false)}",
                              style: TextStyle(
                                  fontSize: 10, color: HexColor("#a7a7a7")))
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Container(
                            width: 13,
                            height: 13,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(
                                    color: HexColor("#322300"), width: 2)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 9.0, bottom: 9),
                            child: Text("提取奖励50%",
                                style: TextStyle(
                                    fontSize: 12, color: HexColor("#4b4b4b"))),
                          ),
                          Text(
                              "${FormatUtil.formatDateCircle(halfTime, isSecond: false)}",
                              style: TextStyle(
                                  fontSize: 10, color: HexColor("#a7a7a7")))
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Container(
                            width: 13,
                            height: 13,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(
                                    color: HexColor("#322300"), width: 2)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 9.0, bottom: 9),
                            child: Text("锁定期满可结束",
                                style: TextStyle(
                                    fontSize: 12, color: HexColor("#4b4b4b"))),
                          ),
                          Text(
                              "${FormatUtil.formatDateCircle(endTime, isSecond: false)}",
                              style: TextStyle(
                                  fontSize: 10, color: HexColor("#a7a7a7")))
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 22,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 23,
                      height: 1,
                      color: HexColor("#D6D6D6"),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10),
                      child: Text("具体以实际日期为准",
                          style: TextStyle(
                              fontSize: 12, color: HexColor("#AAAAAA"))),
                    ),
                    Container(
                      width: 23,
                      height: 1,
                      color: HexColor("#D6D6D6"),
                    ),
                  ],
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 70,
                  height: 1,
                  color: HexColor("#ECECEC"),
                ),
                SizedBox(width: 42, height: 13),
                Container(
                  width: 70,
                  height: 1,
                  color: HexColor("#ECECEC"),
                ),
              ],
            )
          ])),
    );
  } else {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      color: Colors.white,
      margin: const EdgeInsets.only(left: 14.0, right: 14, bottom: 16, top: 16),
      child: Padding(
          padding:
              const EdgeInsets.only(left: 22.0, right: 22, top: 21, bottom: 21),
          child: Stack(alignment: Alignment.topCenter, children: <Widget>[
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Container(
                            width: 13,
                            height: 13,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(
                                    color: HexColor("#322300"), width: 2)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 9.0, bottom: 9),
                            child: Text(
                              "今日加入",
                              style: TextStyle(
                                  fontSize: 12, color: HexColor("#4b4b4b")),
                            ),
                          ),
                          Text(
                              "${FormatUtil.formatDateCircle(currentTime, isSecond: false)}",
                              style: TextStyle(
                                  fontSize: 10, color: HexColor("#a7a7a7")))
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Container(
                            width: 13,
                            height: 13,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(
                                    color: HexColor("#322300"), width: 2)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 9.0, bottom: 9),
                            child: Text("锁定期满可结束",
                                style: TextStyle(
                                    fontSize: 12, color: HexColor("#4b4b4b"))),
                          ),
                          Text(
                              "${FormatUtil.formatDateCircle(endTime, isSecond: false)}",
                              style: TextStyle(
                                  fontSize: 10, color: HexColor("#a7a7a7")))
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 22,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 23,
                      height: 1,
                      color: HexColor("#D6D6D6"),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10),
                      child: Text(
                        "具体以实际日期为准",
                        style:
                            TextStyle(fontSize: 12, color: HexColor("#AAAAAA")),
                      ),
                    ),
                    Container(
                      width: 23,
                      height: 1,
                      color: HexColor("#D6D6D6"),
                    ),
                  ],
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(width: 42, height: 13),
                Container(
                  width: 100,
                  height: 1,
                  color: HexColor("#ECECEC"),
                ),
                SizedBox(width: 42, height: 13)
              ],
            )
          ])),
    );
  }
}

/*Widget getMap3NodeProductHeadItem(BuildContext context,NodeItem nodeItem,{hasRemind = false,showMinDelegation = false}) {
  return Padding(
    padding: EdgeInsets.only(left: 10.0, right: 10, top: 20, bottom: 10),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Image.asset(
                "res/drawable/ic_map3_node_item.png",
                width: 50,
                height: 50,
                fit:BoxFit.cover,
              ),
            ),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(nodeItem.nodeName, style: TextStyles.textC333S14bold),
                          SizedBox(height: 5,),
                          Text("启动共需${FormatUtil.stringFormatNum(nodeItem.minTotalDelegation)}HYN",
                              style: TextStyles.textC333S14)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        Container(
          height: 3,
          margin: EdgeInsets.only(top: 10, bottom: 10),
          color: DefaultColors.colorf5f5f5,
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: Center(
                  child: Column(
                    children: <Widget>[
                      Text("期满年化奖励", style: TextStyles.textC9b9b9bS12),
                      Text("${FormatUtil.formatPercent(nodeItem.annualizedYield)}", style: TextStyles.textC333S14)
                    ],
                  )),
            ),
            Expanded(
              child: Center(
                  child: Column(
                    children: <Widget>[
                      Text("合约期限", style: TextStyles.textC9b9b9bS12),
                      Text("${nodeItem.duration}天", style: TextStyles.textC333S14)
                    ],
                  )),
            ),
            Expanded(
              child: Center(
                  child: Column(
                    children: <Widget>[
                      Text("管理费", style: TextStyles.textC9b9b9bS12),
                      Text("${FormatUtil.formatPercent(nodeItem.commission)}", style: TextStyles.textC333S14)
                    ],
                  )),
            ),
//            if(showMinDelegation)
              Expanded(
                child: Center(
                    child: Column(
                      children: <Widget>[
                        Text(showMinDelegation ? "创建最低投入" : "最低投入", style: TextStyles.textC9b9b9bS12),
                        Text(showMinDelegation ? "${FormatUtil.formatPercent(nodeItem.ownerMinDelegationRate)}"
                            : "${FormatUtil.formatPercent(nodeItem.minDelegationRate)}", style: TextStyles.textC333S14)
                      ],
                    )),
              )
          ],
        ),
        if(hasRemind)
          Padding(
            padding: const EdgeInsets.only(top:8.0),
            child: Text("注：合约生效满90天后，即可提取50%奖励", style: TextStyles.textCf29a6eS12),
          )
      ],
    ),
  );
}*/
