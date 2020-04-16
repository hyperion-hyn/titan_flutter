import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/load_data_bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/model/contract_delegator_item.dart';
import 'package:titan/src/pages/node/model/contract_detail_item.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/pages/node/model/node_item.dart';
import 'package:titan/src/pages/node/widget/node_delegator_member_widget.dart';
import 'package:titan/src/pages/node/widget/node_join_member_widget.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart' as all_page_state;
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/widget/enter_wallet_password.dart';
import 'package:web3dart/json_rpc.dart';
import '../../../global.dart';
import 'map3_node_create_contract_page.dart';

class Map3NodeContractDetailPage extends StatefulWidget {
  final int contractId;

  Map3NodeContractDetailPage(this.contractId);

  @override
  _Map3NodeContractDetailState createState() => new _Map3NodeContractDetailState();
}

class _Map3NodeContractDetailState extends BaseState<Map3NodeContractDetailPage> {
  all_page_state.AllPageState _currentState = all_page_state.LoadingState();
  NodeApi _api = NodeApi();

  ContractDetailItem _contractDetailItem;
  UserDelegateState _userDelegateState;

  ContractNodeItem _contractNodeItem;
  ContractState _contractState;

  Wallet _wallet;

  bool _visible = false;
  bool _isTransferring = false;
  bool _isDelegated = false; // 判断当前(钱包=用户)是否参与抵押
  void Function() onPressed = () {};
  var _actionTitle = "";

  var _amountDelegation = "0";
  var _nodeStateDesc = "";
  var _contractStateDesc = "";

  var _contractProgressDesc = "";
  var _contractProgressDetail = "";

  LoadDataBloc loadDataBloc = LoadDataBloc();
  int _currentPage = 0;
  NodeApi _nodeApi = NodeApi();
  List<ContractDelegateRecordItem> _delegateRecordList = [];

  BillsOperaState _currentOperaState = BillsOperaState.DELEGATE;
  int _durationType = 0;

  get _isPercent50 => _isDelegated && (_durationType == 2);

  get  _stateColor {
    var statusColor = HexColor('#EED197');

    switch (_contractState) {
      case ContractState.PENDING:
        statusColor = HexColor('#EED197');
        break;

      case ContractState.ACTIVE:
      case ContractState.DUE:
        statusColor = HexColor('#1FB9C7');
        break;

      case ContractState.CANCELLED:
      case ContractState.CANCELLED_COMPLETED:
        statusColor = HexColor('#F30202');
        break;

      default:
        statusColor = HexColor('#FFDB58');
        break;
    }
    return statusColor;
  }

  get _stateFactor {
    double value;

    if (_isPercent50) {
      switch (_userDelegateState) {
        case UserDelegateState.PENDING:
        case UserDelegateState.CANCELLED:
        case UserDelegateState.CANCELLED_COLLECTED:
          value = 1.25;
          break;

        case UserDelegateState.ACTIVE:
          value = 2;
          break;

        case UserDelegateState.HALFDUE:
          value = 3;
          break;

        case UserDelegateState.HALFDUE_COLLECTED:
          value = 3.05;

          break;

        case UserDelegateState.DUE:
          value = 4;
          break;

        case UserDelegateState.DUE_COLLECTED:
          value = 4.25;
          break;

        default:
          break;
      }
    }
    else {
      switch (_contractState) {
        case ContractState.PENDING:
        case ContractState.CANCELLED:
        case ContractState.CANCELLED_COMPLETED:
          value = 1.25;
          break;

        case ContractState.ACTIVE:
          value = 2;
          break;

        case ContractState.DUE:
          value = 3;
          break;

        case ContractState.DUE_COMPLETED:
          value = 3.5;
          break;

        default:
          break;
      }
    }

    return value;
  }

  @override
  void onCreated() {
    _actionTitle = S.of(context).confirm;
    _nodeStateDesc = S.of(context).node_in_configuration;
    _contractStateDesc = S.of(context).wait_block_chain_verification;
    super.onCreated();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    loadDataBloc.close();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_wallet == null) {
      _wallet = WalletInheritedModel.of(context).activatedWallet?.wallet;
      getContractInstanceItem();
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          _pageWidget(context),
          _bottomSureButtonWidget(),
        ],
      ),
    );
  }

  Widget _pageWidget(BuildContext context) {
    if (_currentState != null || _contractNodeItem.contract == null) {
      return AllPageStateContainer(_currentState, () {
        setState(() {
          _currentState = all_page_state.LoadingState();
        });
      });
    }

    return Padding(
      padding: EdgeInsets.only(bottom: _visible ? 48 : 0),
      child: LoadDataContainer(
          bloc: loadDataBloc,
          enablePullDown: false,
          onLoadingMore: () {
            getJoinMemberMoreData();
          },
          child: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Container(
                    color: Colors.white,
                    child:
                        getMap3NodeProductHeadItem(context, _contractNodeItem.contract, isJoin: true, isDetail: false)),
              ),
              SliverToBoxAdapter(child: _nodeInfoWidget(_nodeStateDesc)),

              _Spacer(),
              SliverToBoxAdapter(child: _contractActionsWidget(contractStateDesc: _contractStateDesc)),
              SliverToBoxAdapter(child: _lineSpacer()),
              SliverToBoxAdapter(child: _contractProgressWidget()),

              _Spacer(),
              SliverToBoxAdapter(
                child: NodeJoinMemberWidget(
                  "${widget.contractId}",
                  _contractNodeItem.remainDay,
                  _contractNodeItem.ownerName,
                  _contractNodeItem.shareUrl,
                  isShowInviteItem: false,
                ),
              ),

              _Spacer(),
              SliverToBoxAdapter(child: _delegateRecordHeaderWidget()),
              SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                return _delegateRecordItemWidget(_delegateRecordList[index]);
              }, childCount: _delegateRecordList.length)),
            ],
          )),
    );
  }

  Widget _bottomSureButtonWidget() {
    _actionTitle = _isTransferring ? S.of(context).extracting : _actionTitle;
    return Visibility(
      visible: _visible,
      child: Positioned(
        bottom: 0,
        height: 48,
        width: MediaQuery.of(context).size.width,
        child: Container(
          child: RaisedButton(
            textColor: Colors.white,
            color: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
                side: BorderSide(color: Theme.of(context).primaryColor), borderRadius: BorderRadius.circular(0)),
            child: Text(_actionTitle),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }

  Widget _nodeInfoWidget(String nodeStateDesc) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
          child: Row(
            children: <Widget>[
              Text(nodeStateDesc, style: TextStyle(fontSize: 14, color: HexColor("#666666"))),
              Spacer(),
              InkWell(
                  onTap: () {
                    String webUrl = FluroConvertUtils.fluroCnParamsEncode("https://www.map3.network");
                    String webTitle = FluroConvertUtils.fluroCnParamsEncode(S.of(context).map_node_detail);
                    Application.router
                        .navigateTo(context, Routes.toolspage_webview_page + '?initUrl=$webUrl&title=$webTitle');
                  },
                  child:
                      Text(S.of(context).click_view_detail, style: TextStyle(fontSize: 14, color: HexColor("#666666"))))
            ],
          ),
        ),
        Container(
          height: 0.8,
          color: DefaultColors.colorf5f5f5,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(45, 6, 5, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                      width: 100,
                      child:
                          Text(S.of(context).node_version, style: TextStyle(fontSize: 14, color: HexColor("#92979a")))),
                  new Text("${_contractNodeItem.contract.nodeName}", style: TextStyles.textC333S14)
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: <Widget>[
                    Container(
                        width: 100,
                        child: Text(S.of(context).service_provider,
                            style: TextStyle(fontSize: 14, color: HexColor("#92979a")))),
                    new Text("${_contractNodeItem.nodeProviderName}", style: TextStyles.textC333S14)
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: <Widget>[
                    Container(
                        width: 100,
                        child: Text(S.of(context).node_location,
                            style: TextStyle(fontSize: 14, color: HexColor("#92979a")))),
                    new Text("${_contractNodeItem.nodeRegionName}", style: TextStyles.textC333S14)
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _contractActionsWidget({String contractStateDesc = ""}) {
    if (!_isDelegated || _contractDetailItem == null) {
      return Container();
    }

    var amountDelegation = FormatUtil.amountToString(_contractDetailItem.amountDelegation);
    var expectedYield = FormatUtil.amountToString(_contractDetailItem.expectedYield);
    var commission = FormatUtil.amountToString(_contractDetailItem.commission);

    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.volume_up,
                  color: HexColor("#5C4304"),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Text(
                      contractStateDesc,
                      style: TextStyle(fontSize: 14, color: HexColor("#5C4304")),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
            child: Row(
              children: [1, 2, 3].map((value) {
                String title = "";
                String detail = "";
                TextStyle style = TextStyle(fontSize: 19, color: HexColor("#000000"), fontWeight: FontWeight.w600);
                switch (value) {
                  case 1:
                    title = S.of(context).you_have_invested_hyn;
                    detail = amountDelegation;
                    //style = TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold);
                    break;

                  case 2:
                    title = S.of(context).expected_output_hyn;
                    detail = expectedYield;
                    //style = TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold);
                    break;

                  case 3:
                    title = S.of(context).get_manager_hyn;
                    detail = commission;
                    //style = TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold);
                    break;
                }
                return Expanded(
                  child: Center(
                      child: Column(
                    children: <Widget>[
                      Text(detail, style: style),
                      Container(
                        height: 8,
                      ),
                      Text(title, style: TextStyles.textC9b9b9bS12),
                    ],
                  )),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contractProgressWidget() {
    double lineWidth = _durationType == 2 ? 40 : 45;
    double _left(bool isLine, double index) {
      double horizontal = _durationType == 2 ? 0 : 30;
      double gap = 16;
      double multi = _durationType == 2 ? 40 : 8;
      double sectionWidth =
          (MediaQuery.of(context).size.width - horizontal * 2.0 - lineWidth * 4.0 - gap * 8.0) / multi;

      if (!isLine) {
        return horizontal + sectionWidth * (index - 1) + gap * (2.0 * (index - 1)) + lineWidth * (index - 1);
      }
      return horizontal + sectionWidth * (index - 1) + gap * (2.0 * (index - 1)) + lineWidth * (index);
    }

    List<Widget> children = [];


    // todo: 测试
 /*   if (_isPercent50) {
      _userDelegateState = UserDelegateState.DUE;
      _contractState = ContractState.DUE;
    } else {
      _contractState = ContractState.DUE_COMPLETED;
    }
    _setupData();
*/
    if (_isPercent50) {
      var stateIndex = _userDelegateState?.index ?? 0;
      print(
          "【Detail】_contractProgressWidget，1,is:${stateIndex >= UserDelegateState.HALFDUE.index}, progress:${_contractNodeItem.expectHalfDueProgress}");

      children = [
        _nodeWidget(S.of(context).create_time, date: _contractNodeItem.instanceStartTime, left: _left(false, 1)),
        _lineWidget(S.of(context).n_day(7.toString()), lineWidth,
            left: _left(true, 1),
            progress: stateIndex >= UserDelegateState.ACTIVE.index ? 1 : _contractNodeItem.remainProgress),
        _nodeWidget(S.of(context).launch_success,
            date: _contractNodeItem.instanceActiveTime,
            left: _left(false, 2),
            isLight: stateIndex >= UserDelegateState.ACTIVE.index),
        _lineWidget(S.of(context).n_day(90.toString()), lineWidth,
            left: _left(true, 2),
            progress: stateIndex >= UserDelegateState.HALFDUE.index ? 1 : _contractNodeItem.expectHalfDueProgress),
        _nodeWidget(S.of(context).can_withdraw_fifty_reward,
            left: _left(false, 3) - 10, isLight: stateIndex >= UserDelegateState.HALFDUE.index),
        _lineWidget(S.of(context).n_day(90.toString()), lineWidth,
            left: _left(true, 3),
            progress: stateIndex >= UserDelegateState.DUE.index ? 1 : _contractNodeItem.expectDueProgress),
        _nodeWidget(S.of(context).expire_date,
            date: _contractNodeItem.instanceDueTime,
            left: _left(false, 4),
            isLight: stateIndex >= UserDelegateState.DUE.index),
        _lineWidget("", lineWidth,
            left: _left(true, 4), progress: stateIndex >= UserDelegateState.DUE_COLLECTED.index ? 1 : 0.0),
        _nodeWidget(S.of(context).extract_time,
            date: _contractNodeItem.instanceFinishTime,
            left: _left(false, 5),
            isLight: stateIndex >= UserDelegateState.DUE_COLLECTED.index),
        _stateWidget(_contractProgressDetail, left: _left(false, _stateFactor)),
        //_transformWidget(left: _left(false, _transformFactor - 0.5)),
      ];
    } else {
      var stateIndex = _contractState?.index ?? 0;
      print(
          "【Detail】_contractProgressWidget，2,is:${stateIndex >= ContractState.DUE.index}, progress:${_contractNodeItem.expectDueProgress}");
      children = [
        _nodeWidget(S.of(context).create_time, date: _contractNodeItem.instanceStartTime, left: _left(false, 1)),
        _lineWidget(S.of(context).n_day(7.toString()), lineWidth,
            left: _left(true, 1),
            progress: stateIndex >= ContractState.ACTIVE.index ? 1 : _contractNodeItem.remainProgress),
        _nodeWidget(S.of(context).launch_success,
            date: _contractNodeItem.instanceActiveTime,
            left: _left(false, 2),
            isLight: stateIndex >= ContractState.ACTIVE.index),
        _lineWidget(S.of(context).n_day(_contractNodeItem.contract.duration.toString()), lineWidth,
            left: _left(true, 2),
            progress: stateIndex >= ContractState.DUE.index ? 1.0 : _contractNodeItem.expectDueProgress),
        _nodeWidget(S.of(context).expire_date,
            date: _contractNodeItem.instanceDueTime,
            left: _left(false, 3),
            isLight: stateIndex >= ContractState.DUE.index),
        _lineWidget("", lineWidth,
            left: _left(true, 3), progress: stateIndex >= ContractState.DUE_COMPLETED.index ? 1.0 : 0.0),
        _nodeWidget(S.of(context).extract_time,
            date: _contractNodeItem.instanceFinishTime,
            left: _left(false, 4),
            isLight: stateIndex >= ContractState.DUE_COMPLETED.index),
        _stateWidget(_contractProgressDetail, left: _left(false, _stateFactor)),
        //_transformWidget(left: _left(false, _transformFactor - 0.5)),
      ];
    }

    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 18, right: 8.0),
                  child: Container(
                    width: 10,
                    height: 10,
                    //color: Colors.red,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _stateColor,
                        border: Border.all(color: Colors.grey, width: 1.0)),
                  ),
                ),
                Text.rich(TextSpan(children: [
                  TextSpan(text: _contractProgressDesc, style: TextStyle(fontSize: 12, color: Colors.grey)),
                  /*TextSpan(
                    text: _contractProgressDetail,
                    style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),
                  ),*/
                ])),
              ],
            ),
          ),
          Container(
            height: 140,
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
//            color: Colors.red,
            child: Stack(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stateWidget(String name, {double left = 10}) {
    return Positioned(
      left: left,
      top: 10,
      child: Container(
        color: _stateColor,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            name,
            style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.normal),
          ),
        ),
      ),
    );
  }

/*
  Widget _transformWidget({double left = 10}) {
    var rotation = (_contractState==ContractState.DUE_COMPLETED || _contractState==ContractState.DUE)?5.50:0.45;
    return Positioned(
      left: left,
      top: 32.5,
      width: 2.0,
      height: 30,
      child: Container(
        color: _stateColor,
        // rotationZ 的参数为弧度，1.6 大概等于 90°
        // 转换公式 ( 度数 * 3.14 / 180 )
        transform: Matrix4.rotationZ(rotation),
      ),
    );
  }
*/

  Widget _nodeWidget(String name, {int date = 0, double left = 10, bool isLight = true, bool isMiddle = false}) {
    double top = isLight ? 60 : 62;
    double wh = isLight ? 11 : 6;
    var circleColor = isLight ? HexColor("#322300") : HexColor("#CCCCCC");
    var textColor = isLight ? HexColor("#4B4B4B") : HexColor("#A7A7A7");
    var dateString = date > 0 ? "${FormatUtil.formatDate(date)}" : "";

    return Positioned(
      left: left,
      top: top,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: wh,
            height: wh,
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: Colors.white, border: Border.all(color: circleColor, width: 2.0)),
          ),
          Container(
            height: 8.0,
          ),
          Text(
            name,
            style: TextStyle(fontSize: isMiddle ? 10 : 12, color: textColor, fontWeight: FontWeight.normal),
          ),
          Container(
            height: 8.0,
          ),
          Text(
            dateString,
            style: TextStyle(fontSize: 10, color: HexColor("#A7A7A7"), fontWeight: FontWeight.normal),
          ),
          Container(
            height: 8.0,
          ),
        ],
      ),
    );
  }

  Widget _lineWidget(String name, double width, {double left = 10, double progress = 0.0}) {
    var lightColor = HexColor("#322300");
    var greyColor = HexColor("#ECECEC");

    return Positioned(
      top: name.isNotEmpty ? 38 : 42,
      left: left,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            name,
            style: TextStyle(fontSize: 12, color: HexColor("#4B4B4B"), fontWeight: FontWeight.normal),
          ),
          Container(
            height: 8.0,
          ),
          Stack(
            children: <Widget>[
              Container(
                height: 1.0,
                width: width,
                color: greyColor,
              ),
              Container(
                height: 1.0,
                width: width * progress == double.infinity ? 0 : width * progress,
                color: lightColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _lineSpacer() {
    return Container(
      height: 0.5,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      color: DefaultColors.colorf5f5f5,
    );
  }

  Widget _Spacer() {
    return SliverToBoxAdapter(
      child: Container(
        height: 10,
        color: DefaultColors.colorf5f5f5,
      ),
    );
  }

  Widget _delegateRecordHeaderWidget() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
        child: Row(
          children: <Widget>[
            Text(_currentOperaState == BillsOperaState.DELEGATE ? S.of(context).account_flow : "奖励流水",
                style: TextStyle(fontSize: 16, color: HexColor("#333333"))),
            if (_currentOperaState == BillsOperaState.DELEGATE) Spacer(),
            if (_currentOperaState == BillsOperaState.DELEGATE)
              Text(S.of(context).total + "：${FormatUtil.amountToString(_contractNodeItem.amountDelegation)} (HYN)",
                  style: TextStyle(fontSize: 14, color: HexColor("#999999")))
          ],
        ),
      ),
    );
  }

  Widget _delegateRecordItemWidget(ContractDelegateRecordItem delegateItem) {
    String showName = delegateItem.userName.substring(0, 1);
    String userAddress = shortBlockChainAddress(" ${delegateItem.userAddress}", limitCharsLength: 8);
    String txHash = shortBlockChainAddress(delegateItem.txHash, limitCharsLength: 6);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Stack(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 40,
                width: 40,
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(13.0)),
                  ),
                  child: Center(
                      child: Text(
                    showName,
                    style: TextStyle(fontSize: 15, color: HexColor("#000000")),
                  )),
                ),
              ),
              Flexible(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      RichText(
                        text: TextSpan(
                            text: "${delegateItem.userName}",
                            style: TextStyle(fontSize: 14, color: HexColor("#000000")),
                            children: [
                              TextSpan(
                                text: userAddress,
                                style: TextStyle(fontSize: 12, color: HexColor("#9B9B9B")),
                              )
                            ]),
                      ),
                      Container(
                        height: 6.0,
                      ),
                      Text("${FormatUtil.formatDate(delegateItem.createAt)}",
                          style: TextStyle(fontSize: 12, color: HexColor("#333333"))),
                      Container(
                        height: 6.0,
                      ),
                    ],
                  ),
                ),
              ),
              //Spacer(),
              Container(
                width: 8,
              ),
              Flexible(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                        text: FormatUtil.amountToString(delegateItem.amount),
                        style: TextStyle(fontSize: 14, color: HexColor("#333333"), fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      height: 6.0,
                    ),
                    Text(txHash, style: TextStyle(fontSize: 12, color: HexColor("#333333")))
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 40,
            right: 8,
            child: Container(
              height: 0.5,
              color: DefaultColors.colorf5f5f5,
            ),
          ),
        ],
      ),
    );
  }

  Future _collectAction() async {
    if (_wallet == null || _contractDetailItem == null) {
      return;
    }

    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return EnterWalletPasswordWidget();
        }).then((walletPassword) async {
      if (walletPassword == null) {
        return;
      }

      try {
        setState(() {
          if (mounted) {
            _isTransferring = true;
          }
        });

        var gasPriceRecommend = QuotesInheritedModel.of(context, aspect: QuotesAspect.gasPrice).gasPriceRecommend;
        var gasPrice = gasPriceRecommend.average.toInt();

        var gasLimit = EthereumConst.COLLECT_MAP3_NODE_CREATOR_GAS_LIMIT;
        if (_userDelegateState == UserDelegateState.HALFDUE) {
          gasLimit = EthereumConst.COLLECT_HALF_MAP3_NODE_GAS_LIMIT;
        } else {
          if (_isDelegated) {
            gasLimit = EthereumConst.COLLECT_MAP3_NODE_CREATOR_GAS_LIMIT;
          } else {
            gasLimit = EthereumConst.COLLECT_MAP3_NODE_PARTNER_GAS_LIMIT;
          }
        }

        var collectHex = await _api.withdrawContractInstance(
            _contractNodeItem, WalletVo(wallet: _wallet), walletPassword, gasPrice, gasLimit);
        logger.i('map3 collect, collectHex: $collectHex');

        Application.router.navigateTo(
            context,
            Routes.map3node_broadcase_success_page +
                "?pageType=${Map3NodeCreateContractPage.CONTRACT_PAGE_TYPE_COLLECT}");
      } catch (_) {
        logger.e(_);
        setState(() {
          if (mounted) {
            _isTransferring = false;
          }
        });
        if (_ is PlatformException) {
          if (_.code == WalletError.PASSWORD_WRONG) {
            Fluttertoast.showToast(msg: S.of(context).password_incorrect);
          } else {
            Fluttertoast.showToast(msg: S.of(context).transfer_fail);
          }
        } else if (_ is RPCError) {
          if (_.errorCode == -32000) {
            Fluttertoast.showToast(msg: _.message, toastLength: Toast.LENGTH_LONG);
          } else {
            Fluttertoast.showToast(msg: S.of(context).transfer_fail);
          }
        } else {
          Fluttertoast.showToast(msg: S.of(context).transfer_fail);
        }
      }
    });
  }

  Future getJoinMemberData() async {
    try {
      _currentPage = 0;
      _delegateRecordList = [];

      List<ContractDelegateRecordItem> tempMemberList =
          await _nodeApi.getContractDelegateRecord(widget.contractId, page: _currentPage);

      if (tempMemberList.length > 0) {
        List<ContractDelegateRecordItem> filterMemberList = tempMemberList.where((element) {
          return enumBillsOperaStateFromString(element.operaType) == _currentOperaState;
        }).toList();
        _delegateRecordList.addAll(filterMemberList);
        loadDataBloc.add(LoadingMoreSuccessEvent());
      } else {
        loadDataBloc.add(LoadMoreEmptyEvent());
      }

      //setState(() {});
    } catch (e) {
      loadDataBloc.add(LoadMoreFailEvent());

      //setState(() {});
    }
  }

  void getJoinMemberMoreData() async {
    try {
      _currentPage++;
      List<ContractDelegateRecordItem> tempMemberList =
          await _nodeApi.getContractDelegateRecord(widget.contractId, page: _currentPage);

      if (tempMemberList.length > 0) {
        List<ContractDelegateRecordItem> filterMemberList = tempMemberList.where((element) {
          return enumBillsOperaStateFromString(element.operaType) == _currentOperaState;
        }).toList();
        _delegateRecordList.addAll(filterMemberList);
        loadDataBloc.add(LoadingMoreSuccessEvent());
      } else {
        loadDataBloc.add(LoadMoreEmptyEvent());
      }

      setState(() {});
    } catch (e) {
      setState(() {
        loadDataBloc.add(LoadMoreFailEvent());
      });
    }
  }

  Future getContractInstanceItem() async {
    try {
      // 0.
      _isDelegated = await _api.checkIsDelegatedContractInstance(widget.contractId);
      print('[detail] check , isDelegated:$_isDelegated');

      if (_isDelegated) {
        _contractDetailItem = await _api.getContractDetail(widget.contractId);
        _contractNodeItem = _contractDetailItem?.instance;
      } else {
        _contractNodeItem = await _api.getContractInstanceItem("${widget.contractId}");
      }

      // 1.
      _userDelegateState = enumUserDelegateStateFromString(_contractDetailItem?.state ?? "");
      _contractState = enumContractStateFromString(_contractNodeItem.state);
      _currentOperaState =
          _contractState == ContractState.DUE_COMPLETED ? BillsOperaState.WITHDRAW : BillsOperaState.DELEGATE;
      _durationType = _contractNodeItem.contract.durationType;
      print('[contract] _pageView, contractState:$_contractState, userDelegateState:$_userDelegateState');

      // 2.
      await getJoinMemberData();

      _setupData();

      // 3.
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          // todo： 测试
          //_contractDetailItem.userDelegateState = UserDelegateState.DUE_COLLECTED.toString().split(".").last;
          _currentState = null;
        });
      });
    } catch (e) {
      setState(() {
        _currentState = all_page_state.LoadFailState();
      });
    }
  }

  void _setupData() {
    // 1.底部操作按钮相关数据
    switch (_userDelegateState) {
      case UserDelegateState.PENDING:
        _actionTitle = S.of(context).increase_investment;
        onPressed = () {
          Application.router
              .navigateTo(context, Routes.map3node_join_contract_page + "?contractId=${_contractNodeItem.id}");
        };
        _visible = true;
        break;

      case UserDelegateState.ACTIVE:
        _actionTitle = S.of(context).mortgaged;
        onPressed = () {
          Fluttertoast.showToast(msg: S.of(context).node_is_running);
        };
        _visible = false;
        break;

      case UserDelegateState.DUE:
        _actionTitle = S.of(context).extract;
        onPressed = () {
          _collectAction();
        };
        _visible = true;
        break;

      case UserDelegateState.DUE_COLLECTED:
        _actionTitle = S.of(context).finish;
        onPressed = () {
          Fluttertoast.showToast(msg: S.of(context).node_revenue_extracted);
        };
        _visible = false;
        break;

      case UserDelegateState.HALFDUE:
        _actionTitle = S.of(context).withdraw_fifty_revenue;
        onPressed = () {
          _collectAction();
        };
        _visible = true;
        break;

      case UserDelegateState.HALFDUE_COLLECTED:
        _actionTitle = S.of(context).finish;
        onPressed = () {
          Fluttertoast.showToast(msg: S.of(context).node_half_revenue_had_withdraw);
        };
        _visible = false;
        break;

      case UserDelegateState.CANCELLED:
        _actionTitle = S.of(context).extract;
        onPressed = () {
          _collectAction();
        };
        _visible = true;
        break;

      case UserDelegateState.CANCELLED_COLLECTED:
        _actionTitle = S.of(context).finish;
        onPressed = () {
          Fluttertoast.showToast(msg: S.of(context).node_return_had_withdraw_finish);
        };
        _visible = false;
        break;

      default:
        break;
    }

    if (!_isDelegated && _contractState == ContractState.PENDING) {
      _actionTitle = S.of(context).join_delegate;
      onPressed = () {
        Application.router
            .navigateTo(context, Routes.map3node_join_contract_page + "?contractId=${_contractNodeItem.id}");
      };
      _visible = true;
    }

    // 2.节点-合约-状态-进度相关
    switch (_contractState) {
      case ContractState.PENDING:
        _nodeStateDesc = S.of(context).node_wait_to_launch;
        _contractStateDesc = S.of(context).wait_block_chain_verification;

        _contractProgressDesc = S.of(context).wait_to_launch;
        _contractProgressDetail =
            S.of(context).remain + "${FormatUtil.amountToString(_contractNodeItem.remainDelegation)}HYN";
        break;

      case ContractState.ACTIVE:
        _nodeStateDesc = S.of(context).node_in_progress;
        _contractStateDesc = S.of(context).broadcase_sponsor_wait_net_verify(_amountDelegation);

        _contractProgressDesc = S.of(context).launch_success;
        _contractProgressDetail = S.of(context).remain_day(_contractNodeItem.expectDueDay);
        break;

      case ContractState.DUE:
        _nodeStateDesc = S.of(context).node_had_stop;

        _contractProgressDesc = S.of(context).launch_success;
        _contractProgressDetail = S.of(context).expired_can_withdraw_rewards;
        break;

      case ContractState.CANCELLED:
        _nodeStateDesc = S.of(context).node_had_stop;
        _contractStateDesc = S.of(context).launch_fail_request_refund;

        _contractProgressDesc = S.of(context).launch_fail;
        _contractProgressDetail = S.of(context).launch_fail;
        break;

      case ContractState.DUE_COMPLETED:
        _nodeStateDesc = S.of(context).node_had_stop;
        _contractStateDesc = S.of(context).recovered_invested_capital;

        _contractProgressDesc = S.of(context).earned_rewards;
        _contractProgressDetail = S.of(context).congratulation_reward_withdrawn;

        break;

      case ContractState.CANCELLED_COMPLETED:
        _nodeStateDesc = S.of(context).node_had_stop;
        _contractStateDesc = S.of(context).recovered_invested_capital;

        _contractProgressDesc = S.of(context).launch_fail;
        _contractProgressDetail = S.of(context).launch_fail;
        break;

      default:
        break;
    }

    if (_isDelegated) {
      if (_userDelegateState == UserDelegateState.HALFDUE) {
        _contractProgressDesc = S.of(context).launch_success;
        _contractProgressDetail = S.of(context).can_withdraw_fifty_reward;
      }
      else if (_userDelegateState == UserDelegateState.HALFDUE_COLLECTED) {
        _contractProgressDesc = S.of(context).launch_success;
        _contractProgressDetail = "恭喜你获得一半奖励";
      }
      else if (_userDelegateState == UserDelegateState.ACTIVE) {
        _contractProgressDesc = S.of(context).launch_success;
        _contractProgressDetail = S.of(context).remain_day_has_colon(_contractNodeItem.remainHalfDueDay);
      }
    }
  }

}
