import 'dart:convert';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/node_item.dart';
import 'package:titan/src/pages/node/model/node_provider_entity.dart';
import 'package:titan/src/pages/node/model/node_share_entity.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
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
  _Map3NodeCreateContractState createState() => new _Map3NodeCreateContractState();
}

class _Map3NodeCreateContractState extends State<Map3NodeCreateContractPage> {
  TextEditingController _joinCoinController = new TextEditingController();
  final _joinCoinFormKey = GlobalKey<FormState>();
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
      backgroundColor: Color(0xffF3F0F5),
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
      DropdownMenuItem item =
          new DropdownMenuItem(value: i, child: new Text(regions.name, style: TextStyles.textC333S14));
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

    _joinCoinFormKey.currentState?.validate();

    if (inputText == null || inputText == "") {
      setState(() {
        endProfit = "";
        spendManager = "";
      });
      return;
    }
    double inputValue = double.parse(inputText);
    double doubleEndProfit =
        inputValue * contractNodeItem.contract.annualizedYield * contractNodeItem.contract.duration / 365 + inputValue;
    double doubleSpendManager = (double.parse(contractNodeItem.contract.minTotalDelegation) - inputValue) *
        contractNodeItem.contract.annualizedYield *
        contractNodeItem.contract.duration /
        365 *
        contractNodeItem.contract.commission;
    endProfit = FormatUtil.formatNumDecimal(doubleEndProfit);
    spendManager = FormatUtil.formatNumDecimal(doubleSpendManager);

    if (mounted) {
      setState(() {
        _joinCoinController.value = TextEditingValue(
            // 设置内容
            text: inputText,
            // 保持光标在最后
            selection:
                TextSelection.fromPosition(TextPosition(affinity: TextAffinity.downstream, offset: inputText.length)));
      });
    }
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
            getMap3NodeProductHeadItem(context, contractNodeItem),
//            SizedBox(height: 16,),
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 15, top: 16),
                    child: Row(
                      children: <Widget>[
                        Container(
                            width: 100,
                            child: Text(S.of(context).node_version,
                                style: TextStyle(fontSize: 14, color: HexColor("#92979a")))),
                        Text("${contractNodeItem.contract.nodeName}", style: TextStyles.textC333S14),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, left: 15),
                    child: Row(
                      children: <Widget>[
                        Container(
                            width: 100,
                            child: Text(S.of(context).service_provider,
                                style: TextStyle(fontSize: 14, color: HexColor("#92979a")))),
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
                    padding: EdgeInsets.only(top: 16.0, left: 15, bottom: 6),
                    child: Row(
                      children: <Widget>[
                        Container(
                            width: 100,
                            child: Text(S.of(context).node_location,
                                style: TextStyle(fontSize: 14, color: HexColor("#92979a")))),
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
            ),
            SizedBox(height: 8),
            getHoldInNum(
                context, contractNodeItem, _joinCoinFormKey, _joinCoinController, endProfit, spendManager, false,
                (textStr) {
              _filterSubject.sink.add(textStr);
            }, (textStr) {
              getCurrentSpend(textStr);
            }),
            SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(S.of(context).create_contract_only_one_hint, style: TextStyles.textC999S14medium),

                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                    child: Text(S.of(context).please_confirm_eth_gas_enough(walletName), style: TextStyles.textC999S12),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                    child: Text(S.of(context).create_no_enough_hyn_start_fail, style: TextStyles.textC999S12),
                  ),
                  Text(S.of(context).contract_create_cant_destroy, style: TextStyles.textC999S12),
//                  Padding(
//                    padding: const EdgeInsets.only(top: 10.0, bottom: 10),
//                    child: Text(S.of(context).freeze_balance_reward_direct_push, style: TextStyles.textC999S12),
//                  ),
                ],
              ),
            ),
          ])),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 4.0,
              ),
            ],
          ),
          constraints: BoxConstraints.expand(height: 50),
          child: RaisedButton(
              textColor: Colors.white,
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColor)),
              child: Text(S.of(context).confirm_bug, style: TextStyle(fontSize: 16, color: Colors.white70)),
              onPressed: () {
                setState(() {
                  if (!_joinCoinFormKey.currentState.validate()) {
                    return;
                  }
                  String provider = providerList[selectServerItemValue].id;
                  String region = providerList[selectServerItemValue].regions[selectNodeItemValue].id;
                  Application.router.navigateTo(
                      context,
                      Routes.map3node_send_confirm_page +
                          "?coinVo=${FluroConvertUtils.object2string(activatedWallet.coins[1].toJson())}" +
                          "&contractNodeItem=${FluroConvertUtils.object2string(contractNodeItem.toJson())}" +
                          "&transferAmount=${_joinCoinController.text ?? ""}&receiverAddress=${WalletConfig.map3ContractAddress}" +
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

/*Widget startAccount() {
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
  }*/
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
    {Function joinEnougnFunction,
    bool isMyself = false}) {

  List<int> suggestList =
      contractNodeItem.contract.suggestQuantity.split(",").map((suggest) => int.parse(suggest)).toList();

  double minTotal = 0;
  if (isJoin) {
    double tempMinTotal =
        double.parse(contractNodeItem.contract.minTotalDelegation) * contractNodeItem.contract.minDelegationRate;
    if (tempMinTotal >= double.parse(contractNodeItem.remainDelegation)) {
      minTotal = double.parse(contractNodeItem.remainDelegation);
    } else {
      minTotal = tempMinTotal;
    }
  } else {
    minTotal =
        double.parse(contractNodeItem.contract.minTotalDelegation) * contractNodeItem.contract.ownerMinDelegationRate;
  }

  var walletName = WalletInheritedModel.of(context).activatedWallet.wallet.keystore.name;
  walletName = UiUtil.shortString(walletName, limitLength:3);

  var balance = WalletInheritedModel.of(context).activatedWallet.coins[1].balance;
  return Container(
    color: Colors.white,
    padding: EdgeInsets.only(top: 16, bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 15.0, bottom: 15),
          child: Row(
            children: <Widget>[
              Text(S.of(context).mortgage_hyn_num, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              Text(S.of(context).mortgage_wallet_balance(walletName, FormatUtil.formatNumDecimal(balance.toInt().toDouble())),
                  style: TextStyle(color: Colors.grey[600])),
            ],
          ),
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
                            inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                            onChanged: (textStr) {
                              onChangeFuntion(textStr);
//                            _filterSubject.sink.add(textStr);
                            },
                            decoration: InputDecoration(
                              hintStyle: TextStyles.textC9b9b9bS14,
                              labelStyle: TextStyles.textC333S14,
                              hintText: S.of(context).mintotal_buy(FormatUtil.formatNumDecimal(minTotal)),
//                              border: InputBorder.none,
                            ),
                            validator: (textStr) {
                              if (textStr.length == 0) {
                                return S.of(context).please_input_hyn_count;
                              } else if (int.parse(textStr) < minTotal) {
                                return S.of(context).mintotal_hyn(FormatUtil.formatNumDecimal(minTotal));
                              } else if (int.parse(textStr) > balance) {
                                return S.of(context).hyn_balance_no_enough;
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
                if (!isJoin)
                  Padding(
                    padding: const EdgeInsets.only(left: 49.0),
                    child: Row(
                      children: <Widget>[
                        InkWell(
                          child: Container(
                            color: Color(0xFFFFF9E9),
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Text('200,000', style: TextStyle(fontSize: 12)),
                          ),
                          onTap: () {
                            textEditingController.text = '200000';
                          },
                        ),
                        SizedBox(width: 16),
                        InkWell(
                          child: Container(
                            color: Color(0xFFFFF9E9),
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Text('400,000', style: TextStyle(fontSize: 12)),
                          ),
                          onTap: () {
                            textEditingController.text = '400000';
                          },
                        ),
                        SizedBox(width: 16),
                        InkWell(
                          child: Container(
                            color: Color(0xFFFFF9E9),
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Text('600,000', style: TextStyle(fontSize: 12)),
                          ),
                          onTap: () {
                            textEditingController.text = '600000';
                          },
                        ),
                      ],
                    ),
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
                                      style: TextStyle(fontSize: 12, color: HexColor("#5C4304")),
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
                                    child: Text("${FormatUtil.formatNum(suggestList[1])}HYN",
                                        style: TextStyle(fontSize: 12, color: HexColor("#5C4304"))),
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
                                    child: Text("${FormatUtil.formatNum(suggestList[2])}HYN",
                                        style: TextStyle(fontSize: 12, color: HexColor("#5C4304"))),
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
                                      text: S.of(context).balance_portion_hyn,
                                      style: TextStyle(
                                          fontSize: 14, color: HexColor("#333333"), fontWeight: FontWeight.bold),
                                      children: [
                                        TextSpan(
                                          text: "${FormatUtil.stringFormatNum(contractNodeItem.remainDelegation)}",
                                          style: TextStyle(
                                              fontSize: 14, color: HexColor("#333333"), fontWeight: FontWeight.bold),
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
                                      child: Text(S.of(context).all_bug,
                                          style: TextStyle(fontSize: 12, color: HexColor("#5C4304"))),
                                    )),
                              ],
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                            child: RichText(
                              text: TextSpan(
                                  text: S.of(context).end_profit_hyn,
                                  style: TextStyles.textC9b9b9bS12,
                                  children: [
                                    TextSpan(
                                      text: "$endProfit",
                                      style: TextStyles.textC333S14,
                                    )
                                  ]),
                            ),
                          ),
                          if (!isMyself)
                            RichText(
                              text: TextSpan(
                                  text: isJoin ? S.of(context).spend_manager_hyn : S.of(context).get_manager_hyn,
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
    ),
  );
}

Widget getMap3NodeProductHeadItem(BuildContext context, ContractNodeItem contractNodeItem, {isJoin = false, isDetail = true, hasShare = false}) {
  var title = !isDetail
      ? S.of(context).node_contract_detail
      : isJoin ? S.of(context).join_map_node_mortgage : S.of(context).create_map_mortgage_contract;
  var nodeItem = contractNodeItem.contract;
  return Stack(
    children: <Widget>[
      Container(
          height: isDetail ? 250 : 250,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
//          borderRadius: BorderRadius.only(bottomLeft:Radius.circular(15),bottomRight:Radius.circular(15),), // 也可控件一边圆角大小
          )),
      Positioned(
        top: 60,
        left: -20,
        child: Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            gradient: new LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
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
            gradient: new LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
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
            gradient: new LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
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
      if(hasShare)
        Positioned(
          top:0,
          right: 0,
          child: InkWell(
            onTap: () async {
              final ByteData imageByte = await rootBundle.load("res/drawable/hyn.png");

              Wallet wallet = WalletInheritedModel.of(context).activatedWallet.wallet;
              bool isFromOwn = wallet.getEthAccount().address == contractNodeItem.owner;
              NodeShareEntity nodeShareEntity = NodeShareEntity(wallet.getEthAccount().address,"detail",isFromOwn);
              String encodeStr = FormatUtil.encodeBase64(json.encode(nodeShareEntity));
              Share.file(S.of(context).nav_share_app, 'app.png', imageByte.buffer.asUint8List(), 'image/jpeg',
                  text: "${contractNodeItem.shareUrl}?name=${contractNodeItem.ownerName}&key=$encodeStr");
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 44.0, right: 15),
              child: Icon(
                Icons.share,
                color: Colors.white,
              ),
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
                    text: "${FormatUtil.formatTenThousandNoUnit(nodeItem.minTotalDelegation)}",
                    style: TextStyles.textCfffS46,
                    children: <TextSpan>[
                  TextSpan(
                    text:
                        S.of(context).ten_thousand_annualizedyield(FormatUtil.formatPercent(nodeItem.annualizedYield)),
                    style: TextStyles.textCfffS24,
                  )
                ])),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 24),
              child: Text(S.of(context).all_join_end_reward, style: TextStyles.textCccfffS12),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                isJoin
                    ? Column(
                        children: <Widget>[
                          Text(S.of(context).min_invest, style: TextStyles.textCccfffS12),
                          SizedBox(height: 4),
                          Text("${FormatUtil.formatPercent(nodeItem.minDelegationRate)}", style: TextStyles.textCfffS14)
                        ],
                      )
                    : Column(
                        children: <Widget>[
                          Text(S.of(context).create_min_invest, style: TextStyles.textCccfffS12),
                          SizedBox(height: 4),
                          Text("${FormatUtil.formatPercent(nodeItem.ownerMinDelegationRate)}",
                              style: TextStyles.textCfffS14)
                        ],
                      ),
                Container(
                  margin: const EdgeInsets.only(left: 10.0, right: 20),
                  width: 1,
                  height: 32,
                  color: Colors.white70,
                ),
                Column(
                  children: <Widget>[
                    Text(S.of(context).contract_deadline, style: TextStyles.textCccfffS12),
                    SizedBox(height: 4),
                    Text(S.of(context).n_day(nodeItem.duration.toString()), style: TextStyles.textCfffS14)
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(left: 20.0, right: 10),
                  width: 1,
                  height: 32,
                  color: Colors.white70,
                ),
                Column(
                  children: <Widget>[
                    Text(S.of(context).manage_fee, style: TextStyles.textCccfffS12),
                    SizedBox(height: 4),
                    Text("${FormatUtil.formatPercent(nodeItem.commission)}", style: TextStyles.textCfffS14)
                  ],
                ),
              ],
            ),
//            if (isDetail) _getHeadItemCard(context,nodeItem),
          ],
        ),
      )
    ],
  );
}

Widget _getHeadItemCard(BuildContext context, NodeItem nodeItem) {
  var currentTime = new DateTime.now().millisecondsSinceEpoch;
  var durationTime = nodeItem.duration * 3600 * 24 * 1000;
  var tempHalfTime = durationTime / 2 + currentTime;
  int halfTime = int.parse(tempHalfTime.toStringAsFixed(0));
  var endTime = durationTime + currentTime;

  if (nodeItem.halfCollected) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
      color: Colors.white,
      margin: const EdgeInsets.only(left: 14.0, right: 14, bottom: 16, top: 16),
      child: Padding(
          padding: const EdgeInsets.only(left: 22.0, right: 22, top: 21, bottom: 21),
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
                                border: Border.all(color: HexColor("#322300"), width: 2)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 9.0, bottom: 9),
                            child: Text(
                              S.of(context).today_join,
                              style: TextStyle(fontSize: 12, color: HexColor("#4b4b4b")),
                            ),
                          ),
                          Text("${FormatUtil.formatDateCircle(currentTime, isSecond: false)}",
                              style: TextStyle(fontSize: 10, color: HexColor("#a7a7a7")))
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
                                border: Border.all(color: HexColor("#322300"), width: 2)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 9.0, bottom: 9),
                            child: Text(S.of(context).withdraw_reward,
                                style: TextStyle(fontSize: 12, color: HexColor("#4b4b4b"))),
                          ),
                          Text("${FormatUtil.formatDateCircle(halfTime, isSecond: false)}",
                              style: TextStyle(fontSize: 10, color: HexColor("#a7a7a7")))
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
                                border: Border.all(color: HexColor("#322300"), width: 2)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 9.0, bottom: 9),
                            child: Text(S.of(context).expire_end,
                                style: TextStyle(fontSize: 12, color: HexColor("#4b4b4b"))),
                          ),
                          Text("${FormatUtil.formatDateCircle(endTime, isSecond: false)}",
                              style: TextStyle(fontSize: 10, color: HexColor("#a7a7a7")))
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
                      child: Text(S.of(context).truely_date_accurate,
                          style: TextStyle(fontSize: 12, color: HexColor("#AAAAAA"))),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
      color: Colors.white,
      margin: const EdgeInsets.only(left: 14.0, right: 14, bottom: 16, top: 16),
      child: Padding(
          padding: const EdgeInsets.only(left: 22.0, right: 22, top: 21, bottom: 21),
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
                                border: Border.all(color: HexColor("#322300"), width: 2)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 9.0, bottom: 9),
                            child: Text(
                              S.of(context).today_join,
                              style: TextStyle(fontSize: 12, color: HexColor("#4b4b4b")),
                            ),
                          ),
                          Text("${FormatUtil.formatDateCircle(currentTime, isSecond: false)}",
                              style: TextStyle(fontSize: 10, color: HexColor("#a7a7a7")))
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
                                border: Border.all(color: HexColor("#322300"), width: 2)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 9.0, bottom: 9),
                            child: Text(S.of(context).expire_end,
                                style: TextStyle(fontSize: 12, color: HexColor("#4b4b4b"))),
                          ),
                          Text("${FormatUtil.formatDateCircle(endTime, isSecond: false)}",
                              style: TextStyle(fontSize: 10, color: HexColor("#a7a7a7")))
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
                        S.of(context).truely_date_accurate,
                        style: TextStyle(fontSize: 12, color: HexColor("#AAAAAA")),
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
