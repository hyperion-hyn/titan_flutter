import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/load_data_bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/load_data_event.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/bls_key_sign_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/create_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_introduce_entity.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/model/node_provider_entity.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
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

class _Map3NodeCreateState extends State<Map3NodeCreatePage>
    with WidgetsBindingObserver {
  TextEditingController _joinCoinController = new TextEditingController();
  TextEditingController _rateCoinController = new TextEditingController();

  final _joinCoinFormKey = GlobalKey<FormState>();
  AllPageState _currentState = LoadingState();
  AtlasApi _atlasApi = AtlasApi();
  NodeApi _nodeApi = NodeApi();
  Map3IntroduceEntity _introduceEntity;
  BlsKeySignEntity _blsKeySignEntity;
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
  List<String> _reCreateList = [];

  // ignore: close_sinks
  LoadDataBloc _loadDataBloc = LoadDataBloc();

  // 输入框的焦点实例
  FocusNode _focusNode;

  // 当前键盘是否是激活状态
  bool _isKeyboardActive = false;

  // var _localImagePath = "";
  // var _titleList = ["图标", "名称", "节点号", "网址", "安全联系", "描述"];
  // List<String> _detailList = ["", "", "", "", "", ""];
  // List<String> _hintList = ["请选择节点图标", "请输入节点名称", "请输入节点号", "请输入节点网址", "请输入节点的联系方式", "请输入节点描述"];

  var _titleList = ["名称", "节点号", "网址", "安全联系", "描述"];
  List<String> _detailList = ["", "", "", "", ""];
  List<String> _hintList = [
    "请输入节点名称",
    "请输入节点号",
    "请输入节点网址",
    "请输入节点的联系方式",
    "请输入节点描述"
  ];

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
    if (_currentState != null || _blsKeySignEntity == null) {
      return AllPageStateContainer(_currentState, () {
        setState(() {
          _currentState = LoadingState();
        });
        getNetworkData();
      });
    }

    var activatedWallet = WalletInheritedModel.of(context).activatedWallet;
    var walletName = activatedWallet.wallet.keystore.name;

    return Column(
      children: <Widget>[
        Expanded(
          child: LoadDataContainer(
            bloc: _loadDataBloc,
            enablePullUp: false,
            onRefresh: getNetworkData,
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
                          Expanded(
                              child: Text(_introduceEntity?.name ?? "",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          InkWell(
                            child: Text("详细介绍",
                                style: TextStyle(
                                    fontSize: 14, color: HexColor("#1F81FF"))),
                            onTap: () =>
                                AtlasApi.goToAtlasMap3HelpPage(context),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                                "启动所需" +
                                    "${FormatUtil.formatTenThousandNoUnit(_introduceEntity?.startMin?.toString() ?? "0")}" +
                                    S.of(context).ten_thousand,
                                style: TextStyles.textC99000000S13,
                                maxLines: 2,
                                softWrap: true),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(" (HYN) ",
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: HexColor("#999999"))),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text("  |  ",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          HexColor("000000").withOpacity(0.2))),
                            ),
                            Text(
                                S
                                    .of(context)
                                    .n_day("${_introduceEntity?.days ?? 0}"),
                                style: TextStyles.textC99000000S13)
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
                    child: Text(S.of(context).node_location,
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
          getHoldInNum(
            context,
            null,
            _joinCoinFormKey,
            _joinCoinController,
            endProfit,
            spendManager,
            false,
            focusNode: _focusNode,
            suggestList: _reCreateList,
            map3introduceEntity: _introduceEntity,
          ),
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
          var subTitle = index < 2 ? "" : "（选填）";
          var title = _titleList[index];
          var detail = _detailList[index];
          //var detail = _detailList[index].isEmpty ? _hintList[index] : _detailList[index];
          var hint = _hintList[index];
          var keyboardType = TextInputType.text;

          switch (index) {
            case 2:
              keyboardType = TextInputType.url;
              break;

            case 3:
              keyboardType = TextInputType.phone;
              break;

            case 4:
              break;
          }

          return editInfoItem(context, index, title, hint, detail, (
              {String value}) {
            setState(() {
              _detailList[index] = value;
            });
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
    if (_detailList[0].isEmpty) {
      Fluttertoast.showToast(msg: _hintList[0]);
      return;
    }

    if (_detailList[1].isEmpty) {
      Fluttertoast.showToast(msg: _hintList[1]);
      return;
    }

    for (var index = 0; index < _titleList.length; index++) {
      var title = _titleList[index];

      if (title == "名称") {
        _payload.name = _detailList[0];
      } else if (title == "节点号") {
        _payload.nodeId = _detailList[1];
      } else if (title == "网址") {
        _payload.home = _detailList[2];
      } else if (title == "安全联系") {
        _payload.connect = _detailList[3];
      } else if (title == "描述") {
        _payload.describe = _detailList[4];
      }

      var feeRate = _rateCoinController.text ?? "0";
      _payload.feeRate = feeRate;

      var staking = _joinCoinController.text ?? "0";

      _payload.staking = staking;

      _selectProviderEntity = providerList[0];
      _payload.region = _selectProviderEntity.regions[selectNodeItemValue].name;
      _payload.provider = _selectProviderEntity.name;
      _payload.blsAddKey = _blsKeySignEntity.blsKey;
      _payload.blsAddSign = _blsKeySignEntity.blsSign;
      _payload.blsRemoveKey = "";
    }
    _payload.isEdit = false;
    var encodeEntity = FluroConvertUtils.object2string(_payload.toJson());
    Application.router.navigateTo(
        context, Routes.map3node_create_confirm_page + "?entity=$encodeEntity");
  }

  void getNetworkData() async {
    try {
      var requestList = await Future.wait([
        _nodeApi.getNodeProviderList(),
        _atlasApi.getMap3Introduce(),
        _atlasApi.getMap3Bls(),
        _atlasApi.getMap3RecCreate(),
      ]);

      print("[object] ===> requestList:${requestList.length}");

      providerList = requestList[0];
      _introduceEntity = requestList[1];
      _blsKeySignEntity = requestList[2];
      _reCreateList = requestList[3];

      selectNodeProvider(0, 0);

      if (mounted) {
        setState(() {
          _currentState = null;
          _loadDataBloc.add(RefreshSuccessEvent());
        });
      }
    } catch (e) {
      print(e);

      setState(() {
        _currentState = LoadFailState();
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

  void _joinTextFieldChangeListener() {
    _filterSubject.sink.add(_joinCoinController.text);
  }

  void _rateTextFieldChangeListener() {
    _managerSpendCount = int.parse(_rateCoinController.text ?? "0");
  }

  void _dealTextField(String inputText) {
    if (!mounted || originInputStr == inputText) {
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

    if (mounted) {
      setState(() {
        _joinCoinController.value = TextEditingValue(
            // 设置内容
            text: inputText,
            // 保持光标在最后
            selection: TextSelection.fromPosition(TextPosition(
                affinity: TextAffinity.downstream, offset: inputText.length)));
      });
    }
  }
}
