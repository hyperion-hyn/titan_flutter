import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/node_item.dart';
import 'package:titan/src/pages/node/model/node_provider_entity.dart';
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

  final String pageType = CONTRACT_PAGE_TYPE_CREATE;
  final String contractId;

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
  var selectServerItemValue = 0;
  var selectNodeItemValue = 0;
  List<DropdownMenuItem> serverList;
  List<DropdownMenuItem> nodeList;
  List<NodeProviderEntity> providerList = [];

  @override
  void initState() {
    pageTitle = "创建Map3抵押合约";
    managerTitle = "获得管理费（HYN）：";
    _joinCoinController.addListener(textChangeListener);

    _filterSubject.debounceTime(Duration(milliseconds: 500)).listen((text) {
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

      providerList = await _nodeApi.getNodeProviderList();
      selectNodeProvider(0, 0);

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

  void selectNodeProvider(int providerIndex, int regionIndex) {
    if (providerList.length == 0) {
      return;
    }

    serverList = new List();
    for (int i = 0; i < providerList.length; i++) {
      NodeProviderEntity nodeProviderEntity = providerList[i];
      DropdownMenuItem item = new DropdownMenuItem(
          value: i,
          child: new Text(
            nodeProviderEntity.name,
            style: TextStyles.textC333S14,
          ));
      serverList.add(item);
    }
    selectServerItemValue = serverList[providerIndex].value;

    List<Regions> nodeListStr = providerList[providerIndex].regions;
    nodeList = new List();
    for (int i = 0; i < nodeListStr.length; i++) {
      Regions regions = nodeListStr[i];
      DropdownMenuItem item = new DropdownMenuItem(
          value: i,
          child: new Text(regions.name, style: TextStyles.textC333S14));
      nodeList.add(item);
    }
    selectNodeItemValue = nodeList[regionIndex].value;
  }

  void textChangeListener() {
    _filterSubject.sink.add(_joinCoinController.text);
  }

  void getCurrentSpend(String inputText) {
    if (contractNodeItem == null) {
      return;
    }

    _joinCoinFormKey.currentState.validate();

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

    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
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
                                selectNodeProvider(value, 0);
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
                                selectNodeProvider(selectServerItemValue, value);
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
          ])),
        ),
        Container(
          constraints: BoxConstraints.expand(height: 50),
          child: RaisedButton(
              textColor: Colors.white,
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: Theme.of(context).primaryColor),),
              child: Text("确定买入"),
              onPressed: () {
                setState(() {
                  if (!_joinCoinFormKey.currentState.validate()) {
                    return;
                  }
                  String provider = providerList[selectServerItemValue].id;
                  String region = providerList[selectServerItemValue]
                      .regions[selectNodeItemValue]
                      .id;
                  Application.router.navigateTo(
                      context,
                      Routes.map3node_send_confirm_page +
                          "?coinVo=${FluroConvertUtils.object2string(activatedWallet.coins[1].toJson())}" +
                          "&contractNodeItem=${FluroConvertUtils.object2string(contractNodeItem.toJson())}" +
                          "&transferAmount=${_joinCoinController.text}&receiverAddress=${WalletConfig.map3ContractAddress}" +
                          "&provider=$provider" +
                          "&region=$region" +
                          "&pageType=${widget.pageType}" +
                          "&contractId=${widget.contractId}");
                });
              }),
        )
      ],
    );
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
    {Function joinEnougnFunction,bool isMyself = false}) {
  // todo: test_jison_0411
  //List<int> suggestList = [];
  List<int> suggestList = contractNodeItem.contract.suggestQuantity
      .split(",")
      .map((suggest) => int.parse(suggest))
      .toList();

  double minTotal = 0;
  if (isJoin) {
    double tempMinTotal =
        double.parse(contractNodeItem.contract.minTotalDelegation) *
            contractNodeItem.contract.minDelegationRate;
    if (tempMinTotal >= double.parse(contractNodeItem.remainDelegation)) {
      minTotal = double.parse(contractNodeItem.remainDelegation);
    } else {
      minTotal = tempMinTotal;
    }
  } else {
    minTotal = double.parse(contractNodeItem.contract.minTotalDelegation) *
        contractNodeItem.contract.ownerMinDelegationRate;
  }

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
                            if(textStr.length == 0){
                              return null;
                            } else if (int.parse(textStr) < minTotal) {
                              return "不能少于${FormatUtil.formatNumDecimal(minTotal)}HYN";
                            } else if (int.parse(textStr) > balance) {
                              return "HYN余额不足";
                            } else {
                              return null;
                            }
                          }),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 17,
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 49,
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (!isJoin && suggestList.length == 3)
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
                                  },
                                ),
                              )
                            ],
                          ),
                        if (isJoin)
                          Row(
                            children: <Widget>[
                              RichText(
                                text: TextSpan(
                                    text: "剩余份额(HYN)：",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: HexColor("#333333"),
                                        fontWeight: FontWeight.bold),
                                    children: [
                                      TextSpan(
                                        text:
                                            "${FormatUtil.stringFormatNum(contractNodeItem.remainDelegation)}",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: HexColor("#333333"),
                                            fontWeight: FontWeight.bold),
                                      )
                                    ]),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              SizedBox(
                                  height: 22,
                                  width: 70,
                                  child: FlatButton(
                                    padding: const EdgeInsets.all(0),
                                    color: HexColor("#FFDE64"),
                                    onPressed: () {
                                      joinEnougnFunction();
                                    },
                                    child: Text("全部买入",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: HexColor("#5C4304"))),
                                  )),
                            ],
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, bottom: 10),
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
                        if(!isMyself)
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
    {isJoin = false, isDetail = true}) {
  var title = !isDetail?"节点抵押合约详情":isJoin ? "参与Map3节点抵押" : "创建Map3抵押合约";
  return Stack(
    children: <Widget>[
      Container(
        height: isDetail?280:250,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
//          borderRadius: BorderRadius.only(bottomLeft:Radius.circular(15),bottomRight:Radius.circular(15),), // 也可控件一边圆角大小
        )
      ),
      Positioned(
        top: 60,
        left: -20,
        child: Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            gradient: new LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  HexColor("#22ffffff"),
                  HexColor("#00ffffff"),
                ]),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(60)), // 也可控件一边圆角大小
          ),
        ),
      ),
      Positioned(
        top: 100,
        right: -20,
        child: Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            gradient: new LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  HexColor("#22ffffff"),
                  HexColor("#00ffffff"),
                ]),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(60)), // 也可控件一边圆角大小
          ),
        ),
      ),
      Positioned(
        top: 50,
        right: 120,
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            gradient: new LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  HexColor("#22ffffff"),
                  HexColor("#00ffffff"),
                ]),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(60)), // 也可控件一边圆角大小
          ),
        ),
      ),
      InkWell(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 44.0, left: 15),
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 44.0),
          child: Text(
            title,
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
              height: 90,
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
                  height: 40,
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
                  height: 40,
                  color: Colors.white,
                ),
                Column(
                  children: <Widget>[
                    Text("管理费", style: TextStyles.textCccfffS12),
                    Text("${FormatUtil.formatPercent(nodeItem.commission)}",
                        style: TextStyles.textCfffS14)
                  ],
                ),
              ],
            ),
            if (isDetail) _getHeadItemCard(nodeItem),
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
                            child: Text("期满结束",
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
                SizedBox(width: 72),
                Expanded(
                  child: Container(
//                    width: 70,
                    height: 1,
                    color: HexColor("#ECECEC"),
                  ),
                ),
                SizedBox(width: 42, height: 13),
                Expanded(
                  child: Container(
//                    width: 70,
                    height: 1,
                    color: HexColor("#ECECEC"),
                  ),
                ),
                SizedBox(width: 72),
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
                            child: Text("期满结束",
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