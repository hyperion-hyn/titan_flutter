import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/map3_node_util.dart';
import 'package:titan/src/pages/node/model/node_provider_entity.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'map3_node_public_widget.dart';

class Map3NodeDividePage extends StatefulWidget {
  Map3NodeDividePage();

  @override
  _Map3NodeDivideState createState() => new _Map3NodeDivideState();
}

class _Map3NodeDivideState extends State<Map3NodeDividePage> with WidgetsBindingObserver {
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
  int _managerSpendCount = 20;

  // 输入框的焦点实例
  FocusNode _focusNode;

  // 当前键盘是否是激活状态
  bool _isKeyboardActived = false;

  @override
  void initState() {
    _joinCoinController.addListener(textChangeListener);

    _joinCoinController.text = "$_managerSpendCount";
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
      appBar: BaseAppBar(
        baseTitle: 'Map3节点分裂',
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              AtlasApi.goToAtlasMap3HelpPage(context);
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
      var requestList = await Future.wait([_nodeApi.getContractInstanceItem("1"), _nodeApi.getNodeProviderList()]);
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

  var _localImagePath = "";
//  List<String> _detailList = ["", "派大星", "PB2020", "www.hyn.space", "12345678901", "HYN加油"];
  var _titleList = ["图标", "名称", "节点号", "最大抵押量", "网址", "安全联系", "描述"];
  List<String> _detailList = ["", "", "", "", "", "", ""];
  List<String> _hintList = ["请选择节点图标", "请输入节点名称", "请输入一个全网唯一的节点号", "节点允许的最大抵押量", "请输入节点网址", "请输入节点的联系方式", "请输入节点描述"];

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
          child: BaseGestureDetector(
            context: context,
            child: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Container(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _superNodeWidget(),
                      divider,
                      _divideSuperWidget(),
                      divider,
                      divideChildWidget(),
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
                      var detail = _detailList[index];
                      var hint = _hintList[index];
                      var keyboardType = TextInputType.text;

                      switch (index) {
                        case 4:
                          keyboardType = TextInputType.url;
                          break;

                        case 5:
                          keyboardType = TextInputType.phone;
                          break;
                      }

                      return editInfoItem(context, index, title, hint, detail, ({String value}) {
                        if (index == 0) {
                          setState(() {
                            _localImagePath = value;
                          });
                        } else {
                          setState(() {
                            _detailList[index] = value;
                          });
                        }
                      }, keyboardType: keyboardType, subtitle: subTitle);
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
            child: profitListWidget(
              [
                {"总抵押": "450,000"},
                {"我的抵押": "90,000"},
              ],
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
                      text: "母节点",
                      style: TextStyle(fontSize: 16, color: HexColor("#333333"), fontWeight: FontWeight.w500),
                      children: [
                        TextSpan(
                          text: "（分裂后预计总收益率提高2%）",
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
            padding: const EdgeInsets.only(left: 16.0, top: 16, bottom: 16),
            child: profitListWidget(
              [
                {"总抵押": "1,000,000"},
                {"我的抵押": "200,000"},
                {"管理费": "1%"}
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divideSuperWidget() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 20, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                      text: "分裂后母节点",
                      style: TextStyle(fontSize: 16, color: HexColor("#333333"), fontWeight: FontWeight.w500),
                      children: [
                        TextSpan(
                          text: "（保留55%总抵押）",
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
            padding: const EdgeInsets.only(left: 16.0, top: 16, bottom: 16),
            child: profitListWidget(
              [
                {"总抵押": "550,000"},
                {"我的抵押": "110,000"},
                {"管理费": "20%"}
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _managerSpendWidget() {
    return managerSpendWidget(context, _joinCoinController, reduceFunc: () {
      setState(() {
        _managerSpendCount--;
        if (_managerSpendCount < 1) {
          _managerSpendCount = 1;
        }

        _joinCoinController.text = "$_managerSpendCount";
      });
    }, addFunc: () {
      setState(() {
        _managerSpendCount++;
        if (_managerSpendCount > 20) {
          _managerSpendCount = 20;
        }
        _joinCoinController.text = "$_managerSpendCount";
      });
    });
  }

  Widget _confirmButtonWidget() {
    var activatedWallet = WalletInheritedModel.of(context).activatedWallet;

    return Visibility(
      visible: !_isKeyboardActived,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 37, vertical: 18),
        child: ClickOvalButton(
          "确定",
          () async {
            Application.router.navigateTo(context, Routes.map3node_divide_add_page);
          },
          height: 46,
          width: MediaQuery.of(context).size.width - 37 * 2,
          fontSize: 18,
        ),
      ),
    );
  }
}
