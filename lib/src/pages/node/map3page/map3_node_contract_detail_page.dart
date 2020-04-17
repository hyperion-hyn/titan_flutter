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
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/model/contract_delegator_item.dart';
import 'package:titan/src/pages/node/model/contract_detail_item.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/pages/node/model/node_item.dart';
import 'package:titan/src/pages/node/widget/custom_stepper.dart';
import 'package:titan/src/pages/node/widget/node_delegator_member_widget.dart';
import 'package:titan/src/pages/node/widget/node_join_member_widget.dart';
import 'package:titan/src/pages/wallet/api/etherscan_api.dart';
import 'package:titan/src/pages/webview/webview.dart';
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
  String _lastActionTitle = "";
  bool _isDelegated = false; // 判断当前(钱包=用户)是否参与抵押
  void Function() onPressed = () {};
  var _actionTitle = "";

  var _amountDelegation = "0";
  var _nodeStateDesc = "";
  var _contractNotifyDetail = "";

  var _contractStateDesc = "";
  var _contractStateDetail = "";

  LoadDataBloc loadDataBloc = LoadDataBloc();
  int _currentPage = 0;
  NodeApi _nodeApi = NodeApi();
  List<ContractDelegateRecordItem> _delegateRecordList = [];

  //BillsOperaState _currentOperaState = BillsOperaState.DELEGATE;
  int _durationType = 0;

  get _isPercent50 => _isDelegated && (_durationType == 2);

  get _stateColor {
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

  get _currentStep {
    int value;

    if (_isPercent50) {
      switch (_userDelegateState) {
        case UserDelegateState.PENDING:
        case UserDelegateState.CANCELLED:
        case UserDelegateState.CANCELLED_COLLECTED:
          value = 0;
          break;

        case UserDelegateState.ACTIVE:
          value = 1;
          break;

        case UserDelegateState.HALFDUE:
        case UserDelegateState.HALFDUE_COLLECTED:
          value = 2;
          break;

        case UserDelegateState.DUE:
          value = 3;
          break;

        case UserDelegateState.DUE_COLLECTED:
          value = 4;
          break;

        default:
          break;
      }
    } else {
      switch (_contractState) {
        case ContractState.PENDING:
        case ContractState.CANCELLED:
        case ContractState.CANCELLED_COMPLETED:
          value = 0;
          break;

        case ContractState.ACTIVE:
          value = 1;
          break;

        case ContractState.DUE:
          value = 2;
          break;

        case ContractState.DUE_COMPLETED:

          value = 3;
          break;

        default:
          break;
      }
    }

    return value;
  }

  get _currentStepProgress {
    double value;

    if (_isPercent50) {
      switch (_userDelegateState) {
        case UserDelegateState.PENDING:
        case UserDelegateState.CANCELLED:
        case UserDelegateState.CANCELLED_COLLECTED:
          //value = _contractNodeItem.remainProgress;
          value = 0.8;
          break;

        case UserDelegateState.ACTIVE:
          value = _contractNodeItem.expectHalfDueProgress;
          break;

        case UserDelegateState.HALFDUE:
        case UserDelegateState.HALFDUE_COLLECTED:
          value = _contractNodeItem.expectDueProgress;
          break;

        case UserDelegateState.DUE:
        case UserDelegateState.DUE_COLLECTED:

          value = 0;
          break;

        default:
          break;
      }
    } else {
      switch (_contractState) {
        case ContractState.PENDING:
        case ContractState.CANCELLED:
        case ContractState.CANCELLED_COMPLETED:
        //value = _contractNodeItem.remainProgress;
        value = 0.8;

        break;

        case ContractState.ACTIVE:
          value = _contractNodeItem.expectDueProgress;
          break;

        case ContractState.DUE:
        case ContractState.DUE_COMPLETED:
          value = 0;
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
    _contractNotifyDetail = S.of(context).wait_block_chain_verification;
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
    return WillPopScope(
      onWillPop: () async => !_isTransferring,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: <Widget>[
            _pageWidget(context),
            _bottomSureButtonWidget(),
          ],
        ),
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
                        getMap3NodeProductHeadItem(context, _contractNodeItem, isJoin: true, isDetail: false, hasShare: true)),
              ),
              SliverToBoxAdapter(child: _nodeInfoWidget()),
              _Spacer(),
              SliverToBoxAdapter(child: _contractNotifyWidget()),
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
                return _delegateRecordItemWidget(_delegateRecordList[index], index: index);
              }, childCount: _delegateRecordList.length)),
            ],
          )),
    );
  }

  Widget _bottomSureButtonWidget() {
    print("update----_bottomSureButtonWidget, _isTransferring:$_isTransferring");
    _actionTitle = _isTransferring ? S.of(context).extracting : _lastActionTitle;
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

  Widget _nodeInfoWidget() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
          child: Row(
            children: <Widget>[
              Text(_nodeStateDesc, style: TextStyle(fontSize: 14, color: HexColor("#666666"))),
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

  Widget _contractNotifyWidget() {
    if (!_isDelegated || _contractDetailItem == null) {
      return Container();
    }

    var amountDelegation = FormatUtil.amountToString(_contractDetailItem.amountDelegation);
    var expectedYield = FormatUtil.amountToString(_contractDetailItem.expectedYield);
    var commission = FormatUtil.amountToString(_contractDetailItem.commission);
    var textColor = _userDelegateState == UserDelegateState.CANCELLED ? HexColor("#B51414") : HexColor("#5C4304");
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            color: HexColor("#1FB9C7").withOpacity(0.08),
            margin: const EdgeInsets.only(top: 8.0),
            padding: const EdgeInsets.fromLTRB(23, 0, 16, 0),
            child: Row(
              children: <Widget>[
                Image.asset(
                  "res/drawable/volume.png",
                  width: 15,
                  height: 14,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Text(
                      _contractNotifyDetail,
                      style: TextStyle(fontSize: 14, color: textColor),
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
                    title = S.of(context).manager_tip_hyn;
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
                        shape: BoxShape.circle, color: _stateColor, border: Border.all(color: Colors.grey, width: 1.0)),
                  ),
                ),
                Text.rich(TextSpan(children: [
                  TextSpan(text: _contractStateDesc, style: TextStyle(fontSize: 12, color: Colors.grey)),
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
            child: _customStepperWidget(),
          ),
        ],
      ),
    );
  }

  Widget _customStepperWidget() {

    List<String> titles = [];
    List<int> subtitles = [];
    List<String> progressHints = [];

    if (_isPercent50) {
      titles = [
        S.of(context).create_time,
        S.of(context).launch_success,
        S.of(context).can_withdraw_fifty_reward,
        S.of(context).expire_date,
        S.of(context).extract_time
      ];
      subtitles = [
        _contractNodeItem.instanceStartTime,
        _contractNodeItem.instanceActiveTime,
        0,
        _contractNodeItem.instanceDueTime,
        _userDelegateState.index<UserDelegateState.ACTIVE.index? 0:_contractNodeItem.instanceFinishTime,
      ];
      progressHints = [
        S.of(context).n_day(7.toString()),
        S.of(context).n_day(90.toString()),
        S.of(context).n_day(90.toString()),
        "",
        ""
      ];
    } else {
      titles = [
        S.of(context).create_time,
        S.of(context).launch_success,
        S.of(context).expire_date,
        S.of(context).extract_time
      ];
      subtitles = [
        _contractNodeItem.instanceStartTime,
        _contractNodeItem.instanceActiveTime,
        _contractNodeItem.instanceDueTime,
        _contractState.index<ContractState.ACTIVE.index? 0:_contractNodeItem.instanceFinishTime,
      ];
      progressHints = [
        S.of(context).n_day(7.toString()),
        S.of(context).n_day(_contractNodeItem.contract.duration.toString()),
        "",
        ""
      ];
    }

    print('[detail] _currentStep:$_currentStep');
    return CustomStepper(
      tickColor: _stateColor,
      tickText: _contractStateDetail,
      currentStepProgress: _currentStepProgress,
      currentStep: _currentStep,
      steps: titles
          .map(
            (title) {
              var index = titles.indexOf(title);
              var subtitle = subtitles[index]>0?FormatUtil.formatDate(subtitles[index]):"";
              var date = progressHints[index];
              var textColor = _currentStep>=index ? HexColor("#4B4B4B") : HexColor("#A7A7A7");
              bool isMiddle = titles.length == 5 && index==2;

              return CustomStep(
                title: Text(
                  title,
                  style: TextStyle(fontSize: isMiddle ? 10 : 12, color: textColor, fontWeight: FontWeight.normal),
                ),
                progressHint: Text(
                  date,
                  style: TextStyle(fontSize: 12, color: HexColor("#4B4B4B"), fontWeight: FontWeight.normal),
                ),
                subtitle: Text(
                  subtitle,
                  style: TextStyle(fontSize: 10, color: HexColor("#A7A7A7"), fontWeight: FontWeight.normal),
                ),
                content: Container(
                ),
                isActive: true,
              );
            },
      ).toList(),
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
            Text(S.of(context).account_flow,
                style: TextStyle(fontSize: 16, color: HexColor("#333333"))),
            /*if (_currentOperaState == BillsOperaState.DELEGATE) Spacer(),
            if (_currentOperaState == BillsOperaState.DELEGATE)
              RichText(
                text: TextSpan(
                  text: "${S.of(context).total}：",
                  style: TextStyle(fontSize: 12, color: HexColor("#333333"), fontWeight: FontWeight.normal),
                  children: [
                    TextSpan(
                      text: "${FormatUtil.amountToString(_contractNodeItem.amountDelegation)} (HYN)",
                      style: TextStyle(fontSize: 12, color: HexColor("#FF4C3B"), fontWeight: FontWeight.normal),
                    )
                  ]
                ),

              )*/
          ],
        ),
      ),
    );
  }

  Widget _delegateRecordItemWidget(ContractDelegateRecordItem delegateItem, {int index = 0}) {
    String shortName = delegateItem.userName.substring(0, 1);
    String userAddress = shortBlockChainAddress(" ${delegateItem.userAddress}", limitCharsLength: 8);

    return Container(
      //padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Stack(
        children: <Widget>[
          InkWell(
            onTap: () {
              _pushWebView(delegateItem);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 40,
                    width: 40,
                    child: circleIconWidget(shortName),
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
                              style: TextStyle(fontSize: 14, color: HexColor("#000000"), fontWeight: FontWeight.w500),
                            ),
                          ),
                          Container(
                            height: 8.0,
                          ),
                          Text(
                            userAddress,
                            style: TextStyle(fontSize: 12, color: HexColor("#999999")),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Text(
                                FormatUtil.amountToString(delegateItem.amount),
                                style: TextStyle(fontSize: 14, color: HexColor("#333333"), fontWeight: FontWeight.bold),
                              ),
                            ),
                            _billStateWidget(delegateItem)
                          ],
                        ),
                        Container(
                          height: 8.0,
                        ),
                        Text(FormatUtil.formatDate(delegateItem.createAt, isSecond: true),
                            style: TextStyle(fontSize: 10, color: HexColor("#999999")))
                      ],
                    ),
                  ),
                ],
              ),
            ),
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

  Widget _billStateWidget(ContractDelegateRecordItem item) {
    // todo: test
    var state = enumBillsOperaStateFromString(item.operaType) == BillsOperaState.DELEGATE?"已转入":"已提取";
    switch (state) {
      case "入账中...":
        return Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [HexColor("#F3D35D"), HexColor("#E0B102")],
                  begin: FractionalOffset(1, 0.5),
                  end: FractionalOffset(0, 0.5)),
              borderRadius: BorderRadius.all(Radius.circular(12.0))),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
            child: Text(
              state,
              style: TextStyle(fontSize: 6, color: HexColor("#FFFFFF"), fontWeight: FontWeight.normal),
            ),
          ),
        );
        break;

      case "已入账":
        return Container(
          decoration: BoxDecoration(color: HexColor("#F2F2F2"), borderRadius: BorderRadius.all(Radius.circular(12.0))),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
            child: Text(
              state,
              style: TextStyle(fontSize: 6, color: HexColor("#999999"), fontWeight: FontWeight.normal),
            ),
          ),
        );
        break;

      case "入账失败":
        return Container(
          decoration: BoxDecoration(color: HexColor("#F2F2F2"), borderRadius: BorderRadius.all(Radius.circular(12.0))),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
            child: Text(
              state,
              style: TextStyle(fontSize: 6, color: HexColor("#CC2D1E"), fontWeight: FontWeight.normal),
            ),
          ),
        );
        break;

      default:
        return Container(
          decoration: BoxDecoration(color: HexColor("#F2F2F2"), borderRadius: BorderRadius.all(Radius.circular(12.0))),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
            child: Text(
              state,
              style: TextStyle(fontSize: 6, color: HexColor("#999999"), fontWeight: FontWeight.normal),
            ),
          ),
        );
        break;
    }
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
            _lastActionTitle = _actionTitle;
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
          _isTransferring = false;
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
        /*List<ContractDelegateRecordItem> filterMemberList = tempMemberList.where((element) {
          return enumBillsOperaStateFromString(element.operaType) == _currentOperaState;
        }).toList();*/
        _delegateRecordList.addAll(tempMemberList);
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

  Future getJoinMemberMoreData() async {
    try {
      _currentPage++;
      List<ContractDelegateRecordItem> tempMemberList =
          await _nodeApi.getContractDelegateRecord(widget.contractId, page: _currentPage);

      if (tempMemberList.length > 0) {
        /* List<ContractDelegateRecordItem> filterMemberList = tempMemberList.where((element) {
          return enumBillsOperaStateFromString(element.operaType) == _currentOperaState;
        }).toList();*/
        _delegateRecordList.addAll(tempMemberList);
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
//      _currentOperaState =
//          _contractState == ContractState.DUE_COMPLETED ? BillsOperaState.WITHDRAW : BillsOperaState.DELEGATE;
      _durationType = _contractNodeItem.contract.durationType;
      print('[contract] _pageView, contractState:$_contractState, userDelegateState:$_userDelegateState');

      // 2.
      await getJoinMemberData();

      _setupData();

      // 3.
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
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
        _actionTitle = S.of(context).withdrawRefund;
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
        _contractNotifyDetail = S.of(context).wait_block_chain_verification;

        _contractStateDesc = S.of(context).wait_to_launch;
        _contractStateDetail =
            S.of(context).remain + "${FormatUtil.amountToString(_contractNodeItem.remainDelegation)}HYN";
        break;

      case ContractState.ACTIVE:
        _nodeStateDesc = S.of(context).node_in_progress;
        _contractNotifyDetail = S.of(context).broadcase_sponsor_wait_net_verify("${FormatUtil.amountToString(_contractDetailItem.amountDelegation)}");

        _contractStateDesc = S.of(context).launch_success;
        _contractStateDetail = S.of(context).remain_day(_contractNodeItem.expectDueDay);
        break;

      case ContractState.DUE:
        _nodeStateDesc = S.of(context).node_had_stop;
        _contractNotifyDetail = "已到期，可提取奖励"+ "${FormatUtil.amountToString(_contractDetailItem.expectedYield)}HYN";

        _contractStateDesc = S.of(context).contract_had_expired;
        _contractStateDetail = S.of(context).expired_can_withdraw_rewards;
        break;

      case ContractState.CANCELLED:
        _nodeStateDesc = S.of(context).node_had_stop;
        _contractNotifyDetail = S.of(context).launch_fail_request_refund;

        _contractStateDesc = S.of(context).launch_fail;
        _contractStateDetail = S.of(context).launch_fail;
        break;

      case ContractState.DUE_COMPLETED:
        _nodeStateDesc = S.of(context).node_had_stop;
        _contractNotifyDetail = S.of(context).recovered_invested_capital;

        _contractStateDesc = S.of(context).contract_had_stop;
        _contractStateDetail = S.of(context).congratulation_reward_withdrawn;

        break;

      case ContractState.CANCELLED_COMPLETED:
        _nodeStateDesc = S.of(context).node_had_stop;
        _contractNotifyDetail = S.of(context).recovered_invested_capital;

        _contractStateDesc = S.of(context).launch_fail;
        _contractStateDetail = S.of(context).launch_fail;
        break;

      default:
        break;
    }

    if (_isDelegated) {
      if (_userDelegateState == UserDelegateState.HALFDUE) {
        _contractNotifyDetail = S.of(context).can_withdraw_fifty_reward;

        _contractStateDesc = S.of(context).launch_success;
        _contractStateDetail = S.of(context).can_withdraw_fifty_reward;
      } else if (_userDelegateState == UserDelegateState.HALFDUE_COLLECTED) {
        _contractNotifyDetail = "已成功提取一半奖励";

        _contractStateDesc = S.of(context).launch_success;
        _contractStateDetail = "恭喜你获得一半奖励";
      } else if (_userDelegateState == UserDelegateState.ACTIVE) {

        _contractStateDesc = S.of(context).launch_success;
        _contractStateDetail =  "可提50奖励的时间，"+S.of(context).remain_day_has_colon(_contractNodeItem.remainHalfDueDay);
      }
    }

    _lastActionTitle = _actionTitle;
  }

  void _pushWebView(ContractDelegateRecordItem delegateItem) {
    var isChinaMainland = SettingInheritedModel.of(context).areaModel?.isChinaMainland == true;
    var url = EtherscanApi.getTxDetailUrl(delegateItem.txHash, isChinaMainland);
    if (url != null) {
      /* String webUrl = FluroConvertUtils.fluroCnParamsEncode(url);
      String webTitle = FluroConvertUtils.fluroCnParamsEncode(S.of(context).detail);
      Application.router.navigateTo(context, Routes.toolspage_webview_page
          + '?initUrl=$webUrl&title=$webTitle');*/

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WebViewContainer(
                    initUrl: url,
                    title: S.of(context).detail,
                  )));
    }
  }
  
}
