import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/map3page/map3_node_create_confirm_page.dart';
import 'package:titan/src/pages/node/map3page/map3_node_precreate_contract_page.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/pages/node/model/map3_node_util.dart';
import 'package:titan/src/pages/node/model/node_item.dart';
import 'package:titan/src/pages/node/model/node_provider_entity.dart';
import 'package:titan/src/pages/wallet/wallet_setting.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/widget/click_oval_button.dart';
import 'package:titan/src/widget/click_rectangle_button.dart';

import 'map3_node_pronounce_page.dart';

class Map3NodeCreateContractPage extends StatefulWidget {
  static const String CONTRACT_PAGE_TYPE_CREATE = "contract_page_type_create";
  static const String CONTRACT_PAGE_TYPE_JOIN = "contract_page_type_join";
  static const String CONTRACT_PAGE_TYPE_COLLECT = "contract_page_type_collect";

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
  ContractNodeItem contractItem;
  PublishSubject<String> _filterSubject = PublishSubject<String>();
  String endProfit = "";
  String spendManager = "";
  var selectServerItemValue = 0;
  var selectNodeItemValue = 0;
  List<DropdownMenuItem> serverList;
  List<DropdownMenuItem> nodeList;
  List<NodeProviderEntity> providerList = [];
  String originInputStr = "";

  @override
  void initState() {
    _joinCoinController.addListener(textChangeListener);

    _filterSubject.debounceTime(Duration(milliseconds: 500)).listen((text) {
      getCurrentSpend(text);
    });

    getNetworkData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        centerTitle: true,
        title: Text(
          '创建Map3节点',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: _pageView(context),
    );
  }

  void getNetworkData() async {
    try {
      var requestList =
          await Future.wait([_nodeApi.getContractItem(widget.contractId), _nodeApi.getNodeProviderList()]);
      contractItem = requestList[0];
      providerList = requestList[1];

      selectNodeProvider(0, 0);

      setState(() {
        currentState = null;
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
    if (contractItem == null || !mounted || originInputStr == inputText) {
      return;
    }

    originInputStr = inputText;
    _joinCoinFormKey.currentState?.validate();

    if (inputText == null || inputText == "") {
      setState(() {
        endProfit = "";
        spendManager = "";
      });
      return;
    }
    double inputValue = double.parse(inputText);
    endProfit = Map3NodeUtil.getEndProfit(contractItem.contract, inputValue);
    spendManager = Map3NodeUtil.getManagerTip(contractItem.contract, inputValue);

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

  int _currentIndex;
  var _editText = "";
  var _localImagePath = "";
  List<String> _detailList =["","派大星","PB2020","www.hyn.space","12345678901","HYN加油"];
  Widget _pageView(BuildContext context) {
    if (currentState != null || contractItem.contract == null) {
      return AllPageStateContainer(currentState, () {
        setState(() {
          currentState = LoadingState();
        });
        getNetworkData();
      });
    }

    var activatedWallet = WalletInheritedModel.of(context).activatedWallet;
    var walletName = activatedWallet.wallet.keystore.name;

    var divider = Container(color: HexColor("#F4F4F4"),height: 8,);
    return Column(
      children: <Widget>[
        Expanded(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Container(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _headerWidget(),
                    divider,
                    getHoldInNum(
                        context, contractItem, _joinCoinFormKey, _joinCoinController, endProfit, spendManager, false),
                    divider,
                    _managerSpendWidget(),
                    divider,
                  ]),
                ),
              ),
              SliverToBoxAdapter(
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    var title = "图标";
                    var subTitle = "（选填）";
                    var detail = "";

                    switch (index) {
                      case 0:
                        title = "图标";
                        subTitle = "";
                        detail = _localImagePath.isEmpty?"请编辑节点Icon":"";


                        break;

                      case 1:
                        title = "名称";
                        subTitle = "";
                        detail = "派大星";
                        break;

                      case 2:
                        title = "节点号";
                        subTitle = "";
                        detail = "PB2020";
                        break;

                      case 3:
                        title = "网址";
                        subTitle = "（选填）";
                        detail = "www.hyn.space";
                        break;

                      case 4:
                        title = "安全联系";
                        subTitle = "（选填）";
                        detail = "17876894078";
                        break;

                      case 5:
                        title = "描述";
                        subTitle = "";
                        detail = "大家快来参与我的节点吧";
                        break;
                    }

                   detail = _detailList[index];


                    return Material(
                      child: Ink(
                        child: InkWell(
                          splashColor: Colors.blue,
                          onTap: () async{

                            if (index == 0) {
                              EditIconSheet(context, (path) {
                                setState(() {
                                  _localImagePath = path;
                                });
                              });
                              return;
                            }

                            _currentIndex = index;
                            String text = await Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    Map3NodePronouncePage(title: title,)));
                            if (text.isNotEmpty) {
                              setState(() {
                                _detailList[index] = text;
                              });
                              print("[Pronounce] _editText:${_editText}");
                            }
                          },
                          child: Container(
                              color: Colors.white,

                              child: Padding(
                              padding:  EdgeInsets.symmetric(vertical: detail.isNotEmpty?18:14, horizontal: 14),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    title,
                                    style: TextStyle(color: HexColor("#333333"), fontSize: 16),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Text(
                                      subTitle,
                                      style: TextStyle(color: HexColor("#999999"), fontSize: 12),
                                    ),
                                  ),
                                  Spacer(),
                                  detail.isNotEmpty
                                      ? Text(
                                          detail,
                                          style: TextStyle(color: HexColor("#999999"), fontSize: 14),
                                        )
                                      : Image.asset(
                                    _localImagePath??"res/drawable/ic_map3_node_item_2.png",
                                          width: 36,
                                          height: 36,
                                          fit: BoxFit.cover,
                                        ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: Icon(
                                      Icons.chevron_right,
                                      color: DefaultColors.color999,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider(
                      height: 0.5,
                      color: HexColor("#F2F2F2"),
                    );
                  },
                  itemCount: _detailList.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                ),
              ),
//            SliverToBoxAdapter(
//              child: Container(
//                height: 82,
//              ),
//            )
            ],
          ),
        ),
        _confirmButtonWidget(),
      ],
    );
  }

  Widget _headerWidget() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              //mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Image.asset(
                  "res/drawable/ic_map3_node_item_2.png",
                  width: 62,
                  height: 62,
                  fit: BoxFit.cover,
                ),
                SizedBox(
                  width: 12,
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Expanded(child: Text("Map3云节点（V1.0）", style: TextStyle(fontWeight: FontWeight.bold))),
                          InkWell(
                            child: Text("详细介绍", style: TextStyle(fontSize: 14, color: HexColor("#1F81FF"))),
                            onTap: () {
                              String webUrl = FluroConvertUtils.fluroCnParamsEncode("http://baidu.com");
                              String webTitle = FluroConvertUtils.fluroCnParamsEncode("详细介绍");
                              Application.router.navigateTo(
                                  context, Routes.toolspage_webview_page + '?initUrl=$webUrl&title=$webTitle');
                            },
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("启动所需" + "启动所需100万  ",
                                style: TextStyles.textC99000000S13, maxLines: 1, softWrap: true),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(" (HYN) ",
                                  style: TextStyle(fontSize: 10, color: HexColor("#999999").withOpacity(0.2))),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text("  |  ",
                                  style: TextStyle(fontSize: 12, color: HexColor("000000").withOpacity(0.2))),
                            ),
                            Text(S.of(context).n_day("180"), style: TextStyles.textC99000000S13)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 15),
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
            padding: EdgeInsets.only(top: 8.0, left: 15, bottom: 16),
            child: Row(
              children: <Widget>[
                Container(
                    width: 100,
                    child:
                        Text(S.of(context).node_location, style: TextStyle(fontSize: 14, color: HexColor("#92979a")))),
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
    );
  }

  bool _renew = true;

  int _managerSpendCount = 20;

  Widget _managerSpendWidget() {
    return Container(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: RichText(
              text: TextSpan(
                  text: "管理费设置",
                  style: TextStyle(fontSize: 16, color: HexColor("#333333"), fontWeight: FontWeight.normal),
                  children: [
                    TextSpan(
                      text: "（1%-20%）",
                      style: TextStyle(fontSize: 12, color: HexColor("#999999"), fontWeight: FontWeight.normal),
                    )
                  ]),
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    setState(() {
                      _managerSpendCount--;
                      if (_managerSpendCount < 1) {
                        _managerSpendCount = 1;
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        child: Text(
                          "-",
                          style: TextStyle(fontSize: 16, color: HexColor("#333333")),
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: HexColor("#F2F2F2"),
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                      child: Text(
                        "$_managerSpendCount",
                        style: TextStyle(fontSize: 16, color: HexColor("#333333")),
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: HexColor("#FFFFFF"),
                      border: Border.all(color: HexColor("#DEDEDE"), width: 0.5),
                      borderRadius: BorderRadius.circular(13.0),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Container(
                    child: Text(
                      "%",
                      style: TextStyle(fontSize: 16, color: HexColor("#333333")),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _managerSpendCount++;
                      if (_managerSpendCount > 20) {
                        _managerSpendCount = 20;
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        child: Text(
                          "+",
                          style: TextStyle(fontSize: 16, color: HexColor("#333333")),
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: HexColor("#F2F2F2"),
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  TextEditingController _pronounceTextController = TextEditingController();

  Widget _nodePronounceWidget() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  "节点公告",
                  style: TextStyle(fontSize: 16, color: HexColor("#333333")),
                ),
              ),
            ],
          ),
          TextFormField(
            controller: _pronounceTextController,
            keyboardType: TextInputType.text,
            maxLength: 200,
            maxLines: 6,
            style: TextStyle(color: HexColor("#333333"), fontSize: 14),
            decoration: InputDecoration(
              hintStyle: TextStyle(color: HexColor("#B8B8B8"), fontSize: 14),
              //labelStyle: TextStyle(color: HexColor("#333333"), fontSize: 12),
              hintText: "大家快来参与我的节点吧，收益高高！",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            validator: (textStr) {
              if (textStr.length == 0) {
                return "大家快来参与我的节点吧，收益高高！";
              }
              {
                return null;
              }
            },
            onChanged: (value) {
              print("[NodePronounce] value:$value");
            },
          ),
        ],
      ),
    );
  }

  Widget _confirmButtonWidget() {
    var activatedWallet = WalletInheritedModel.of(context).activatedWallet;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 37, vertical: 18),
      child: ClickOvalButton(
        "创建提交",
        () async {

          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) =>
                  Map3NodeCreateConfirmPage(widget.contractId)));
          return;

          setState(() {
            if (!_joinCoinFormKey.currentState.validate()) {
              return;
            }

            var providerModel = providerList[selectServerItemValue];
            var regionsModel = providerModel.regions[selectNodeItemValue];
            contractItem.nodeRegion = regionsModel.id;
            contractItem.nodeProvider = providerModel.id;
            contractItem.nodeRegionName = regionsModel.name;
            contractItem.nodeProviderName = providerModel.name;
            var transferAmount = _joinCoinController.text?.isNotEmpty == true ? _joinCoinController.text : "0";
            contractItem.announcement =
                _pronounceTextController.text.isNotEmpty ? _pronounceTextController.text : "欢迎来到Titan";
            contractItem.renew = _renew;
            contractItem.commission = _managerSpendCount * 0.01;
            Application.router.navigateTo(
                context,
                Routes.map3node_send_confirm_page +
                    "?coinVo=${FluroConvertUtils.object2string(activatedWallet.coins[1].toJson())}" +
                    "&contractNodeItem=${FluroConvertUtils.object2string(contractItem.toJson())}" +
                    "&transferAmount=${transferAmount.trim()}&receiverAddress=${WalletConfig.map3ContractAddress}" +
                    "&actionEvent=${Map3NodeActionEvent.CREATE}" +
                    "&contractId=${widget.contractId}");
          });
        },
        height: 46,
        width: MediaQuery.of(context).size.width - 37 * 2,
        fontSize: 18,
      ),
    );
  }
}

Widget getHoldInNum(BuildContext context, ContractNodeItem contractNodeItem, GlobalKey<FormState> formKey,
    TextEditingController textEditingController, String endProfit, String spendManager, bool isJoin,
    {bool isMyself = false}) {
  List<int> suggestList =
      contractNodeItem.contract.suggestQuantity.split(",").map((suggest) => int.parse(suggest)).toList();

  double minTotal = 0;
  double remainTotal = 0;
  if (isJoin) {
    //calculation
    remainTotal = double.parse(contractNodeItem.remainDelegation);
    double tempMinTotal =
        double.parse(contractNodeItem.contract.minTotalDelegation) * contractNodeItem.contract.minDelegationRate;
    if (remainTotal <= 0) {
      minTotal = 0;
      remainTotal = 0;
      contractNodeItem.remainDelegation = "0";
    } else if (tempMinTotal >= remainTotal) {
      minTotal = remainTotal;
    } else {
      minTotal = tempMinTotal;
    }
  } else {
    remainTotal = double.parse(contractNodeItem.contract.minTotalDelegation);
    minTotal =
        double.parse(contractNodeItem.contract.minTotalDelegation) * contractNodeItem.contract.ownerMinDelegationRate;
  }

  var walletName = WalletInheritedModel.of(context).activatedWallet.wallet.keystore.name;
  walletName = UiUtil.shortString(walletName, limitLength: 6);

  var coinVo = WalletInheritedModel.of(context).getCoinVoOfHyn();
  return Container(
    color: Colors.white,
    padding: EdgeInsets.only(top: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8, right: 8),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child:
                    Text(S.of(context).mortgage_hyn_num, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              ),
              Expanded(
                child: Text(S.of(context).mortgage_wallet_balance(FormatUtil.coinBalanceHumanReadFormat(coinVo)),
                    style: TextStyle(color: Colors.grey[600])),
              ),
            ],
          ),
        ),
        Container(
            padding: const EdgeInsets.only(left: 16.0, right: 36, bottom: 8),
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
                      width: 12,
                    ),
                    Flexible(
                      flex: 1,
                      child: Form(
                        key: formKey,
                        child: TextFormField(
                          controller: textEditingController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(
                            /*filled: true,
                              fillColor: HexColor("#F2F2F2"),
                              contentPadding: const EdgeInsets.only(left: 24.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: HexColor("#F2F2F2")),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: HexColor("#F2F2F2")),
                                borderRadius: BorderRadius.circular(30),
                              ),*/
                            hintStyle: TextStyle(color: HexColor("#B8B8B8"), fontSize: 12),
                            labelStyle: TextStyles.textC333S14,
                            hintText: S.of(context).mintotal_buy(FormatUtil.formatNumDecimal(minTotal)),
                            //border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          validator: (textStr) {
                            if (textStr.length == 0) {
                              return S.of(context).please_input_hyn_count;
                            } else if (minTotal == 0) {
                              return "抵押已满";
                            } else if (int.parse(textStr) < minTotal) {
                              return S.of(context).mintotal_hyn(FormatUtil.formatNumDecimal(minTotal));
                            } else if (int.parse(textStr) > remainTotal) {
                              return "不能超过剩余份额";
                            } else if (Decimal.parse(textStr) >
                                Decimal.parse(FormatUtil.coinBalanceHumanRead(coinVo))) {
                              return S.of(context).hyn_balance_no_enough;
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                if (!isJoin && suggestList.length == 3)
                  Padding(
                    padding: const EdgeInsets.only(left: 49.0, bottom: 18),
                    child: Row(
                      children: [0, 0.5, 1, 0.5, 2].map((value) {
                        if (value == 0.5) {
                          return SizedBox(width: 16);
                        }

                        return InkWell(
                          child: Container(
                            color: HexColor("#1FB9C7").withOpacity(0.08),
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Text(suggestList[value].toString(),
                                style: TextStyle(fontSize: 12, color: HexColor("#5C4304"))),
                          ),
                          onTap: () {
                            textEditingController.text = suggestList[value].toString();
                          },
                        );
                      }).toList(),
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
                                        textEditingController.text = contractNodeItem.remainDelegation;
//                                        joinEnougnFunction();
                                      },
                                      child: Text(S.of(context).all_bug,
                                          style: TextStyle(fontSize: 12, color: HexColor("#5C4304"))),
                                    )),
                              ],
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

Widget getMap3NodeProductHeadItemSmall(BuildContext context, ContractNodeItem contractNodeItem,
    {isJoin = false, isDetail = true, hasShare = false}) {
  var title = !isDetail
      ? S.of(context).node_contract_detail
      : isJoin ? S.of(context).join_map_node_mortgage : S.of(context).create_map_mortgage_contract;
  var nodeItem = contractNodeItem.contract;
  return Material(
    child: Container(
      color: Theme.of(context).primaryColor,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: 56,
//            color: Colors.red,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Positioned(
                    left: 0,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )),
                Text(
                  title,
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(24.5),
                  child: Image.asset(
                    "res/drawable/ic_map3_node_item_contract_fit_bg.png",
                    width: 62,
                    height: 62,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(nodeItem.name, style: TextStyle(fontSize: 16, color: Colors.white)),
                      SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                              "启动所需" +
                                  '${FormatUtil.formatTenThousandNoUnit(nodeItem.minTotalDelegation)}${S.of(context).ten_thousand}',
                              style: TextStyle(fontSize: 13, color: Colors.white)),
                          SizedBox(width: 4),
                          Container(width: 1, height: 10, color: Colors.white24),
                          SizedBox(width: 4),
                          Text(S.of(context).n_day(nodeItem.duration.toString()),
                              style: TextStyle(fontSize: 13, color: Colors.white)),
                        ],
                      )
                    ],
                  ),
                ),
                Column(
                  children: <Widget>[
                    Text(FormatUtil.formatPercent(nodeItem.annualizedYield),
                        style: TextStyle(fontSize: 20, color: Colors.white)),
                    Text(S.of(context).annualized_rewards, style: TextStyle(fontSize: 13, color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget getMap3NodeProductHeadItem(BuildContext context, ContractNodeItem contractNodeItem,
    {isJoin = false, isDetail = true, hasShare = false}) {
  double padding = UiUtil.isIPhoneX(context) ? 20 : 0;
  var title = !isDetail
      ? S.of(context).node_contract_detail
      : isJoin ? S.of(context).join_map_node_mortgage : S.of(context).create_map_mortgage_contract;
  var nodeItem = contractNodeItem.contract;
  return Stack(
    children: <Widget>[
      Container(
          height: isDetail ? (UiUtil.isIPhoneX(context) ? 280 : 250) : 250,
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
          padding: EdgeInsets.only(top: 44.0 + padding, left: 15),
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      if (hasShare)
        Positioned(
          top: 0,
          right: 0,
          child: InkWell(
            onTap: () async {
              Application.router.navigateTo(
                  context,
                  Routes.map3node_share_page +
                      "?contractNodeItem=${FluroConvertUtils.object2string(contractNodeItem.toJson())}");
            },
            child: Padding(
              padding: EdgeInsets.only(top: 44.0 + padding, right: 15),
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
          padding: EdgeInsets.only(top: 44.0 + padding),
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
