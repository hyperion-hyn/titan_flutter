import 'dart:io';

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
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/map3_node_util.dart';
import 'package:titan/src/pages/node/model/node_provider_entity.dart';
import 'package:titan/src/pages/wallet/wallet_setting.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/round_border_textfield.dart';

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

class _Map3NodeCreateContractState extends State<Map3NodeCreateContractPage> with WidgetsBindingObserver {
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

  // 输入框的焦点实例
  FocusNode _focusNode;

  // 当前键盘是否是激活状态
  bool _isKeyboardActived = false;

  @override
  void initState() {
    _joinCoinController.addListener(textChangeListener);

    _filterSubject.debounceTime(Duration(milliseconds: 500)).listen((text) {
      getCurrentSpend(text);
    });

    getNetworkData();

    _setupNode();

    super.initState();
  }

  void _setupNode() {
    _focusNode = FocusNode();

    // 监听输入框焦点变化
    _focusNode.addListener(_onFocus);

    // 创建一个界面变化的观察者
    WidgetsBinding.instance.addObserver(this);
  }

  // 焦点变化时触发的函数
  _onFocus() {
    if (_focusNode.hasFocus) {
      // 聚焦时候的操作
      return;
    }

    // 失去焦点时候的操作
    setState(() {
      _isKeyboardActived = false;
    });

    print("[Keyboard] 1, isKeyboardActived:$_isKeyboardActived");
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("[Keyboard] 2, isKeyboardActived:$_isKeyboardActived");

      // 当前是安卓系统并且在焦点聚焦的情况下
      if (Platform.isAndroid && _focusNode.hasFocus) {
        if (_isKeyboardActived) {
          setState(() {
            _isKeyboardActived = false;
          });
          // 使输入框失去焦点
          _focusNode.unfocus();
          return;
        }
        setState(() {
          _isKeyboardActived = true;
        });
      }
    });
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

    _focusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  var _editText = "";
  var _localImagePath = "";
//  List<String> _detailList = ["", "派大星", "PB2020", "www.hyn.space", "12345678901", "HYN加油"];
  var _titleList = ["图标", "名称", "节点号", "网址", "安全联系", "描述"];
  List<String> _detailList = ["", "", "", "", "", ""];
  List<String> _hintList = ["请选择节点图标", "请输入节点名称", "请输入节点号", "请输入节点网址", "请输入节点的联系方式", "请输入节点描述"];

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

    var divider = Container(
      color: HexColor("#F4F4F4"),
      height: 8,
    );
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
                        context, contractItem, _joinCoinFormKey, _joinCoinController, endProfit, spendManager, false,
                        focusNode: _focusNode),
                    divider,
                    _managerSpendWidget(),
                    divider,
                  ]),
                ),
              ),
              SliverToBoxAdapter(
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    var subTitle = index < 3 ? "" : "（选填）";
                    var title = _titleList[index];
                    var detail = _detailList[index].isEmpty ? _hintList[index] : _detailList[index];
                    var keyboardType = TextInputType.text;

                    switch (index) {
                      case 3:
                        keyboardType = TextInputType.url;
                        break;

                      case 4:
                        keyboardType = TextInputType.phone;
                        break;

                      case 5:
                        break;
                    }

                    return Material(
                      child: Ink(
                        child: InkWell(
                          splashColor: Colors.blue,
                          onTap: () async {
                            if (index == 0) {
                              EditIconSheet(context, (path) {
                                setState(() {
                                  _localImagePath = path;
                                });
                              });
                              return;
                            }

                            String text = await Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) => Map3NodePronouncePage(
                                      title: title,
                                      hint: detail,
                                      keyboardType: keyboardType,
                                    )));
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
                              padding: EdgeInsets.symmetric(vertical: detail.isNotEmpty ? 18 : 14, horizontal: 14),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    title,
                                    style: TextStyle(color: HexColor("#333333"), fontSize: 16),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: subTitle.isEmpty
                                        ? Text(
                                            ' * ',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: HexColor("#FFFF4C3B"),
                                              fontSize: 16,
                                            ),
                                          )
                                        : Text(
                                            subTitle,
                                            style: TextStyle(color: HexColor("#999999"), fontSize: 12),
                                          ),
                                  ),
                                  Spacer(),
                                  _localImagePath.isEmpty
                                      ? Text(
                                          detail,
                                          style: TextStyle(color: HexColor("#999999"), fontSize: 14),
                                        )
                                      : Image.asset(
                                          _localImagePath ?? "res/drawable/ic_map3_node_item_2.png",
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

  Widget _confirmButtonWidget() {
    var activatedWallet = WalletInheritedModel.of(context).activatedWallet;

    return Visibility(
      visible: !_isKeyboardActived,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 37, vertical: 18),
        child: ClickOvalButton(
          "创建提交",
          () async {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (BuildContext context) => Map3NodeCreateConfirmPage(widget.contractId)));
            /*
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
            });*/
          },
          height: 46,
          width: MediaQuery.of(context).size.width - 37 * 2,
          fontSize: 18,
        ),
      ),
    );
  }
}

Widget getHoldInNum(BuildContext context, ContractNodeItem contractNodeItem, GlobalKey<FormState> formKey,
    TextEditingController textEditingController, String endProfit, String spendManager, bool isJoin,
    {bool isMyself = false, FocusNode focusNode}) {
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
                SizedBox(
                  height: 12,
                ),
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
                      child: RoundBorderTextField(
                        focusNode: focusNode,
                        controller: textEditingController,
                        keyboardType: TextInputType.number,
                        hint: S.of(context).mintotal_buy(FormatUtil.formatNumDecimal(minTotal)),
                        validator: (textStr) {
                          if (textStr.length == 0) {
                            return S.of(context).please_input_hyn_count;
                          } else if (minTotal == 0) {
                            return "抵押已满";
                          } else if (int.parse(textStr) < minTotal) {
                            return S.of(context).mintotal_hyn(FormatUtil.formatNumDecimal(minTotal));
                          } else if (int.parse(textStr) > remainTotal) {
                            return "不能超过剩余份额";
                          } else if (Decimal.parse(textStr) > Decimal.parse(FormatUtil.coinBalanceHumanRead(coinVo))) {
                            return S.of(context).hyn_balance_no_enough;
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                    /*
                    Flexible(
                      flex: 1,
                      child: Form(
                        key: formKey,
                        child: TextFormField(
                          controller: textEditingController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(

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
                    */
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
