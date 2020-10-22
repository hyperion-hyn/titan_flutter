import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/load_data_bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/quotes/bloc/bloc.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_tx_log_entity.dart';
import 'package:titan/src/pages/atlas_map/widget/custom_stepper.dart';
import 'package:titan/src/pages/atlas_map/widget/node_join_member_widget.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/model/map3_node_util.dart';
import 'package:titan/src/pages/node/model/node_provider_entity.dart';
import 'package:titan/src/pages/wallet/model/transtion_detail_vo.dart';
import 'package:titan/src/pages/wallet/wallet_show_account_info_page.dart';
import 'package:titan/src/pages/webview/webview.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart' as all_page_state;
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/map3_nodes_widget.dart';
import 'package:titan/src/widget/popup/bubble_widget.dart';
import 'package:titan/src/widget/popup/pop_route.dart';
import 'package:titan/src/widget/popup/pop_widget.dart';
import 'package:titan/src/widget/wallet_widget.dart';
import 'package:web3dart/web3dart.dart';
import '../../../global.dart';
import 'map3_node_create_wallet_page.dart';
import 'map3_node_public_widget.dart';
import 'package:web3dart/src/models/map3_node_information_entity.dart';

class Map3NodeDetailPage extends StatefulWidget {
  final Map3InfoEntity map3infoEntity;

  Map3NodeDetailPage(this.map3infoEntity);

  @override
  _Map3NodeDetailState createState() => _Map3NodeDetailState();
}

class _Map3NodeDetailState extends BaseState<Map3NodeDetailPage> {
  all_page_state.AllPageState _currentState = all_page_state.LoadingState();
  AtlasApi _atlasApi = AtlasApi();

  //0映射中;1 创建提交中；2创建失败; 3募资中,没在撤销节点;4募资中，撤销节点提交中，如果撤销失败将回到3状态；5撤销节点成功；6合约已启动；7合约期满终止；
  Map3InfoStatus _map3Status = Map3InfoStatus.CREATE_SUBMIT_ING;
  Map3InfoEntity _map3infoEntity;

  get _isVisibleNotification {
    var startMin = double.parse(AtlasApi.map3introduceEntity?.startMin ?? "0");
    var staking = ConvertTokenUnit.weiToEther(
        weiBigInt: BigInt.parse(
      widget.map3infoEntity?.staking ?? "0",
    )).toDouble();
    var isFull = (startMin > 0) && (staking > 0) && (staking >= startMin);
    var condition0 = (_map3Status == Map3InfoStatus.FUNDRAISING_NO_CANCEL && isFull);

    var condition1 =
        (_map3Status == Map3InfoStatus.CANCEL_NODE_SUCCESS || _map3Status == Map3InfoStatus.CONTRACT_IS_END);

    return condition0 || condition1;
  }

  bool _visible = false;
  bool _isTransferring = false;

  bool _isDelegated = true; // todo:判断当前(钱包=用户)是否参与抵押, 不一定是180天

  LoadDataBloc _loadDataBloc = LoadDataBloc();
  int _currentPage = 0;
  List<Map3TxLogEntity> _delegateRecordList = [];

  get _stateColor => Map3NodeUtil.statusColor(_map3Status);

  get _isNoWallet => _address.isEmpty;

  get _canPreEdit => _map3Status == Map3InfoStatus.CONTRACT_HAS_STARTED;

  get _isOwner => _map3infoEntity.address == _address;

  get _currentStep {
    if (_map3Status == null) return 0;

    int value = 0;

    switch (_map3Status) {
      case Map3InfoStatus.MAP:
      case Map3InfoStatus.CREATE_SUBMIT_ING:
      case Map3InfoStatus.FUNDRAISING_NO_CANCEL:
      case Map3InfoStatus.FUNDRAISING_CANCEL_SUBMIT:
      case Map3InfoStatus.CANCEL_NODE_SUCCESS:
        value = 0;
        break;

      case Map3InfoStatus.CONTRACT_HAS_STARTED:
        value = 1;
        break;

      case Map3InfoStatus.CONTRACT_IS_END:
        value = 2;
        break;

      default:
        break;
    }

    return value;
  }

  get _currentStepProgress {
    if (_map3Status == null) return 0.0;

    double value = 0.0;

    /*
    switch (_map3Status) {
      case Map3InfoStatus.PRE_CREATE:
      case Map3InfoStatus.PENDING:
      case Map3InfoStatus.CANCELLED:
      case Map3InfoStatus.CANCELLED_COMPLETED:
      case Map3InfoStatus.FAIL:
        break;

      case Map3InfoStatus.ACTIVE:
        break;

      case Map3InfoStatus.DUE:
        value = 0;
        break;

      default:
        break;
    }
    */

    return value;
  }

  get _contractStateDesc {
    if (_map3Status == null) {
      return S.of(context).wait_to_launch;
    }

    var _contractStateDesc = "";

    /*
    switch (_map3Status) {
      case Map3InfoStatus.PRE_CREATE:
      case Map3InfoStatus.PENDING:
        _contractStateDesc = S.of(context).wait_to_launch;
        break;

      case Map3InfoStatus.ACTIVE:
        _contractStateDesc = S.of(context).contract_running;
        break;

      case Map3InfoStatus.DUE:
        _contractStateDesc = S.of(context).contract_had_expired;
        break;

      case Map3InfoStatus.CANCELLED:
      case Map3InfoStatus.CANCELLED_COMPLETED:
      case Map3InfoStatus.FAIL:
        _contractStateDesc = S.of(context).launch_fail;
        break;

      default:
        break;
    }
    */

    return _contractStateDesc;
  }

  get _contractStateDetail {
    if (_map3Status == null) {
      return S.of(context).wait_block_chain_verification;
    }

    var _contractStateDetail = "";
    /*
    switch (_map3Status) {
      case Map3InfoStatus.PRE_CREATE:
      case Map3InfoStatus.PENDING:
        break;

      case Map3InfoStatus.ACTIVE:
        break;

      case Map3InfoStatus.DUE:
        _contractStateDetail = S.of(context).expired_can_withdraw_rewards;
        break;

      case Map3InfoStatus.CANCELLED:
        _contractStateDetail = S.of(context).launch_fail;
        break;

        break;

      case Map3InfoStatus.CANCELLED_COMPLETED:
      case Map3InfoStatus.FAIL:
        _contractStateDetail = S.of(context).launch_fail;
        break;

      default:
        break;
    }
    */

    return _contractStateDetail;
  }

  var _moreKey = GlobalKey(debugLabel: '__more_global__');
  double _moreSizeHeight = 18;
  double _moreSizeWidth = 100;
  double _moreOffsetLeft = 246;
  double _moreOffsetTop = 76;
  var _address = "";
  var _nodeId = "";
  var _nodeAddress = "";
  final client = WalletUtil.getWeb3Client(true);
  Map3NodeInformationEntity _map3nodeInformationEntity;

  NodeApi _nodeApi = NodeApi();
  NodeProviderEntity _selectProviderEntity;
  Regions _selectedRegion;

  @override
  void onCreated() {
    super.onCreated();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    var _wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet?.wallet;
    _address = _wallet?.getEthAccount()?.address ?? "";
    _nodeId = widget.map3infoEntity?.nodeId ?? "";
    _nodeAddress = widget.map3infoEntity?.address ?? "";

    getContractDetailData();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);

    super.initState();
  }

  void _afterLayout(_) {
    _getMorePosition();
  }

  _getMorePosition() {
    final RenderBox renderBox = _moreKey?.currentContext?.findRenderObject();
    if (renderBox == null) return;

    final positions = renderBox.localToGlobal(Offset(0, 0));
    _moreOffsetLeft = positions.dx - _moreSizeWidth * 0.75;
    _moreOffsetTop = positions.dy + 18 * 2.0 + 10;
    //print("positions of more:$positions, left:$_moreOffsetLeft, top:$_moreOffsetTop");
  }

//  left: 246,
//  top: 76,

  @override
  void dispose() {
    print("[detail] dispose");

    _loadDataBloc.close();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_isTransferring,
      child: Scaffold(
        backgroundColor: DefaultColors.colorf5f5f5,
        appBar: BaseAppBar(
          baseTitle: S.of(context).node_contract_detail,
          actions: <Widget>[
            InkWell(
              onTap: () {
                _showMoreAlertView();
              },
              borderRadius: BorderRadius.circular(60),
              child: Padding(
                padding: EdgeInsets.only(left: 20, right: 35),
                child: Icon(
                  Icons.add,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
        body: _pageWidget(context),
      ),
    );
  }

  Widget _pageWidget(BuildContext context) {
    if (_currentState != null || _map3infoEntity == null) {
      return Scaffold(
        body: AllPageStateContainer(_currentState, () {
          setState(() {
            _currentState = all_page_state.LoadingState();
            getContractDetailData();
          });
        }),
      );
    }

    return Column(
      children: <Widget>[
        Expanded(
          child: LoadDataContainer(
              bloc: _loadDataBloc,
              //enablePullDown: false,
              onRefresh: getContractDetailData,
              onLoadingMore: getJoinMemberMoreData,
              child: CustomScrollView(
                slivers: <Widget>[
                  // 0.通知
                  SliverToBoxAdapter(child: _topNextEpisodeNotifyWidget()),

                  // 1.合约介绍信息
                  SliverToBoxAdapter(
                    child: _map3NodeInfoItem(context),
                  ),
                  _spacer(),

                  // 2
                  SliverToBoxAdapter(
                    child: _nodeNextTimesWidget(),
                  ),
                  _spacer(isVisible: _canPreEdit),

                  // 3.合约状态信息
                  // 3.1最近已操作状态通知 + 总参与抵押金额及期望收益
                  SliverToBoxAdapter(child: _contractProfitWidget()),
                  _spacer(),

                  // 3.2服务器
                  SliverToBoxAdapter(child: _nodeServerWidget()),
                  _spacer(),

                  SliverToBoxAdapter(child: _remortgageWidget()),

                  SliverToBoxAdapter(child: _lineSpacer()),
                  _spacer(),

                  // 3.2合约进度状态
                  SliverToBoxAdapter(child: _contractProgressWidget()),
                  _spacer(),

                  // 4.参与人员列表信息
                  SliverToBoxAdapter(
                    child: Material(
                      color: Colors.white,
                      child: NodeJoinMemberWidget(
                        _nodeId,
                        "",
                        "",
                        "",
                        isShowInviteItem: false,
                        loadDataBloc: _loadDataBloc,
                      ),
                    ),
                  ),
                  _spacer(),

                  // 5.合约流水信息
                  SliverToBoxAdapter(child: _delegateRecordHeaderWidget()),

                  _delegateRecordList.isNotEmpty
                      ? SliverList(
                          delegate: SliverChildBuilderDelegate((context, index) {
                          return _delegateRecordItemWidget(_delegateRecordList[index]);
                        }, childCount: _delegateRecordList.length))
                      : emptyListWidget(title: "节点记录为空"),
                ],
              )),
        ),
        _bottomBtnBarWidget(),
      ],
    );
  }

  // todo: bar
  _showMoreAlertView() {
    return Navigator.push(
      context,
      PopRoute(
        child: Popup(
          child: BubbleWidget(_moreSizeWidth, 92.0, Colors.white, BubbleArrowDirection.top,
              length: 50,
              innerPadding: 0.0,
              child: Container(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 0),
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (subContext, index) {
                    var title = "";
                    if (index == 2) {
                      title = "裂变";
                    } else if (index == 0) {
                      title = "终止";
                    } else if (index == 1) {
                      title = "分享";
                    }

                    return SizedBox(
                      width: 100,
                      height: index == 0 ? 44 : 36,
                      child: FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();

                          if (_isNoWallet) {
                            _pushWalletManagerAction();
                            return;
                          }

                          if (index == 2) {
                            Application.router.navigateTo(context, Routes.map3node_divide_page);
                          } else if (index == 0) {
                            if (widget.map3infoEntity != null) {
                              Application.router.navigateTo(
                                context,
                                Routes.map3node_exit_page +
                                    '?info=${FluroConvertUtils.object2string(widget.map3infoEntity.toJson())}',
                              );
                            }
                          } else if (index == 1) {
                            Application.router.navigateTo(
                                context,
                                Routes.map3node_share_page +
                                    "?contractNodeItem=${FluroConvertUtils.object2string(widget.map3infoEntity.toJson())}");
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Divider(
                              height: 0.5,
                              color: DefaultColors.colorf2f2f2,
                              indent: 13,
                              endIndent: 13,
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(8, index == 0 ? 12 : 8, 8, 8),
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  itemCount: 2,
                ),
              )),
          left: _moreOffsetLeft,
          top: _moreOffsetTop,
        ),
      ),
    );
  }

  Widget _bottomBtnBarWidget() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          color: Colors.black12,
          offset: Offset(0.0, 0.1), //阴影xy轴偏移量
          blurRadius: 1, //阴影模糊程度
        )
      ]),
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Spacer(),
          ClickOvalButton(
            "撤销抵押",
            () {
              if (_isNoWallet) {
                _pushWalletManagerAction();
                return;
              }

              if (widget.map3infoEntity != null) {
                Application.router.navigateTo(
                  context,
                  Routes.map3node_cancel_page +
                      '?info=${FluroConvertUtils.object2string(widget.map3infoEntity.toJson())}',
                );
              }
            },
            width: 120,
            height: 32,
            fontSize: 14,
            fontColor: DefaultColors.color999,
            btnColor: Colors.transparent,
          ),
          Spacer(),
          ClickOvalButton(
            "抵押",
            _joinContractAction,
            width: 120,
            height: 32,
            fontSize: 14,
          ),
          Spacer(),
        ],
      ),
    );
  }

  Widget _topNextEpisodeNotifyWidget() {
    if (!_isVisibleNotification) return Container();

    var notification = "";
    switch (_map3Status) {
      case Map3InfoStatus.CONTRACT_IS_END:
        // "第二期已经开启，前往查看  >>"
        notification = "节点已到期，将在下个纪元结算……";
        break;

      case Map3InfoStatus.CANCEL_NODE_SUCCESS:
        notification = "节点已终止，抵押金额已返回您的钱包……";
        break;

      case Map3InfoStatus.FUNDRAISING_NO_CANCEL:
        notification = "抵押已满100W，将在下个纪元启动……";
        break;

      default:
        break;
    }

    return Container(
      color: HexColor("#1FB9C7").withOpacity(0.08),
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
                notification,
                style: TextStyle(fontSize: 12, color: HexColor("#333333")),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _map3NodeInfoItem(BuildContext context) {
    if (_map3infoEntity == null) return Container();

    var nodeName = _map3infoEntity?.name ?? "***";
    var nodeYearOld = "   节龄: ***天";
    var nodeAddress = "节点地址 ${UiUtil.shortEthAddress(_map3infoEntity?.address ?? "***", limitLength: 6)}";
    var nodeIdPre = "节点号";
    var nodeId = " ${_map3infoEntity.nodeId ?? "***"}";
    var descPre = "节点公告：";
    var desc = (_map3infoEntity?.describe ?? "").isEmpty ? "大家快来参与我的节点吧，收益高高，收益真的很高，" : _map3infoEntity.describe;

    var _map3StatusDesc = "待启动";
    var _map3StatusColor = HexColor("#228BA1");
    switch (_map3Status) {
      case Map3InfoStatus.MAP:
      case Map3InfoStatus.CREATE_SUBMIT_ING:
        _map3StatusDesc = "待启动";
        _map3StatusColor = HexColor("#228BA1");
        break;

      case Map3InfoStatus.CREATE_FAIL:
        _map3StatusDesc = "启动失败";
        _map3StatusColor = HexColor("#FF4C3B");
        break;

      case Map3InfoStatus.CONTRACT_HAS_STARTED:
        _map3StatusDesc = "启动中";
        _map3StatusColor = HexColor("#228BA1");
        break;

      case Map3InfoStatus.CONTRACT_IS_END:
        _map3StatusDesc = "已到期";
        _map3StatusColor = HexColor("#FF4C3B");
        break;

      case Map3InfoStatus.CANCEL_NODE_SUCCESS:
        _map3StatusDesc = "已终止";
        _map3StatusColor = HexColor("#FF4C3B");
        break;

      case Map3InfoStatus.FUNDRAISING_CANCEL_SUBMIT:
        _map3StatusDesc = "撤销中";
        _map3StatusColor = HexColor("#228BA1");
        break;

      default:
        _map3StatusDesc = "映射中";
        _map3StatusColor = HexColor("#228BA1");
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16, top: 16, bottom: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 42,
                  height: 42,
                  child: walletHeaderWidget(
                    _map3infoEntity.name,
                    isShowShape: false,
                    address: _map3infoEntity.address,
                    isCircle: false,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text.rich(TextSpan(children: [
                        TextSpan(text: nodeName, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        TextSpan(text: nodeYearOld, style: TextStyle(fontSize: 13, color: HexColor("#333333"))),
                      ])),
                      Container(
                        height: 4,
                      ),
                      Text(nodeAddress, style: TextStyles.textC9b9b9bS12),
                    ],
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(_map3StatusDesc, style: TextStyle(color: _map3StatusColor, fontSize: 12)),
                      Container(
                        height: 4,
                      ),
                      Text.rich(TextSpan(children: [
                        TextSpan(
                            text: nodeIdPre,
                            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: HexColor("#333333"))),
                        TextSpan(
                            text: nodeId,
                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: HexColor("#333333"))),
                      ])),
                    ],
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        descPre,
                        style: TextStyle(fontSize: 12, color: HexColor("#999999")),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Text(
                            desc,
                            maxLines: 3,
                            textAlign: TextAlign.justify,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13, color: HexColor("#333333")),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Visibility(
                    visible: false,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: InkWell(
                        //color: HexColor("#FF15B2D2"),
                        //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        onTap: () {
                          var encodeEntity = FluroConvertUtils.object2string(_map3infoEntity.toJson());
                          Application.router.navigateTo(context, Routes.map3node_edit_page + "?entity=$encodeEntity");
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Spacer(),
                            Text("编辑节点", style: TextStyle(fontSize: 14, color: HexColor("#1F81FF"))),
                          ],
                        ),
                        //style: TextStyles.textC906b00S13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nodeNextTimesWidget() {
    if (!_canPreEdit) return Container();

    // todo
    var haveEdit = false;
    var newFeeRate = "10%";
    bool autoRenew = false;

    var lastFeeRate = FormatUtil.formatPercent(double.parse(widget.map3infoEntity.getFeeRate()));
    var feeRate = haveEdit?newFeeRate:lastFeeRate;
    var statusDesc = autoRenew?"已开启":"未开启";
    var editDateLimit = "（请在纪元${_map3infoEntity.startBlock} - 纪元${_map3infoEntity.endBlock}之前修改）";

    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 12, bottom: 20),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text.rich(TextSpan(children: [
                  TextSpan(text: "下期预设", style: TextStyle(fontSize: 16, color: HexColor("#333333"))),
                  TextSpan(text: editDateLimit, style: TextStyle(fontSize: 12, color: HexColor("#999999"))),
                ])),
                Spacer(),
                SizedBox(
                  height: 30,
                  child: InkWell(
                    onTap: () {
                      if (haveEdit) return;

                      Application.router.navigateTo(
                          context,
                          Routes.map3node_pre_edit_page +
                              "?info=${FluroConvertUtils.object2string(_map3infoEntity.toJson())}");
                    },
                    child: Center(
                        child: Text(
                      "修改",
                      style: TextStyle(
                        fontSize: 14,
                        color: haveEdit ? HexColor("#999999") : HexColor("#1F81FF"),
                      ),
                    )),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "自动续期",
                      style: TextStyle(
                        color: HexColor("#999999"),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      statusDesc,
                      style: TextStyle(
                        color: HexColor("#333333"),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "管理费",
                      style: TextStyle(
                        color: HexColor("#999999"),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      feeRate,
                      style: TextStyle(
                        color: HexColor("#333333"),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _remortgageWidget() {
    Widget _item(String title, String detail) {
      return Text.rich(TextSpan(children: [
        TextSpan(
            text: title, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: HexColor("#999999"))),
        TextSpan(text: detail, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: HexColor("#333333"))),
      ]));
    }

    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 12, bottom: 20),
        child: Container(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text.rich(TextSpan(children: [
                    TextSpan(
                        text: "复投Atlas共识节点",
                        style: TextStyle(
                          fontSize: 16,
                          color: HexColor("#333333"),
                        )),
                  ])),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: HexColor("#F8F8F8"),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                    child: Column(
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              width: 42,
                              height: 42,
                              child: walletHeaderWidget(
                                "item.name",
                                isShowShape: false,
                                address: "0xkkkkkkkk",
                                isCircle: false,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text.rich(TextSpan(children: [
                                    TextSpan(text: "山哥", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                  ])),
                                  Container(
                                    height: 4,
                                  ),
                                  _item("节点排名：", "2"),
                                ],
                              ),
                            ),
                            Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text("2020/12/12 12:12", style: TextStyle(color: HexColor("#9B9B9B"), fontSize: 12)),
                                Container(
                                  height: 4,
                                ),
                                Container(
                                  color: HexColor("#E3FAFB"),
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: Text("出块节点",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500, fontSize: 12, color: HexColor("#333333"))),
                                ),
                              ],
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 18),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: _item("预期收益：", "12%"),
                              ),
                              Expanded(
                                child: _item("总抵押：", "11,490,490"),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: _item("管理费：", "9%"),
                              ),
                              Expanded(
                                child: _item("签名率：", "98%"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nodeServerWidget() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 12, bottom: 20),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text.rich(TextSpan(children: [
                  TextSpan(text: "节点服务", style: TextStyle(fontSize: 16, color: HexColor("#333333"))),
                ])),
                Spacer(),
                SizedBox(
                  height: 30,
                  child: InkWell(
                    onTap: _pushNodeInfoAction,
                    child: Center(child: Text("访问节点", style: TextStyle(fontSize: 14, color: HexColor("#1F81FF")))),
                    //style: TextStyles.textC906b00S13),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Container(
                        height: 100,
                        child:
                            Map3NodesWidget('[{\"name\":\"${_map3infoEntity.name}\",\"value\":[151.2002,-33.8591]}]'),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [0, 1].map((index) {
                          var titles = ["设备", "位置"];
                          var details = ["阿里云机器", "中国香港"];

                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    titles[index],
                                    style: TextStyle(
                                      color: HexColor("#92979A"),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    details[index],
                                    style: TextStyle(
                                      color: HexColor("#333333"),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _contractProfitWidget() {
    /*
    var amount = _contractDetailItem?.amountDelegation ?? "0";

    var total = double.parse(_contractDetailItem?.expectedYield ?? "0") + double.parse(amount);
    var expectedYield = FormatUtil.amountToString(total.toString());
    var commission = FormatUtil.amountToString(_contractDetailItem?.commission ?? "0");

    var withdrawn = FormatUtil.amountToString(_contractDetailItem?.withdrawn ?? "0") + "HYN";
    var managerTip = Map3NodeUtil.managerTip(_contractNodeItem.contract, double.parse(amount), isOwner: _isOwner);
    var endProfit = Map3NodeUtil.getEndProfit(_contractNodeItem.contract, double.parse(amount));
  */

    var totalDelegation = FormatUtil.stringFormatNum(ConvertTokenUnit.weiToEther(
        weiBigInt: BigInt.parse(
      widget.map3infoEntity?.staking ?? "0",
    )).toString());
    var feeRate = FormatUtil.formatPercent(double.parse(widget.map3infoEntity.getFeeRate()));

    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 18, top: 16),
                child: Text("节点金额", style: TextStyle(fontSize: 16, color: HexColor("#333333"))),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      totalDelegation,
                      style: TextStyle(fontSize: 22, color: HexColor("#228BA1"), fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      "总抵押",
                      style: TextStyle(fontSize: 14, color: HexColor("#999999"), fontWeight: FontWeight.normal),
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 60,
              ),
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      "100,000",
                      style: TextStyle(fontSize: 22, color: HexColor("#BF8D2A"), fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      "我的奖励",
                      style: TextStyle(fontSize: 14, color: HexColor("#999999"), fontWeight: FontWeight.normal),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16, top: 32, left: 16, right: 16),
            child: profitListBigWidget(
              [
                {"管理费": "$feeRate"},
                {"我的抵押": "110，000"},
                {"总奖励": "800，000"},
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contractProgressWidget() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
            child: Text("节点进度", style: TextStyle(fontSize: 16, color: HexColor("#333333"))),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 16, 8),
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
                  TextSpan(text: _contractStateDesc, style: TextStyle(fontSize: 14, color: _stateColor)),
                ])),
                Spacer(),
                Text(
                  S.of(context).launcher_time_left(FormatUtil.timeStringSimple(context, 0)),
                  style: TextStyles.textC999S14,
                ),
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
    var titles = [
      S.of(context).create_time,
      S.of(context).launch_success,
      "到期时间",
    ];
    var subtitles = [
      _map3infoEntity.startBlock,
      _map3infoEntity.startBlock, // todo
      _map3infoEntity.endBlock,
    ];
    var progressHints = [
      "",
      S.of(context).n_day(90.toString()),
      "",
    ];

    //print('[detail] _currentStep:$_currentStep， _currentStepProgress：${_currentStepProgress}');
    return CustomStepper(
      tickColor: _stateColor,
      tickText: _contractStateDetail,
      currentStepProgress: _currentStepProgress,
      currentStep: _currentStep,
      steps: titles.map(
        (title) {
          var index = titles.indexOf(title);
          //var subtitle = FormatUtil.formatDate(subtitles[index]);
          var subtitle = "";
          var date = progressHints[index];
          var textColor = _currentStep != index ? HexColor("#A7A7A7") : HexColor('#1FB9C7');

          return CustomStep(
            title: Text(
              title,
              style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.normal),
            ),
            progressHint: Text(
              date,
              style: TextStyle(fontSize: 12, color: HexColor("#4B4B4B"), fontWeight: FontWeight.normal),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: textColor, fontWeight: FontWeight.normal),
            ),
            content: Container(),
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
//      color: DefaultColors.colorf5f5f5,
    );
  }

  Widget _spacer({bool isVisible = true}) {
    return SliverToBoxAdapter(
      child: Visibility(
        visible: isVisible,
        child: Container(
          height: 10,
//        color: DefaultColors.colorf5f5f5,
        ),
      ),
    );
  }

  Widget _delegateRecordHeaderWidget() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
        child: Row(
          children: <Widget>[
            Text(S.of(context).account_flow, style: TextStyle(fontSize: 16, color: HexColor("#333333"))),
          ],
        ),
      ),
    );
  }

  Widget _delegateRecordItemWidget(Map3TxLogEntity item) {
    var isPending = item.status == 0 || item.status == 1;
    // type 0一般转账；1创建atlas节点；2修改atlas节点/重新激活Atlas；3参与atlas节点抵押；4撤销atlas节点抵押；5领取atlas奖励；6创建map3节点；7编辑map3节点；8撤销map3节点；9参与map3抵押；10撤销map3抵押；11领取map3奖励；12续期map3;13裂变map3节点；

    var amountValue = ConvertTokenUnit.weiToEther(weiBigInt: BigInt.parse(item?.dataDecoded?.amount ?? "0")).toDouble();
    var amount = FormatUtil.formatPrice(amountValue);
    var detail = "";
    switch (item.type) {
      case 0:
        detail = ConvertTokenUnit.weiToEther(weiBigInt: BigInt.parse(item?.dataDecoded?.amount ?? "0")).toString();
        break;

      case 1:
        detail = "创建atlas节点";
        break;

      case 2:
        detail = "修改atlas节点/重新激活Atlas";
        break;

      case 3:
        detail = "参与atlas节点抵押";
        break;

      case 4:
        detail = "撤销atlas节点抵押";
        break;

      case 5:
        detail = "领取atlas奖励";
        break;

      case 6:
        // detail = "创建Map3节点";
        detail = "创建Map3节点" + " " + amount;
        break;

      case 7:
        detail = "编辑Map3节点";
        break;

      case 8:
        detail = "终止Map3节点";
        break;

      case 9:
        detail = "微抵押" + " " + amount;
        break;

      case 10:
        detail = "取消Map3抵押" + " " + amount;
        break;

      case 11:
        detail = "提取奖励" + " " + amount;
        break;

      case 12:
        detail = "续期map3";
        break;

      case 13:
        detail = "裂变map3节点";
        break;
    }

    return Container(
      color: Colors.white,
      child: Stack(
        children: <Widget>[
          InkWell(
            onTap: () {
              _pushTransactionDetailAction(item);
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
                    child: walletHeaderWidget(item.name, address: item.from),
                  ),
                  Flexible(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              RichText(
                                text: TextSpan(
                                  text: item.name,
                                  style:
                                      TextStyle(fontSize: 14, color: HexColor("#000000"), fontWeight: FontWeight.w500),
                                ),
                              ),
                              Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: Text(
                                      isPending ? "*" : detail,
                                      style: TextStyle(
                                          fontSize: 14, color: HexColor("#333333"), fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  _billStateWidget(item)
                                ],
                              ),
                            ],
                          ),
                          Container(
                            height: 8.0,
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                shortBlockChainAddress(" ${item.from}", limitCharsLength: 8),
                                style: TextStyle(fontSize: 12, color: HexColor("#999999")),
                              ),
                              Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text(FormatUtil.formatDateStr(item.createdAt),
                                      style: TextStyle(fontSize: 10, color: HexColor("#999999"))),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Widget _billStateWidget(Map3TxLogEntity item) {
    // status 自定义： 1.pending；2.wait receipt; 3success; 4.fail;5.drop fail see TransactionXXX

    switch (item.status) {
      case 1:
      case 2:
        return Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [HexColor("#E0B102"), HexColor("#F3D35D")],
                  begin: FractionalOffset(1, 0.5),
                  end: FractionalOffset(0, 0.5)),
              borderRadius: BorderRadius.all(Radius.circular(12.0))),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
            child: Text(
              "进行中",
              style: TextStyle(fontSize: 6, color: HexColor("#FFFFFF"), fontWeight: FontWeight.normal),
            ),
          ),
        );
        break;

      case 4:
      case 5:
        return Container(
          decoration: BoxDecoration(color: HexColor("#FF4C3B"), borderRadius: BorderRadius.all(Radius.circular(12.0))),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
            child: Text(
              "失败了",
              style: TextStyle(fontSize: 6, color: HexColor("#FFFFFF"), fontWeight: FontWeight.normal),
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
              "已完成",
              style: TextStyle(fontSize: 6, color: HexColor("#999999"), fontWeight: FontWeight.normal),
            ),
          ),
        );

        break;
    }
  }

  Future getJoinMemberMoreData() async {
    try {
      _currentPage++;

      List<Map3TxLogEntity> tempMemberList = await _atlasApi.getMap3StakingLogList(_nodeId, page: _currentPage);

      if (tempMemberList.length > 0) {
        _delegateRecordList.addAll(tempMemberList);
        _loadDataBloc.add(LoadingMoreSuccessEvent());
      } else {
        _loadDataBloc.add(LoadMoreEmptyEvent());
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadDataBloc.add(LoadMoreFailEvent());
        });
      }
    }
  }

  // todo: test_detail
  Future getContractDetailData() async {
    try {
      _map3infoEntity = await _atlasApi.getMap3Info(_address, _nodeId);

      if (_map3infoEntity != null && _map3infoEntity.address.isNotEmpty) {
        List<Map3TxLogEntity> tempMemberList = await _atlasApi.getMap3StakingLogList(_nodeAddress);
        _delegateRecordList = tempMemberList;
      }

      _map3Status = Map3InfoStatus.values[_map3infoEntity.status];

      var map3Address = EthereumAddress.fromHex(widget.map3infoEntity.address);
      _map3nodeInformationEntity = await client.getMap3NodeInformation(map3Address);

      var providerList = await _nodeApi.getNodeProviderList();
      if (providerList.isNotEmpty) {
        _selectProviderEntity = providerList[0];

        for (var region in _selectProviderEntity.regions) {
          if (region.id == _map3infoEntity.region) {
            _selectedRegion = region;
            break;
          }
        }
      }

      // 3.
      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _currentState = null;
            _loadDataBloc.add(RefreshSuccessEvent());

            _isTransferring = false;
          });
        }
      });
    } catch (e) {
      logger.e(e);
      LogUtil.toastException(e);

      if (mounted) {
        setState(() {
          _loadDataBloc.add(RefreshFailEvent());
          _visible = false;
          _currentState = all_page_state.LoadFailState();

          _isTransferring = false;
        });
      }
    }
  }

  void _pushNodeInfoAction() {
    if (_map3infoEntity != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WebViewContainer(
                    initUrl: "https://www.map3.network",
                    title: "",
                  )));
    }
  }

  void _pushTransactionDetailAction(Map3TxLogEntity item) {
    TransactionDetailVo transactionDetail = TransactionDetailVo(
      id: item.id,
      contractAddress: item.contractAddress,
      state: 1,
      //1 success, 0 pending, -1 failed
      amount: ConvertTokenUnit.weiToEther(weiBigInt: BigInt.parse(item.dataDecoded.amount)).toDouble(),
      symbol: "HYN",
      fromAddress: item.from,
      toAddress: item.to,
      time: item.timestamp,
      nonce: item.nonce.toString(),
      gasPrice: item.gasPrice,
      gas: item.gasLimit.toString(),
      gasUsed: item.gasUsed.toString(),
      describe: item.dataDecoded.description.details,
      data: item.data,
      dataDecoded: item.dataDecoded.toJson(),
      blockHash: item.blockHash,
      blockNum: item.blockNum,
      epoch: item.epoch,
      transactionIndex: item.transactionIndex,
      type: item.type, //1、转出 2、转入
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WalletShowAccountInfoPage(transactionDetail)),
    );
  }

  void _pushWalletManagerAction() {
    Application.router.navigateTo(
        context, Routes.map3node_create_wallet + "?pageType=${Map3NodeCreateWalletPage.CREATE_WALLET_PAGE_TYPE_JOIN}");
  }

  void _joinContractAction() async {
    if (_isNoWallet) {
      _pushWalletManagerAction();
      return;
    }

    if (mounted) {
      setState(() {
        _isTransferring = true;
      });
    }

    if (_map3infoEntity != null) {
      var entryRouteName = Uri.encodeComponent(Routes.map3node_contract_detail_page);
      await Application.router.navigateTo(
          context,
          Routes.map3node_join_contract_page +
              "?entryRouteName=$entryRouteName&entityInfo=${FluroConvertUtils.object2string(_map3infoEntity.toJson())}");
      _nextAction();
    }
  }

  void _nextAction() {
    final result = ModalRoute.of(context).settings?.arguments;

    print("[detai] _next action, result:$result");

    if (result != null && result is Map && result["result"] is bool) {
      getContractDetailData();
    } else {
      if (mounted) {
        setState(() {
          _isTransferring = false;
        });
      }
    }
  }
}
