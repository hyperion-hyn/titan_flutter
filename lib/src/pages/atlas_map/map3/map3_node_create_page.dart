import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/create_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/map3_node_util.dart';
import 'package:titan/src/pages/node/model/node_provider_entity.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'map3_node_public_widget.dart';

class Map3NodeCreatePage extends StatefulWidget {
  final String contractId;

  Map3NodeCreatePage(this.contractId);

  @override
  _Map3NodeCreateState createState() => new _Map3NodeCreateState();
}

class _Map3NodeCreateState extends State<Map3NodeCreatePage> with WidgetsBindingObserver {
  TextEditingController _joinCoinController = new TextEditingController();
  TextEditingController _rateCoinController = new TextEditingController();

  final _joinCoinFormKey = GlobalKey<FormState>();
  AllPageState currentState = LoadingState();
  NodeApi _nodeApi = NodeApi();
  ContractNodeItem contractItem;
  PublishSubject<String> _filterSubject = PublishSubject<String>();
  String endProfit = "";
  String spendManager = "";
  var selectServerItemValue = 0;
  var selectNodeItemValue = 0;
  NodeProviderEntity _selectProviderEntity;
  List<DropdownMenuItem> serverList;
  List<DropdownMenuItem> nodeList;
  List<NodeProviderEntity> providerList = [];
  String originInputStr = "";
  int _managerSpendCount = 20;
  CreateMap3Payload _payload = CreateMap3Payload.onlyNodeId("ABC");

  // 输入框的焦点实例
  FocusNode _focusNode;

  // 当前键盘是否是激活状态
  bool _isKeyboardActive = false;

  var _localImagePath = "";
  var _titleList = ["图标", "名称", "节点号", "网址", "安全联系", "描述"];
  List<String> _detailList = ["", "", "", "", "", ""];
  List<String> _hintList = ["请选择节点图标", "请输入节点名称", "请输入节点号", "请输入节点网址", "请输入节点的联系方式", "请输入节点描述"];

  @override
  void initState() {
    _joinCoinController.addListener(_joinTextFieldChangeListener);
    _rateCoinController.addListener(_rateTextFieldChangeListener);

    _rateCoinController.text = "$_managerSpendCount";

    _filterSubject.debounceTime(Duration(milliseconds: 500)).listen((text) {
      _dealTextField(text);
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
      _isKeyboardActive = false;
    });

    print("[Keyboard] 1, isKeyboardActived:$_isKeyboardActive");
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("[Keyboard] 2, isKeyboardActived:$_isKeyboardActive");

      // 当前是安卓系统并且在焦点聚焦的情况下
      if (Platform.isAndroid && _focusNode.hasFocus) {
        if (_isKeyboardActive) {
          setState(() {
            _isKeyboardActive = false;
          });
          // 使输入框失去焦点
          _focusNode.unfocus();
          return;
        }
        setState(() {
          _isKeyboardActive = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: '创建Map3节点',
      ),
      backgroundColor: Colors.white,
      body: _pageView(context),
    );
  }

  @override
  void dispose() {
    _filterSubject.close();

    _focusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

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

    return Column(
      children: <Widget>[
        Expanded(
          child: BaseGestureDetector(
            context: context,
            child: CustomScrollView(
              slivers: <Widget>[
                _headerWidget(),
                _contentWidget(),
              ],
            ),
          ),
        ),
        _confirmButtonWidget(),
      ],
    );
  }

  Widget _nodeServerWidget() {
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
                            onTap: _pushWebView,
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("启动所需100万  ", style: TextStyles.textC99000000S13, maxLines: 1, softWrap: true),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(" (HYN) ", style: TextStyle(fontSize: 10, color: HexColor("#999999"))),
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
                          selectNodeProvider(
                            value,
                            0,
                          );
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 8.0,
              left: 15,
              bottom: 16,
            ),
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

  Widget _headerWidget() {
    var divider = Container(
      color: HexColor("#F4F4F4"),
      height: 8,
    );

    return SliverToBoxAdapter(
      child: Container(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _nodeServerWidget(),
          divider,
          getHoldInNum(context, contractItem, _joinCoinFormKey, _joinCoinController, endProfit, spendManager, false,
              focusNode: _focusNode),
          divider,
          managerSpendWidget(context, _rateCoinController, reduceFunc: () {
            setState(() {
              _managerSpendCount--;
              if (_managerSpendCount < 1) {
                _managerSpendCount = 1;
              }

              _rateCoinController.text = "$_managerSpendCount";
            });
          }, addFunc: () {
            setState(() {
              _managerSpendCount++;
              if (_managerSpendCount > 20) {
                _managerSpendCount = 20;
              }
              _rateCoinController.text = "$_managerSpendCount";
            });
          }),
          divider,
        ]),
      ),
    );
  }

  Widget _contentWidget() {
    return SliverToBoxAdapter(
      child: ListView.separated(
        itemBuilder: (context, index) {
          var subTitle = index < 3 ? "" : "（选填）";
          var title = _titleList[index];
          var detail = _detailList[index];
          //var detail = _detailList[index].isEmpty ? _hintList[index] : _detailList[index];
          var hint = _hintList[index];
          var keyboardType = TextInputType.text;

          switch (index) {
            case 0:
              detail = _localImagePath;
              break;

            case 3:
              keyboardType = TextInputType.url;
              break;

            case 4:
              keyboardType = TextInputType.phone;
              break;

            case 5:
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
    );
  }

  Widget _confirmButtonWidget() {
    return Visibility(
      visible: !_isKeyboardActive,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 37, vertical: 18),
        child: ClickOvalButton(
          "创建提交",
          _confirmAction,
          height: 46,
          width: MediaQuery.of(context).size.width - 37 * 2,
          fontSize: 18,
        ),
      ),
    );
  }

  void _confirmAction() async {
    if (_localImagePath.isEmpty) {
      Fluttertoast.showToast(msg: _hintList[0]);
      return;
    }

    if (_detailList[1].isEmpty) {
      Fluttertoast.showToast(msg: _hintList[1]);
      return;
    }

    if (_detailList[2].isEmpty) {
      Fluttertoast.showToast(msg: _hintList[2]);
      return;
    }

    for (var index = 0; index < _titleList.length; index++) {
      var title = _titleList[index];
      if (title == "图标") {
        _payload.pic = _localImagePath;
      } else if (title == "名称") {
        _payload.name = _detailList[1];
      } else if (title == "节点号") {
        _payload.nodeId = _detailList[2];
      } else if (title == "网址") {
        _payload.home = _detailList[3];
      } else if (title == "安全联系") {
        _payload.connect = _detailList[4];
      } else if (title == "描述") {
        _payload.describe = _detailList[5];
      }

      var feeRate = _rateCoinController.text ?? "0";
      _payload.feeRate = feeRate;

      var staking = _joinCoinController.text ?? "0";

      _payload.staking = staking;

      _selectProviderEntity = providerList[0];
      _payload.region = _selectProviderEntity.regions[selectNodeItemValue].name;
      _payload.provider = _selectProviderEntity.name;
    }
    _payload.isEdit = false;
    var encodeEntity = FluroConvertUtils.object2string(_payload.toJson());
    Application.router.navigateTo(context, Routes.map3node_create_confirm_page + "?entity=$encodeEntity");
  }

  void getNetworkData() async {
    try {
      var requestList =
          await Future.wait([_nodeApi.getContractInstanceItem(widget.contractId), _nodeApi.getNodeProviderList()]);
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

  void _joinTextFieldChangeListener() {
    _filterSubject.sink.add(_joinCoinController.text);
  }

  void _rateTextFieldChangeListener() {
    _managerSpendCount = int.parse(_rateCoinController.text ?? "0");
  }

  void _dealTextField(String inputText) {
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

  _pushWebView() {

    AtlasApi.goToAtlasMap3HelpPage(context);

    // String webUrl = FluroConvertUtils.fluroCnParamsEncode("http://baidu.com");
    // String webTitle = FluroConvertUtils.fluroCnParamsEncode("详细介绍");
    // Application.router.navigateTo(
    //     context, Routes.toolspage_webview_page + '?initUrl=$webUrl&title=$webTitle');

  }
}
