import 'dart:io';
import 'dart:math';
import 'package:decimal/decimal.dart';
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
import 'package:titan/src/config/consts.dart';
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

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/bloc/wallet_cmp_event.dart';

class Map3NodeCreatePage extends StatefulWidget {
  final String contractId;

  Map3NodeCreatePage(this.contractId);

  @override
  _Map3NodeCreateState createState() => new _Map3NodeCreateState();
}

class _Map3NodeCreateState extends State<Map3NodeCreatePage> with WidgetsBindingObserver {
  TextEditingController _inputTextController = new TextEditingController();
  //TextEditingController _rateCoinController = new TextEditingController();

  final _inputFormKey = GlobalKey<FormState>();
  AllPageState _currentState = LoadingState();
  AtlasApi _atlasApi = AtlasApi();
  NodeApi _nodeApi = NodeApi();
  Map3IntroduceEntity _introduceEntity;
  BlsKeySignEntity _blsKeySignEntity;
  PublishSubject<String> _filterSubject = PublishSubject<String>();
  String endProfit = "";
  String spendManager = "";
  var _selectServerItemValue = 0;
  var _selectNodeItemValue = 0;
  NodeProviderEntity _selectProviderEntity;
  List<DropdownMenuItem> _serverList;
  List<DropdownMenuItem> _nodeList;
  List<NodeProviderEntity> _providerList = [];
  String _originInputStr = "";
  // double _currentFeeRate = 10;
  // double _maxFeeRate = 100;
  // double _minFeeRate = 0;
  // double _avgFeeRate = 0;
  double _fixedFeeRate = 0;

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

  var _titleList = [
    S.of(Keys.rootKey.currentContext).name,
    S.of(Keys.rootKey.currentContext).node_num,
    S.of(Keys.rootKey.currentContext).contact,
    S.of(Keys.rootKey.currentContext).website,
    S.of(Keys.rootKey.currentContext).description,
  ];
  List<String> _detailList = ["", "", "", "", ""];
  List<String> _hintList = [
    S.of(Keys.rootKey.currentContext).please_enter_node_name,
    S.of(Keys.rootKey.currentContext).please_input_node_num,
    S.of(Keys.rootKey.currentContext).please_input_node_contact,
    S.of(Keys.rootKey.currentContext).please_enter_node_address,
    S.of(Keys.rootKey.currentContext).please_enter_node_description
  ];

  @override
  void initState() {
    _inputTextController.addListener(_createTextFieldChangeListener);

    //_currentFeeRate = _maxFeeRate;
    //_rateCoinController.addListener(_rateTextFieldChangeListener);
    //_rateCoinController.text = "$_currentFeeRate";

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

    print("[Keyboard] 1, isKeyboardActive:$_isKeyboardActive");
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
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (context != null) {
      BlocProvider.of<WalletCmpBloc>(context).add(UpdateActivatedWalletBalanceEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: S.of(context).create_map3_node,
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

    return Column(
      children: <Widget>[
        Expanded(
          child: LoadDataContainer(
            bloc: _loadDataBloc,
            enablePullUp: false,
            onRefresh: getNetworkData,
            onLoadData: getNetworkData,
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
                              child: Text(_introduceEntity?.name ?? "", style: TextStyle(fontWeight: FontWeight.bold))),
                          InkWell(
                            child: Text(S.of(context).detailed_introduction,
                                style: TextStyle(fontSize: 14, color: HexColor("#1F81FF"))),
                            onTap: () => AtlasApi.goToAtlasMap3HelpPage(context),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                  S.of(context).active_still_need +
                                      "${FormatUtil.formatTenThousandNoUnit(_introduceEntity?.startMin?.toString() ?? "0")}" +
                                      S.of(context).ten_thousand,
                                  style: TextStyles.textC99000000S13,
                                  maxLines: 2,
                                  softWrap: true),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(" (HYN) ", style: TextStyle(fontSize: 10, color: HexColor("#999999"))),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text("  |  ",
                                  style: TextStyle(fontSize: 12, color: HexColor("000000").withOpacity(0.2))),
                            ),
                            Text(S.of(context).n_day("${_introduceEntity?.days ?? 0}"),
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
                        style: TextStyle(fontSize: 14, color: HexColor("#92979a")))),
                DropdownButtonHideUnderline(
                  child: Container(
                    height: 30,
                    child: DropdownButton(
                      value: _selectServerItemValue,
                      items: _serverList,
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
                      value: _selectNodeItemValue,
                      items: _nodeList,
                      onChanged: (value) {
                        setState(() {
                          selectNodeProvider(_selectServerItemValue, value);
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
            _inputFormKey,
            _inputTextController,
            endProfit,
            spendManager,
            focusNode: _focusNode,
            suggestList: _reCreateList,
            map3introduceEntity: _introduceEntity,
          ),
          divider,
          managerSpendWidgetConst(
            fixedFeeRate: _fixedFeeRate,
          ),
          /*
          managerSpendWidget(
            context,
            _rateCoinController,
            reduceFunc: () {
              setState(() {
                _currentFeeRate--;

                if (_currentFeeRate <= _minFeeRate) {
                  _currentFeeRate = _minFeeRate;
                }

                _rateCoinController.text = "$_currentFeeRate";
              });
            },
            addFunc: () {
              setState(() {
                _currentFeeRate++;
                if (_currentFeeRate >= _maxFeeRate) {
                  _currentFeeRate = _maxFeeRate;
                }

                _rateCoinController.text = "$_currentFeeRate";
              });
            },
            maxFeeRate: _maxFeeRate,
            minFeeRate: _minFeeRate,
            avgFeeRate: _avgFeeRate,
          ),
          */
          divider,
        ]),
      ),
    );
  }

  Widget _contentWidget() {
    return SliverToBoxAdapter(
      child: ListView.separated(
        itemBuilder: (context, index) {
          var subTitle = index < 3 ? "" : "（${S.of(context).optional_input}）";
          var title = _titleList[index];
          var detail = _detailList[index];
          var hint = _hintList[index];
          var keyboardType = TextInputType.text;

          switch (index) {
            case 2:
              keyboardType = TextInputType.url;
              break;

            case 3:
              keyboardType = TextInputType.text;
              break;

            case 4:
              break;
          }

          return editInfoItem(context, index, title, hint, detail, ({String value}) {
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
          S.of(context).submit_create,
          _confirmAction,
          height: 46,
          width: MediaQuery.of(context).size.width - 37 * 2,
          fontSize: 18,
        ),
      ),
    );
  }

  void _confirmAction() async {
    if (!_inputFormKey.currentState.validate()) {
      Fluttertoast.showToast(msg: S.of(context).please_input_hyn_count);
      return;
    }

    // 节点名称
    if (_detailList[0].isEmpty) {
      Fluttertoast.showToast(msg: _hintList[0]);
      return;
    }

    // 节点id
    if (_detailList[1].isEmpty) {
      Fluttertoast.showToast(msg: _hintList[1]);
      return;
    }

    try {
      var nodeId = _detailList[1];

      var haveExist = await _atlasApi.checkNodeIdExist(nodeId);
      if (haveExist) {
        Fluttertoast.showToast(msg: '节点号已存在，请输入其他节点号');
        return;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: '未知错误，请稍后重试！');
      return;
    }

    // 安全联系
    if (_detailList[2].isEmpty) {
      Fluttertoast.showToast(msg: _hintList[2]);
      return;
    }

    var coinVo = WalletInheritedModel.of(
      context,
      aspect: WalletAspect.activatedWallet,
    ).getCoinVoBySymbol('HYN');

    var staking = _inputStakingValue.toString();

    var stakingValue = Decimal.tryParse(staking);

    /*
    print("【create】staking: $staking");
    if (stakingValue.toDouble() <= 0) {
       Fluttertoast.showToast(msg: S.of(context).please_input_hyn_count);
      return;
    }*/

    var balance = Decimal.parse(FormatUtil.coinBalanceHumanRead(coinVo));

    if (stakingValue == null || stakingValue > Decimal.parse(FormatUtil.coinBalanceHumanRead(coinVo))) {
      Fluttertoast.showToast(msg: S.of(context).hyn_balance_no_enough);
      return;
    }

    var total = Decimal.parse('0.000021') + stakingValue;

    if (total >= balance) {
      Fluttertoast.showToast(msg: "请预留少量HYN（如：0.00005）作为矿工费");
      return;
    }

    // var feeRate = _inputFeeRateValue;
    // if (feeRate < _minFeeRate || feeRate > _maxFeeRate) {
    //   Fluttertoast.showToast(msg: S.of(context).manage_fee_range('${_minFeeRate.toInt()}', '${_maxFeeRate.toInt()}'));
    //   return;
    // }

    for (var index = 0; index < _titleList.length; index++) {
      var title = _titleList[index];

      if (title == S.of(Keys.rootKey.currentContext).name) {
        _payload.name = _detailList[0];
      } else if (title == S.of(Keys.rootKey.currentContext).node_num) {
        _payload.nodeId = _detailList[1];
      } else if (title == S.of(Keys.rootKey.currentContext).contact) {
        _payload.connect = _detailList[2];
      } else if (title == S.of(Keys.rootKey.currentContext).website) {
        _payload.home = _detailList[3];
      } else if (title == S.of(Keys.rootKey.currentContext).description) {
        _payload.describe = _detailList[4];
      }

      _payload.staking = staking;

      _payload.feeRate = _inputFeeRateValue.toString();

      _selectProviderEntity = _providerList[0];

      var region = _selectProviderEntity.regions[_selectNodeItemValue];
      _payload.regionName = region.name;
      _payload.region = region.id;
      // var latLng = region.location.coordinates.first.toString() + "," + region.location.coordinates.last.toString();
      // print("latLng:$latLng");
      // _payload.latLng = latLng;

      _payload.provider = _selectProviderEntity.id;
      _payload.providerName = _selectProviderEntity.name;

      _payload.blsAddKey = _blsKeySignEntity.blsKey;
      _payload.blsAddSign = _blsKeySignEntity.blsSign;
      _payload.blsRemoveKey = "";

      var pledgeMap3Entity = await createPledgeMap3Entity(
        context,
        _payload.nodeId,
        action: 'create',
      );

      _payload.userName = pledgeMap3Entity.payload.userName;

      _payload.userIdentity = '';
      _payload.userEmail = "";
      _payload.userPic = "";
    }
    var payloadJson = _payload.toJson();
    print("payloadJson: $payloadJson");
    var encodeEntity = FluroConvertUtils.object2string(payloadJson);
    Application.router.navigateTo(context, Routes.map3node_create_confirm_page + "?entity=$encodeEntity");
  }

  void getNetworkData() async {
    try {
      var requestList = await Future.wait([
        _nodeApi.getNodeProviderList(),
        AtlasApi.getIntroduceEntity(),
        _atlasApi.getMap3Bls(),
        _atlasApi.getMap3RecCreate(),
      ]);

      _providerList = requestList[0];
      _introduceEntity = requestList[1];
      _blsKeySignEntity = requestList[2];
      _reCreateList = requestList[3];

      // _maxFeeRate = 100 * double.parse(_introduceEntity?.feeMax ?? "100");
      // _minFeeRate = 100 * double.parse(_introduceEntity?.feeMin ?? "0");
      // _avgFeeRate = 100 * double.parse(_introduceEntity?.feeAvg ?? "0");
      _fixedFeeRate = 100 * double.parse(_introduceEntity?.feeFixed ?? "0");

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
        _loadDataBloc.add(RefreshFailEvent());
        _currentState = LoadFailState();
      });
    }
  }

  void selectNodeProvider(int providerIndex, int regionIndex) {
    if (_providerList.length == 0) {
      return;
    }

    _serverList = new List();
    for (int i = 0; i < _providerList.length; i++) {
      NodeProviderEntity nodeProviderEntity = _providerList[i];
      DropdownMenuItem item = new DropdownMenuItem(
          value: i,
          child: new Text(
            nodeProviderEntity.name,
            style: TextStyles.textC333S14,
          ));
      _serverList.add(item);
    }
    _selectServerItemValue = _serverList[providerIndex].value;

    List<Regions> nodeListStr = _providerList[providerIndex].regions;
    _nodeList = new List();
    for (int i = 0; i < nodeListStr.length; i++) {
      Regions regions = nodeListStr[i];
      DropdownMenuItem item =
          new DropdownMenuItem(value: i, child: new Text(regions.name, style: TextStyles.textC333S14));
      _nodeList.add(item);
    }
    _selectNodeItemValue = _nodeList[regionIndex].value;
  }

  get _inputStakingValue {
    var text = _inputTextController?.text ?? '0';
    if (text.isEmpty) {
      text = '0';
    }
    var value = double.tryParse(text);
    if (value == null) return 0;
    return value;
  }

  get _inputFeeRateValue {
    return _fixedFeeRate;

    /*
    var text = _rateCoinController?.text ?? '0';
    if (text.isEmpty) {
      text = '0';
    }
    var value = double.tryParse(text);
    if (value == null) return 0;
    return value;
    */
  }

  void _createTextFieldChangeListener() {
    _filterSubject.sink.add(_inputTextController.text);
  }

  /*
  _updateRate() {
    var createMin = double.parse(_introduceEntity?.startMin ?? '550000');
    var rate = (100 * (_inputStakingValue / createMin));
    if (rate >= 20) {
      _maxFeeRate = 20;
    } else if (rate < 20 && rate > 10) {
      _maxFeeRate = rate;
    } else {
      _maxFeeRate = 10;
    }
    _currentFeeRate = min(_currentFeeRate, _maxFeeRate);
    _rateCoinController.text = "$_currentFeeRate";
    setState(() {});
  }


  void _rateTextFieldChangeListener() {
    if (_inputFeeRateValue <= 0) {
      return;
    }

    var rateValue = _inputFeeRateValue;
    if (rateValue >= 10 && rateValue <= _maxFeeRate) {
      _currentFeeRate = rateValue;
    } else {
      Fluttertoast.showToast(msg: "管理费须在10%到$_maxFeeRate%之间");

      setState(() {
        _currentFeeRate = _maxFeeRate;
        _rateCoinController.text = "$_currentFeeRate";
      });
    }
  }
  */

  void _dealTextField(String inputText) {
    if (!mounted || _originInputStr == inputText) {
      return;
    }

    _originInputStr = inputText;
    _inputFormKey.currentState?.validate();

    if (inputText == null || inputText == "") {
      setState(() {
        endProfit = "";
        spendManager = "";
      });
      return;
    }

    if (mounted) {
      setState(() {
        _inputTextController.value = TextEditingValue(
            // 设置内容
            text: inputText,
            // 保持光标在最后
            selection:
                TextSelection.fromPosition(TextPosition(affinity: TextAffinity.downstream, offset: inputText.length)));
      });
    }
  }
}
