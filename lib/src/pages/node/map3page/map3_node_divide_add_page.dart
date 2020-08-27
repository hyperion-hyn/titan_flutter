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
import 'package:titan/src/pages/node/map3page/map3_node_normal_confirm_page.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
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

class Map3NodeDivideAddPage extends StatefulWidget {


  Map3NodeDivideAddPage();

  @override
  _Map3NodeDivideAddState createState() => new _Map3NodeDivideAddState();
}

class _Map3NodeDivideAddState extends State<Map3NodeDivideAddPage> with WidgetsBindingObserver {
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
          '增加抵押',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              String webUrl = FluroConvertUtils.fluroCnParamsEncode("http://baidu.com");
              String webTitle = FluroConvertUtils.fluroCnParamsEncode("关于节点分裂");
              Application.router
                  .navigateTo(context, Routes.toolspage_webview_page + '?initUrl=$webUrl&title=$webTitle');
            },
            child: Text(
              "关于节点分裂",
              style: TextStyle(color: HexColor("#1F81FF"), fontSize: 14),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: _pageView(context),
    );
  }

  void getNetworkData() async {
    try {
      var requestList =
          await Future.wait([_nodeApi.getContractItem("1"), _nodeApi.getNodeProviderList()]);
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
  var _titleList = ["图标", "名称", "节点号", "最大抵押量", "网址", "安全联系", "描述"];
  List<String> _detailList = ["", "", "", "", "", "", ""];
  List<String> _hintList = ["请选择节点图标", "请输入节点名称", "请输入一个全网唯一的节点号", "节点允许的最大抵押量", "请输入节点网址", "请输入节点的联系方式", "请输入节点描述"];

  TextEditingController _textEditingController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  double minTotal = 0;
  double remainTotal = 0;

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
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              // hide keyboard when touch other widgets
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Container(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _superNodeWidget(),
                      divider,
                      _inputWidget(),
                      divider,
                      _tipsWidget(),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
        _confirmButtonWidget(),
      ],
    );
  }

  Widget divideChildWidget() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 20, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                      text: "分裂后子节点",
                      style: TextStyle(fontSize: 16, color: HexColor("#333333"), fontWeight: FontWeight.w500),
                      children: [
                        TextSpan(
                          text: "（保留45%总抵押）",
                          style: TextStyle(fontSize: 12, color: HexColor("#999999"), fontWeight: FontWeight.normal),
                        )
                      ]),
                ),
                Spacer(),
                Container(
                  color: HexColor("#1FB9C7").withOpacity(0.08),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text("第一期", style: TextStyle(fontSize: 12, color: HexColor("#5C4304"))),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [1, 0.5, 2].map((value) {
                String title = "";
                String detail = "0";

                switch (value) {
                  case 1:
                    title = "总抵押";
                    detail = "900,000";
                    break;

                  case 2:
                    title = "我的抵押";
                    detail = "300,000";
                    break;

                  default:
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Container(
                        height: 15,
                        width: 0.5,
                        color: HexColor("#000000").withOpacity(0.2),
                      ),
                    );
                    break;
                }

                return Column(
                  children: <Widget>[
                    Text(detail,
                        style: TextStyle(fontSize: 16, color: HexColor("#333333"), fontWeight: FontWeight.normal)),
                    Container(
                      height: 4,
                    ),
                    Text(title,
                        style: TextStyle(fontSize: 12, color: HexColor("#999999"), fontWeight: FontWeight.normal)),
                  ],
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 18, right: 16),
            child: Container(
              color: HexColor("#F2F2F2"),
              height: 0.5,
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

  Widget _superNodeWidget() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 10, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                      text: "分裂后子节点",
                      style: TextStyle(fontSize: 16, color: HexColor("#333333"), fontWeight: FontWeight.w500),
                      children: [
                        TextSpan(
                          text: "",
                          style: TextStyle(fontSize: 12, color: HexColor("#999999"), fontWeight: FontWeight.normal),
                        )
                      ]),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16, right: 16),
            child: Row(
              children: <Widget>[
                Image.asset(
                  "res/drawable/map3_node_default_avatar.png",
                  width: 42,
                  height: 42,
                  fit: BoxFit.cover,
                ),
                SizedBox(
                  width: 8,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text.rich(TextSpan(children: [
                      TextSpan(
                          text: "派大星",
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: HexColor("#333333"))),
                      TextSpan(
                          text: "  币龄: 12天",
                          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: HexColor("#333333"))),
                    ])),
                    Container(
                      height: 4,
                    ),
                    Text("${UiUtil.shortEthAddress("钱包地址 oxfdaf89fda47sn43sff", limitLength: 9)}",
                        style: TextStyles.textC9b9b9bS12),
                  ],
                ),
                Spacer(),
                Container(
                  color: HexColor("#1FB9C7").withOpacity(0.08),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text("第一期", style: TextStyle(fontSize: 12, color: HexColor("#5C4304"))),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
            child: Container(
              color: HexColor("#F2F2F2"),
              height: 0.5,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30, top: 16, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [1, 0.5, 2, 0.5, 3].map((value) {
                String title = "";
                String detail = "0";

                switch (value) {
                  case 1:
                    title = "总抵押";
                    detail = "450,000";
                    break;

                  case 2:
                    title = "我的抵押";
                    detail = "90,000";
                    break;

                  case 3:
                    title = "管理费";
                    detail = "20%";
                    break;

                  default:
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Container(
                        height: 15,
                        width: 0.5,
                        color: HexColor("#000000").withOpacity(0.2),
                      ),
                    );
                    break;
                }

                return Column(
                  children: <Widget>[
                    Text(detail,
                        style: TextStyle(fontSize: 16, color: HexColor("#333333"), fontWeight: FontWeight.normal)),
                    Container(
                      height: 4,
                    ),
                    Text(title,
                        style: TextStyle(fontSize: 12, color: HexColor("#999999"), fontWeight: FontWeight.normal)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipsWidget() {
    var _nodeWidget = Padding(
      padding: const EdgeInsets.only(right: 10, top: 10),
      child: Container(
        width: 3,
        height: 3,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: DefaultColors.color999,
            border: Border.all(color: DefaultColors.color999, width: 1.0)),
      ),
    );

    Widget _rowWidget(String title, {double top = 8, String subTitle = ""}) {
      return Padding(
        padding: EdgeInsets.only(top: top),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _nodeWidget,
            Expanded(
                child: InkWell(
              onTap: () {
                if (subTitle.isEmpty) {
                  return;
                }
                // todo: test_jison_0604
                String webUrl = FluroConvertUtils.fluroCnParamsEncode("http://baidu.com");
                String webTitle = FluroConvertUtils.fluroCnParamsEncode(subTitle);
                Application.router
                    .navigateTo(context, Routes.toolspage_webview_page + '?initUrl=$webUrl&title=$webTitle');
              },
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: subTitle,
                      style: TextStyle(color: HexColor("#1F81FF"), fontSize: 12),
                    )
                  ],
                  text: title,
                  style: TextStyle(height: 1.8, color: DefaultColors.color999, fontSize: 12),
                ),
              ),
            )),
          ],
        ),
      );
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8),
            child: Text("注意事项", style: TextStyle(color: HexColor("#333333"), fontSize: 16)),
          ),
          _rowWidget("节点总抵押需满55万才能享受Map3工作服务奖励"),
          _rowWidget("分裂后子节点马上进入运行状态，共享母节点节龄和运行时长", subTitle: ""),
          _rowWidget("如果母节点已经抵押Atlas节点，则分裂后子节点也会自动抵押到相同的Atlas节点上", subTitle: ""),
        ],
      ),
    );
  }

  Widget _inputWidget() {
    var coinVo = WalletInheritedModel.of(context).getCoinVoOfHyn();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 4, right: 8),
                  child: Image.asset(
                    "res/drawable/map3_add_input_star_tag.png",
                    width: 12,
                    height: 12,
                  ),
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                        text: "做为节点主，分裂后子节点您至少拥有20%的抵押量，如果不足20%，需要增加抵押来完成节点分裂",
                        style: TextStyle(
                            fontSize: 14, color: HexColor("#333333"), fontWeight: FontWeight.w500, height: 1.5),
                        children: [
                          TextSpan(
                            text: "",
                            style: TextStyle(fontSize: 12, color: HexColor("#999999"), fontWeight: FontWeight.normal),
                          )
                        ]),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Row(
              children: <Widget>[
                RichText(
                  text: TextSpan(
                      text: "增加抵押",
                      style: TextStyle(fontSize: 16, color: HexColor("#333333"), fontWeight: FontWeight.normal),
                      children: [
                        TextSpan(
                          text: "（节点创建至少抵押110,000）",
                          style: TextStyle(fontSize: 12, color: HexColor("#999999"), fontWeight: FontWeight.normal),
                        )
                      ]),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
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
                    key: _formKey,
                    child: RoundBorderTextField(
                      controller: _textEditingController,
                      keyboardType: TextInputType.number,
                      suffixText: "最佳",
                      suffixStyle: TextStyle(color: HexColor("#1F81FF"), fontSize: 14),
                      hint: "最低买入200,000",
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
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 48,
                ),
                Expanded(
                  child: Text(
                    "最佳裂变增投20,000HYN，子母节点皆可获得最高回报",
                    //"撤销抵押将会影响节点进度，剩余抵押不足20%节点将会被取消",
                    style: TextStyle(fontSize: 12, color: HexColor("#999999"), height: 1.5),
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
          "马上分裂",
          () async {
            Application.router.navigateTo(
                context, Routes.map3node_normal_confirm_page + "?actionEvent=${Map3NodeActionEvent.ADD.index}");
          },
          height: 46,
          width: MediaQuery.of(context).size.width - 37 * 2,
          fontSize: 18,
        ),
      ),
    );
  }
}
