import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/load_data_bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/atlas/atlas_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_introduce_entity.dart';
import 'package:titan/src/pages/atlas_map/event/node_event.dart';
import 'package:titan/src/pages/atlas_map/widget/custom_stepper.dart';
import 'package:titan/src/pages/atlas_map/widget/node_join_member_widget.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/pages/node/model/map3_node_util.dart';
import 'package:titan/src/pages/node/model/node_provider_entity.dart';
import 'package:titan/src/pages/wallet/model/hyn_transfer_history.dart';
import 'package:titan/src/pages/webview/webview.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart' as all_page_state;
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/map3_nodes_widget.dart';
import 'package:web3dart/web3dart.dart';
import '../../../../env.dart';
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
  LoadDataBloc _loadDataBloc = LoadDataBloc();
  all_page_state.AllPageState _currentState = all_page_state.LoadingState();

  AtlasApi _atlasApi = AtlasApi();
  NodeApi _nodeApi = NodeApi();
  final client = WalletUtil.getWeb3Client(true);

  // 0映射中;1 创建提交中；2创建失败; 3募资中,没在撤销节点;4募资中，撤销节点提交中，如果撤销失败将回到3状态；5撤销节点成功；6合约已启动；7合约期满终止；
  Map3InfoStatus _map3Status = Map3InfoStatus.CREATE_SUBMIT_ING;
  Map3InfoEntity _map3infoEntity;
  Map3NodeInformationEntity _map3nodeInformationEntity;

  Microdelegations _microDelegationsCreator;
  Microdelegations _microDelegationsJoiner;

  int _currentPage = 0;
  List<HynTransferHistory> _delegateRecordList = [];

  var _address = "";
  var _nodeId = "";
  var _nodeAddress = "";

  NodeProviderEntity _selectProviderEntity;
  Regions _selectedRegion;
  var _haveShowedAlertView = false;
  Map3IntroduceEntity _map3introduceEntity;

  get _isRunning => _map3Status == Map3InfoStatus.CONTRACT_HAS_STARTED;
  get _isPending => _map3Status == Map3InfoStatus.FUNDRAISING_NO_CANCEL;

  get statusCreator => _microDelegationsCreator?.renewal?.status ?? 0;
  get statusJoiner => _microDelegationsJoiner?.renewal?.status ?? 0;

  get isHiddenRenew => (statusCreator == 1 && _isDelegator && !_isCreator);

  get _notifyMessage {
    switch (_map3Status) {
      case Map3InfoStatus.FUNDRAISING_NO_CANCEL:
        if (_isFullDelegate) {
          var startMinValue = FormatUtil.formatTenThousandNoUnit(startMin.toString()) + S.of(context).ten_thousand;
          return "抵押已满$startMinValue，将在下个纪元启动……";
        } else {
          if (_isOver7Epoch) {
            return '该节点超过7纪元未满足启动所需，已停止新抵押。请节点主终止节点，已有抵押将全部返还抵押者';
          }
        }
        break;

      case Map3InfoStatus.CONTRACT_IS_END:
        return "节点已到期，将在下个纪元结算……";
        break;

      case Map3InfoStatus.CONTRACT_HAS_STARTED:
        if (_isDelegator) {
          if (_isCreator) {
            /*
            * 没有设置过，开始提示
            * */
            var periodEpoch14 = _releaseEpoch - 14 + 1;
            //var periodEpoch7 = _releaseEpoch - 7;

            var leftEpoch = periodEpoch14 - _currentEpoch;

            if (statusCreator == 0 && leftEpoch > 0) {
              return "距离可以设置下期续约还有$leftEpoch纪元";
            }
          } else {
            /*
            * 没有设置过，开始提示
            * */
            //var periodEpoch14 = _releaseEpoch - 14 + 1;
            var periodEpoch7 = _releaseEpoch - 7 + 1;

            var leftEpoch = periodEpoch7 - _currentEpoch;

            if (statusJoiner == 0 && leftEpoch > 0) {
              if (statusCreator == 0) {
                return "距离可以设置下期续约还有$leftEpoch纪元";
              } else if (statusCreator == 1) {
                return _closeRenewDefaultText;
              }
            }
          }
        }

        break;

      default:
        break;
    }

    return null;
  }

  get _visibleBottomBar => ((_isRunning && _isDelegator) || (_isPending)); // 提取奖励 or 参与抵押

  get _isNoWallet => _address?.isEmpty ?? true;

  get _endRemainEpoch => (_releaseEpoch ?? 0) - (_currentEpoch ?? 0) + 1;

  var _currentEpoch = 0;
  // 到期纪元
  get _releaseEpoch => double.parse(_map3nodeInformationEntity?.map3Node?.releaseEpoch ?? "0").toInt();
  get _activeEpoch => _map3nodeInformationEntity?.map3Node?.activationEpoch ?? 0;
  get _pendingEpoch => _map3nodeInformationEntity?.map3Node?.pendingEpoch ?? 0;
  get _pendingUnlockEpoch =>
      double.tryParse(_microDelegationsCreator?.pendingDelegation?.unlockedEpoch ?? '0')?.toInt() ?? 0;

  get _closeRenewDefaultText => '节点主已经停止续约，该节点到期后自动终止';

  /*
  tips:
  “创建者“显示编辑： 倒数14个纪元到倒数7纪元 且 状态为未设置  开始显示。
  如果已经设置了关闭，就显示【关闭】，其他情况显示【已开启】

  ”抵押者“显示编辑： 倒数7纪元后  且 （“创建者”设置为【已开启】或【未设置】） 且  自己状态为未设置，    或“创建者”已设置为【已开启】 且 自己状态为未设置，  开始显示。
  如果已经设置了关闭，就显示【关闭】，其他情况显示【已开启】
  */
  get _canEditNextPeriod {
    // 周期
    var periodEpoch14 = (_releaseEpoch - 14) > 0 ? _releaseEpoch - 14 : 0;
    var periodEpoch7 = _releaseEpoch - 7 > 0 ? _releaseEpoch - 7 : 0;

    //  创建者
    if (_isCreator) {
      var isInActionPeriodCreator = (_currentEpoch > periodEpoch14) && (_currentEpoch <= periodEpoch7);
      LogUtil.printMessage("【isCreator】statusCreator:$statusCreator, isInActionPeriodCreator:$isInActionPeriodCreator");

      if (isInActionPeriodCreator && statusCreator == 0) {
        //在可编辑时间内，且未修改过
        return true;
      }
      return false;
    }

    // 参与者
    var isInActionPeriodJoiner = _currentEpoch > periodEpoch7 && _currentEpoch <= _releaseEpoch;
    LogUtil.printMessage("[statusJoiner] statusJoiner:$statusJoiner, statusCreator:$statusCreator");

    if (_isDelegator) {
      var isCreatorSetOpen = statusCreator == 2; //创建人已开启
      var isCreatorSetClose = statusCreator == 1; //创建人已开启

      if ((statusJoiner == 0 && isCreatorSetOpen) ||
          (statusJoiner == 0 && isInActionPeriodJoiner && !isCreatorSetClose)) {
        return true;
      }
    }

    return false;
  }

  // 0.募集中
  // 1.纪元已经过7天；
  get _canExit => _isCreator && _isPending && _isOver7Epoch;

  get _isOver7Epoch => (_currentEpoch - _pendingUnlockEpoch) > 0 && (_pendingEpoch > 0) && (_currentEpoch > 0);

  get _canEditNode =>
      _isCreator &&
      (_map3Status != Map3InfoStatus.CANCEL_NODE_SUCCESS || _map3Status != Map3InfoStatus.FUNDRAISING_CANCEL_SUBMIT);

  /*
  角色分析：
  1.判断是否参与抵押
  Yes：用户（包括：创建人，参与者）
  NO：未抵押，即：游客

  2.针对角色开放不同权限
  a: 创建人
  b: 参与人
  c: 游客
  *
   */

  get _isCreator => _map3infoEntity?.isCreator() ?? false;

  get _isDelegator => _map3infoEntity?.mine != null;

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

  //最小启动所需
  get startMin => double.tryParse(_map3introduceEntity?.startMin ?? "0") ?? 0;

  //当前抵押量
  get staking => double.tryParse(_map3infoEntity?.getStaking() ?? "0") ?? 0;

  get _isFullDelegate => (startMin > 0) && (staking > 0) && (staking >= startMin);

  get _currentStepProgress {
    if (_map3Status == null) return 0.0;

    double value = 0.0;

    switch (_map3Status) {
      case Map3InfoStatus.FUNDRAISING_NO_CANCEL:
        var left = staking / startMin;

        if (_isFullDelegate) {
          value = 0.95;
        } else {
          if (left <= 0.1) {
            value = 0.1;
          } else if (left > 0.1 && left < 1.0) {
            value = left;
          } else {
            value = 0.95;
          }
        }
        break;

      case Map3InfoStatus.MAP:
      case Map3InfoStatus.CREATE_SUBMIT_ING:
      case Map3InfoStatus.FUNDRAISING_CANCEL_SUBMIT:
      case Map3InfoStatus.CANCEL_NODE_SUCCESS:
        value = 0.5;
        break;

      case Map3InfoStatus.CONTRACT_HAS_STARTED:
        value = 0.5;

        var left = (_currentEpoch - _activeEpoch).toDouble() / (_releaseEpoch - _activeEpoch).toDouble();

        if (left <= 0.1) {
          value = 0.1;
        } else if (left > 0.1 && left < 1.0) {
          value = left;
        } else {
          value = 1.0;
        }

        break;

      case Map3InfoStatus.CONTRACT_IS_END:
        value = 0.5;
        break;

      default:
        break;
    }

    return value;
  }

  get _stateDescText => Map3NodeUtil.stateDescText(_map3Status);

  get _statusColor => Map3NodeUtil.statusColor(_map3Status);

  get _contractStateDetail {
    if (_map3Status == null) {
      return S.of(context).wait_block_chain_verification;
    }

    var _map3StatusDesc = "";

    switch (_map3Status) {
      case Map3InfoStatus.MAP:
        //case Map3InfoStatus.CREATE_SUBMIT_ING:
        _map3StatusDesc = "";

        break;

      case Map3InfoStatus.CREATE_FAIL:
        _map3StatusDesc = "";

        break;

      case Map3InfoStatus.CONTRACT_HAS_STARTED:
        var _endRemainEpochValue = _endRemainEpoch.toInt();
        if (_endRemainEpochValue > 0) {
          _map3StatusDesc = "距离到期还有$_endRemainEpochValue纪元";
        } else {
          _map3StatusDesc = "距离到期仅剩1个纪元";
        }

        break;

      case Map3InfoStatus.CONTRACT_IS_END:
        _map3StatusDesc = "";

        break;

      case Map3InfoStatus.CANCEL_NODE_SUCCESS:
        _map3StatusDesc = "";

        break;

      case Map3InfoStatus.FUNDRAISING_CANCEL_SUBMIT:
        // _map3StatusDesc = "撤销请求已提交";
        _map3StatusDesc = "";

        break;

      case Map3InfoStatus.FUNDRAISING_NO_CANCEL:
      case Map3InfoStatus.CREATE_SUBMIT_ING:
        if (_isFullDelegate) {
          _map3StatusDesc = "抵押已满，准备启动";
        } else {
          var remain = startMin - staking;
          var remainDelegation = FormatUtil.formatPrice(remain);
          _map3StatusDesc = S.of(context).remain + remainDelegation + "启动";
        }

        break;

      default:
        _map3StatusDesc = "";

        break;
    }

    return _map3StatusDesc;
  }

  //var _moreKey = GlobalKey(debugLabel: '__more_global__');
  // double _moreSizeHeight = 18;
  // double _moreOffsetLeft = 246;
  // double _moreOffsetTop = 76;
  //double _moreSizeWidth = 100;

  @override
  void initState() {
    //WidgetsBinding.instance.addPostFrameCallback(_afterLayout);

    _setupData();

    super.initState();
  }

  @override
  void onCreated() {
    super.onCreated();

    _loadDetailData();
  }

  _setupData() async {
    _map3infoEntity = widget.map3infoEntity;

    _nodeId = _map3infoEntity?.nodeId ?? "";
    _nodeAddress = _map3infoEntity?.address ?? "";
    _map3Status = Map3InfoStatus.values[_map3infoEntity?.status ?? 1];

    var _wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet?.wallet;
    _address = _wallet?.getEthAccount()?.address ?? "";

    _map3introduceEntity = await AtlasApi.getIntroduceEntity();
  }

  _showEditPreNextAlert() {
    print("[object] --> _haveShowedAlertView:$_haveShowedAlertView");

    if (_haveShowedAlertView) {
      return;
    } else {
      UiUtil.showAlertView(
        context,
        title: S.of(context).important_hint,
        actions: [
          ClickOvalButton(
            "马上设置",
            () {
              setState(() {
                _haveShowedAlertView = true;
              });
              Navigator.pop(context);

              _preNextAction();
            },
            width: 160,
            height: 38,
            fontSize: 16,
          ),
        ],
        content:
            _isCreator ? '请你设置下期预设是否自动续约。如果过期不设置，节点将在到期后自动续约' : '节点主已经设置下期自动续约，请你设置下期是否跟随续约。如果过期不设置，节点将在到期后自动跟随续约。',
      );
    }
  }

  /*
  void _afterLayout(_) {
    _getMorePosition();
  }

  _getMorePosition() {
    final RenderBox renderBox = _moreKey?.currentContext?.findRenderObject();
    if (renderBox == null) return;

    //final positions = renderBox.localToGlobal(Offset(0, 0));
    //_moreOffsetLeft = positions.dx - _moreSizeWidth * 0.75;
    //_moreOffsetTop = positions.dy + 18 * 2.0 + 10;
    //LogUtil.printMessage("positions of more:$positions, left:$_moreOffsetLeft, top:$_moreOffsetTop");
  }

  //  left: 246,
  //  top: 76,
  */

  @override
  void dispose() {
    LogUtil.printMessage("[detail] dispose");

    _loadDataBloc.close();
    super.dispose();
  }

  Widget build(BuildContext context) {
    _currentEpoch = AtlasInheritedModel.of(context).committeeInfo?.epoch ?? 0;
    LogUtil.printMessage("_currentEpoch: $_currentEpoch");

    List<Widget> actions = [];

    Widget shareWidget = IconButton(
      icon: Image.asset(
        "res/drawable/map3_node_share.png",
        width: 15,
        height: 18,
        color: HexColor("#999999"),
      ),
      tooltip: S.of(context).share,
      onPressed: _shareAction,
    );

    if (_canExit) {
      actions = [
        FlatButton(
          onPressed: _exitAction,
          child: Text(
            "终止",
            style: TextStyle(
              color: HexColor("#999999"),
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        shareWidget,
      ];
    } else {
      actions = [
        shareWidget,
      ];
    }
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        backgroundColor: DefaultColors.colorf5f5f5,
        appBar: BaseAppBar(
          baseTitle: S.of(context).node_contract_detail,
          actions: actions,
        ),
        body: _pageWidget(context),
      ),
    );
  }

  /// TODO:Widget
  Widget _pageWidget(BuildContext context) {
    if (_currentState != null || _map3infoEntity == null) {
      return Scaffold(
        body: AllPageStateContainer(_currentState, () {
          setState(() {
            _currentState = all_page_state.LoadingState();
            _loadDetailData();
          });
        }),
      );
    }

    return Column(
      children: <Widget>[
        _topNextEpisodeNotifyWidget(),
        Expanded(
          child: LoadDataContainer(
              bloc: _loadDataBloc,
              //enablePullDown: false,
              enablePullUp: _nodeAddress.isNotEmpty,
              onRefresh: _loadDetailData,
              onLoadingMore: _loadMoreData,
              child: CustomScrollView(
                //physics: AlwaysScrollableScrollPhysics(),
                slivers: <Widget>[
                  // 0.通知
                  //SliverToBoxAdapter(child: _topNextEpisodeNotifyWidget()),

                  // 1.合约介绍信息
                  SliverToBoxAdapter(
                    child: _map3NodeInfoItem(context),
                  ),
                  _spacer(),

                  // 3.合约状态信息
                  // 3.1最近已操作状态通知 + 总参与抵押金额及期望收益
                  SliverToBoxAdapter(child: _contractProfitWidget()),
                  _spacer(),

                  SliverToBoxAdapter(child: _nodeServerWidget()),
                  _spacer(),

                  // 2
                  SliverToBoxAdapter(
                    child: _nodeNextPeriodWidget(),
                  ),
                  _spacer(isVisible: _isRunning),

                  // 3.2服务器
                  SliverToBoxAdapter(child: _reDelegationWidget()),
                  _spacer(isVisible: _isRunning),

                  // 3.2合约进度状态
                  SliverToBoxAdapter(child: _contractProgressWidget()),
                  _spacer(),

                  // 4.参与人员列表信息
                  SliverToBoxAdapter(
                    child: Material(
                      color: Colors.white,
                      child: NodeJoinMemberWidget(
                        nodeId: _nodeId,
                        isShowInviteItem: false,
                        loadDataBloc: _loadDataBloc,
                      ),
                    ),
                  ),
                  _spacer(),

                  // 5.合约流水信息
                  SliverToBoxAdapter(child: _delegateRecordHeaderWidget()),

                  (_delegateRecordList?.isNotEmpty ?? false)
                      ? SliverList(
                          delegate: SliverChildBuilderDelegate((context, index) {
                          return delegateRecordItemWidget(
                            _delegateRecordList[index],
                            map3CreatorAddress: _map3nodeInformationEntity?.map3Node?.operatorAddress ?? "",
                          );
                        }, childCount: _delegateRecordList.length))
                      : emptyListWidget(title: "节点记录为空"),
                ],
              )),
        ),
        _bottomBtnBarWidget(),
      ],
    );
  }

  /*
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

                          if (index == 2) {
                            _divideAction();
                          } else if (index == 0) {
                            _exitAction();
                          } else if (index == 1) {
                            _shareAction();
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
  */

  Widget _bottomBtnBarWidget() {
    LogUtil.printMessage("_invisibleBottomBar:$_visibleBottomBar");

    //get _visibleBottomBar => ((_isRunning && _isDelegator) || (_isPending)); // 提取奖励 or 参与抵押

    var staking0 = (_isDelegator && _isOver7Epoch && _microDelegationsJoiner == null);
    if (!_visibleBottomBar || (!_isDelegator && _isOver7Epoch) || staking0) return Container();

    List<Widget> children = [];

    switch (_map3Status) {
      case Map3InfoStatus.CONTRACT_HAS_STARTED:
        children = <Widget>[
          ClickOvalButton(
            "提取奖励",
            _collectAction,
            width: 160,
            height: 36,
            fontSize: 14,
            //btnColor: HexColor("#FFC900"),
          )
        ];
        break;

      case Map3InfoStatus.FUNDRAISING_NO_CANCEL:
        if (_isOver7Epoch && !_isFullDelegate) {
          if (_isDelegator) {
            if (_isCreator) {
              children = <Widget>[
                ClickOvalButton(
                  "终止节点",
                  _exitAction,
                  width: 160,
                  height: 36,
                  fontSize: 14,
                ),
              ];
            } else {
              children = <Widget>[
                ClickOvalButton(
                  "撤销抵押",
                  _cancelAction,
                  width: 160,
                  height: 36,
                  fontSize: 14,
                ),
              ];
            }
          }
        } else {
          children = <Widget>[
            Spacer(),
            ClickOvalButton(
              "部分撤销",
              _cancelAction,
              width: 120,
              height: 32,
              fontSize: 14,
              fontColor: HexColor("#999999"),
              btnColor: Colors.transparent,
            ),
            Spacer(),
            ClickOvalButton(
              "抵押",
              _joinAction,
              width: 120,
              height: 32,
              fontSize: 14,
            ),
            Spacer(),
          ];
        }
        break;

      default:
        break;
    }

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
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );
  }

  Widget _topNextEpisodeNotifyWidget() {
    var notification = _notifyMessage;
    if (notification == null) {
      return Container();
    }

    var bgColor = (_isRunning || (!_isFullDelegate && _isOver7Epoch))
        ? HexColor("#FF4C3B")
        : HexColor("#1FB9C7").withOpacity(0.08);
    var contentColor = (_isRunning || (!_isFullDelegate && _isOver7Epoch)) ? HexColor("#FFFFFF") : HexColor("#333333");
    return Container(
      color: bgColor,
      padding: const EdgeInsets.fromLTRB(23, 0, 16, 0),
      child: Row(
        children: <Widget>[
          Image.asset(
            "res/drawable/volume.png",
            width: 15,
            height: 14,
            color: contentColor,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text(
                notification,
                style: TextStyle(fontSize: 12, color: contentColor),
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
    var oldYear = double.parse(_map3nodeInformationEntity?.map3Node?.age ?? "0").toInt();
    var oldYearValue = oldYear > 0 ? "节龄：${FormatUtil.formatPrice(oldYear.toDouble())}" : "";

    var nodeAddress =
        "${UiUtil.shortEthAddress(WalletUtil.ethAddressToBech32Address(_map3infoEntity?.address) ?? "***", limitLength: 8)}";
    var nodeIdPre = "节点号 ";

    var nodeId = " ${_map3infoEntity.nodeId ?? "***"}";
    var descPre = "节点公告";
    var desc = (_map3infoEntity?.describe ?? "").isEmpty ?? false
        ? "大家快来参与我的节点吧，人帅靠谱，光干活不说话，奖励稳定，服务周到！"
        : _map3infoEntity.describe;

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
                iconMap3Widget(_map3infoEntity),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Flexible(
                              child: Text(nodeName,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  )),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 8,
                              ),
                              child: Text(oldYearValue,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: HexColor("#999999"),
                                  )),
                            ),
                          ],
                        ),
                        Container(
                          height: 4,
                        ),
                        Text(nodeAddress, style: TextStyles.textC9b9b9bS12),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 18, right: 8.0),
                            child: Container(
                              width: 8,
                              height: 8,
                              //color: Colors.red,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _statusColor,
                                border: Border.all(
                                  color: Map3NodeUtil.statusBorderColor(_map3Status),
                                  width: 1.0,
                                ),
                              ),
                            ),
                          ),
                          Text.rich(
                            TextSpan(children: [
                              TextSpan(
                                text: _stateDescText,
                                style: TextStyle(fontSize: 12, color: _statusColor),
                              ),
                            ]),
                          ),
                        ],
                      ),
                      //Text(_stateDescText, style: TextStyle(color: _statusColor, fontSize: 12)),
                      Container(
                        height: 4,
                      ),
                      Text.rich(TextSpan(children: [
                        TextSpan(
                            text: nodeIdPre,
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                              color: HexColor("#333333"),
                            )),
                        TextSpan(
                            text: nodeId,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: HexColor("#333333"),
                            )),
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
                  if (_map3infoEntity.home.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12, top: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            S.of(context).website,
                            style: TextStyle(fontSize: 12, color: HexColor("#999999")),
                          ),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 8,
                                right: 16,
                              ),
                              child: Text(
                                _map3infoEntity.home ?? '',
                                maxLines: 3,
                                textAlign: TextAlign.justify,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 13, color: HexColor("#333333")),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_map3infoEntity.contact.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            S.of(context).contact,
                            style: TextStyle(fontSize: 12, color: HexColor("#999999")),
                          ),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 8,
                                right: 16,
                              ),
                              child: Text(
                                _map3infoEntity.contact ?? '',
                                maxLines: 3,
                                textAlign: TextAlign.justify,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 13, color: HexColor("#333333")),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        descPre,
                        style: TextStyle(fontSize: 12, color: HexColor("#999999")),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 8,
                            right: 16,
                          ),
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
                    //visible: _canEditNode,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: InkWell(
                        //color: HexColor("#FF15B2D2"),
                        //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        onTap: _editAction,
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

  Widget _nodeNextPeriodWidget() {
    if (!_isRunning) {
      return Container();
    }

    var currentMicroDelegations = _isCreator ? _microDelegationsCreator : _microDelegationsJoiner;
    var status = currentMicroDelegations?.renewal?.status ?? 0;

    var lastFeeRate = FormatUtil.formatPercent(double.parse(_map3infoEntity?.getFeeRate() ?? "0"));
    var rateForNextPeriod = _map3nodeInformationEntity?.map3Node?.commission?.rateForNextPeriod ?? "0";
    var newFeeRate = FormatUtil.formatPercent(double.parse(rateForNextPeriod));

    var statusDesc = "已开启";
    var feeRate = lastFeeRate;
    switch (status) {
      case 0: // 未编辑，默认，开启，取上传rate
        if (_isDelegator) {
          if (_isCreator) {
            //var periodEpoch14 = _releaseEpoch - 14 + 1;
            var periodEpoch7 = _releaseEpoch - 7;

            var isOutActionPeriodCreator = (_currentEpoch > periodEpoch7);

            if (isOutActionPeriodCreator) {
              statusDesc = '设置期已过，将默认续约';
            } else {
              statusDesc = "未设置，过期将默认续约";
            }
          } else {
            //var periodEpoch14 = _releaseEpoch - 14 + 1;
            //var periodEpoch7 = _releaseEpoch - 7 + 1;
            var isOutActionPeriodJoiner = _currentEpoch > _releaseEpoch;

            if (isOutActionPeriodJoiner) {
              statusDesc = '设置期已过，将默认续约';
            } else {
              statusDesc = "未设置，过期将默认续约";
            }
          }
        } else {
          statusDesc = "未参与抵押，不能设置";
        }

        feeRate = lastFeeRate;
        break;

      case 1:
        statusDesc = "停止续约";
        feeRate = newFeeRate;
        break;

      case 2:
        statusDesc = "已开启续约";
        feeRate = newFeeRate;
        break;
    }

    // 周期
    var periodEpoch14 = _releaseEpoch - 14 + 1;
    var periodEpoch7 = _releaseEpoch - 7;

    var editDateLimit = "";

    var statueCreator = (_microDelegationsCreator?.renewal?.status ?? 0);
    var statueJoiner = (_microDelegationsJoiner?.renewal?.status ?? 0);

    if (_isDelegator) {
      if (_isCreator) {
        editDateLimit = "（请在纪元$periodEpoch14 ~ $periodEpoch7内设置）";
        if (statueCreator != 0) {
          editDateLimit = "（设置完成）";
        }
      } else {
        if (statueCreator == 2) {
          editDateLimit = "（请在节点到期前设置）";
        } else if (statueCreator == 1) {
          editDateLimit = '';
        } else {
          if (statueJoiner != 0) {
            editDateLimit = "（设置完成）";
          } else {
            editDateLimit = "（请在纪元${periodEpoch7 + 1} ~ $_releaseEpoch内设置）";
          }
        }
      }
    } else {
      editDateLimit = "";
    }

    if (periodEpoch14 < 0 || periodEpoch7 < 0) {
      editDateLimit = "";
    }

    if (_isDelegator && _canEditNextPeriod) {
      _map3infoEntity.rateForNextPeriod = rateForNextPeriod;
    }

    var isCloseRenew = (statueCreator == 1 && _isDelegator && !_isCreator);

    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 20),
        child: Column(
          children: <Widget>[
            Visibility(
              visible: _isDelegator,
              child: Text(
                "当前纪元：$_currentEpoch",
              ),
            ),
            Row(
              children: <Widget>[
                Text.rich(TextSpan(children: [
                  TextSpan(text: "下期预设", style: TextStyle(fontSize: 16, color: HexColor("#333333"))),
                  TextSpan(
                      text: isCloseRenew ? '' : editDateLimit,
                      style: TextStyle(fontSize: 12, color: HexColor("#999999"))),
                ])),
                Spacer(),
                Visibility(
                  visible: _isDelegator,
                  child: SizedBox(
                    height: 30,
                    child: InkWell(
                      onTap: _preNextAction,
                      child: Center(
                          child: Text(
                        isCloseRenew ? '' : "设置",
                        style: TextStyle(
                          fontSize: 14,
                          color: _canEditNextPeriod ? HexColor("#1F81FF") : HexColor("#999999"),
                        ),
                      )),
                    ),
                  ),
                ),
              ],
            ),
            isCloseRenew
                ? Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          _closeRenewDefaultText,
                          style: TextStyle(
                            color: HexColor("#333333"),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            _isCreator ? "自动续期" : "跟随续期",
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
            isCloseRenew
                ? Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "你无需任何操作",
                          style: TextStyle(
                            color: HexColor("#999999"),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 16),
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

  Widget _reDelegationWidget() {
    if (!_isRunning) return Container();

    var atlasEntity = _map3infoEntity?.atlas;
    bool isReDelegation = atlasEntity != null;

    if (!isReDelegation) {
      return Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 12, bottom: 20),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 36),
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(
                          text: "暂未复投Atlas节点，复投Atlas节点可以获得出块奖励",
                          style: TextStyle(
                            fontSize: 14,
                            color: HexColor("#333333"),
                          )),
                    ]),
                    textAlign: TextAlign.center,
                  ),
                ),
                Visibility(
                  visible: _isCreator && _map3Status == Map3InfoStatus.CONTRACT_HAS_STARTED,
                  child: InkWell(
                    onTap: () {
                      Application.eventBus.fire(UpdateMap3TabsPageIndexEvent(
                        index: 1,
                      ));
                      Routes.popUntilCachedEntryRouteName(context);
                    },
                    child: Text.rich(TextSpan(children: [
                      TextSpan(
                          text: "复投Atlas节点",
                          style: TextStyle(
                            fontSize: 14,
                            color: HexColor("#1F81FF"),
                          )),
                    ])),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget _item(String title, String detail) {
      return Text.rich(TextSpan(children: [
        TextSpan(
            text: title, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: HexColor("#999999"))),
        TextSpan(text: detail, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: HexColor("#333333"))),
      ]));
    }

    Decimal rewardDecimal = Decimal.parse(atlasEntity.rewardRate);
    var rewardValueString = FormatUtil.truncateDecimalNum(rewardDecimal, 4);
    var rewardValue = double.parse(rewardValueString);
    var rewardRate = FormatUtil.formatPercent(rewardValue);
    //LogUtil.printMessage("rank:${atlasEntity.rank},atlasEntity.reward:${atlasEntity.rewardRate}, rewardValueString:$rewardValueString");

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
                        text: "正在复投Atlas共识节点",
                        style: TextStyle(
                          fontSize: 16,
                          color: HexColor("#333333"),
                        )),
                  ])),
                ],
              ),
              InkWell(
                onTap: () {
                  var map3Address =
                      _map3nodeInformationEntity?.map3Node?.map3Address ?? (_map3infoEntity?.address ?? "");
                  Application.router.navigateTo(
                    context,
                    Routes.atlas_detail_page +
                        '?atlasNodeId=${FluroConvertUtils.fluroCnParamsEncode(atlasEntity?.nodeId ?? _nodeId)}&atlasNodeAddress=${FluroConvertUtils.fluroCnParamsEncode(atlasEntity?.address ?? map3Address)}',
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: HexColor("#F8F8F8"),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          iconWidget(
                            atlasEntity.pic,
                            atlasEntity.name,
                            atlasEntity.address,
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text.rich(TextSpan(children: [
                                    TextSpan(
                                        text: atlasEntity?.name ?? "",
                                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                  ])),
                                  Container(
                                    height: 4,
                                  ),
                                  _item("节点号：", atlasEntity?.nodeId ?? ''),
                                ],
                              ),
                            ),
                          ),
                          //Spacer(),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(rewardRate,
                                    style: TextStyle(
                                      color: HexColor("#9B9B9B"),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    )),
                                Container(
                                  height: 4,
                                ),
                                Text("昨日年化",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: HexColor("#999999"),
                                    )),
                              ],
                            ),
                          )
                        ],
                      ),
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
    List points = [];
    var point = {
      'name': _map3infoEntity.name ?? '',
      'value': _selectedRegion?.location?.getCoordinatesAfterSwap() ?? []
    };
    points.add(point);
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 20),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text.rich(TextSpan(children: [
                  TextSpan(text: "节点服务", style: TextStyle(fontSize: 16, color: HexColor("#333333"))),
                ])),
                Spacer(),
                Visibility(
                  visible: false,
                  child: SizedBox(
                    height: 30,
                    child: InkWell(
                      onTap: _pushNodeInfoAction,
                      child: Center(child: Text("访问节点", style: TextStyle(fontSize: 14, color: HexColor("#1F81FF")))),
                      //style: TextStyles.textC906b00S13),
                    ),
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
                        child: Map3NodesWidget(
                          json.encode(points),
                        ),
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
                          var details = [_selectProviderEntity?.name ?? "亚马逊云", _selectedRegion?.name ?? ""];

                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                  flex: 2,
                                  child: Text(
                                    details[index],
                                    style: TextStyle(
                                      color: HexColor("#333333"),
                                      fontSize: 12,
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
    if (_map3infoEntity == null) return Container();

    var totalDelegation = FormatUtil.stringFormatCoinNum(_map3infoEntity?.getStaking() ?? "0");
    var feeRate = FormatUtil.formatPercent(double.parse(_map3infoEntity?.getFeeRate() ?? "0"));

    var totalReward =
        FormatUtil.clearScientificCounting(_map3nodeInformationEntity?.accumulatedReward?.toDouble() ?? 0);
    var totalRewardValue = ConvertTokenUnit.weiToEther(weiBigInt: BigInt.parse(totalReward)).toDouble();
    var totalRewardString = FormatUtil.formatPrice(totalRewardValue);

    var myDelegationString = "0";
    var myRewardString = "0";

    Microdelegations _microDelegations = _isCreator ? _microDelegationsCreator : _microDelegationsJoiner;

    if (_microDelegations != null) {
      var pendingAmount = _microDelegations?.pendingDelegation?.amount;
      var activeAmount = _microDelegations?.amount;
      var myAmount = _isRunning ? activeAmount : pendingAmount;

      var myDelegation = FormatUtil.clearScientificCounting(myAmount?.toDouble() ?? 0);
      var myDelegationValue = ConvertTokenUnit.weiToEther(weiBigInt: BigInt.parse(myDelegation)).toDouble();
      myDelegationString = FormatUtil.formatPrice(myDelegationValue);

      var myReward = FormatUtil.clearScientificCounting(_microDelegations?.reward?.toDouble() ?? 0);
      var myRewardValue = ConvertTokenUnit.weiToEther(weiBigInt: BigInt.parse(myReward)).toDouble();
      myRewardString = FormatUtil.formatPrice(myRewardValue);
    }

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
                    padding: const EdgeInsets.only(top: 24),
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
                    padding: const EdgeInsets.only(top: 24),
                    child: Text(
                      myRewardString,
                      style: TextStyle(fontSize: 22, color: HexColor("#BF8D2A"), fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      "可提奖励",
                      style: TextStyle(fontSize: 14, color: HexColor("#999999"), fontWeight: FontWeight.normal),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 20, top: 30, left: 14, right: 14),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: HexColor("#F8F8F8"),
                borderRadius: BorderRadius.circular(6),
              ),
              child: profitListBigWidget(
                [
                  {"节点累计奖励": totalRewardString},
                  {"管理费": feeRate},
                  {"我的抵押": _isDelegator ? myDelegationString : "未抵押"},
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contractProgressWidget() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
            child: Row(
              children: <Widget>[
                Text("节点进度", style: TextStyle(fontSize: 16, color: HexColor("#333333"))),
                Spacer(),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 18, right: 8.0),
                      child: Container(
                        width: 10,
                        height: 10,
                        //color: Colors.red,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _statusColor,
                          border: Border.all(
                            color: Map3NodeUtil.statusBorderColor(_map3Status),
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: _stateDescText,
                          style: TextStyle(fontSize: 12, color: _statusColor),
                        ),
                      ]),
                    ),
                  ],
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
      _pendingEpoch > 0 ? "创建 #$_pendingEpoch" : "创建",
      _activeEpoch > 0 ? "启动 #$_activeEpoch" : "启动",
      _releaseEpoch > 0 ? "到期 #$_releaseEpoch" : "到期",
    ];

    var createdAt = FormatUtil.formatDate(_map3infoEntity?.createTime ?? 0, isSecond: false);
    var startTime = FormatUtil.formatDate(_map3infoEntity?.startTime ?? 0, isSecond: false);
    var endTime = FormatUtil.formatDate(_map3infoEntity?.endTime ?? 0, isSecond: false);

    var subtitles = [
      createdAt,
      startTime,
      endTime,
    ];
    var progressHints = [
      "",
      "${_map3introduceEntity?.days}纪元",
      "",
    ];

    return CustomStepper(
      tickColor: _statusColor,
      tickText: _contractStateDetail,
      currentStepProgress: _currentStepProgress,
      currentStep: _currentStep,
      steps: titles.map(
        (title) {
          var index = titles.indexOf(title);
          var subtitle = subtitles[index];
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

  Widget _spacer({bool isVisible = true}) {
    return SliverToBoxAdapter(
      child: Visibility(
        visible: isVisible,
        child: Container(
          height: 10,
        ),
      ),
    );
  }

  Widget _delegateRecordHeaderWidget() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Row(
          children: <Widget>[
            Text(S.of(context).account_flow, style: TextStyle(fontSize: 16, color: HexColor("#333333"))),
          ],
        ),
      ),
    );
  }

  /// TODO:Request
  Future _loadMoreData() async {
    try {
      _currentPage++;
      print("[getMap3StakingLogList]  more, _currentPage:$_currentPage");

      List<HynTransferHistory> tempMemberList = await _atlasApi.getMap3StakingLogList(_nodeAddress, page: _currentPage);

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

  Future _loadDetailData() async {
    _currentPage = 1;

    try {
      var requestList = await Future.wait([
        _atlasApi.getMap3Info(_address, _nodeId),
        _nodeApi.getNodeProviderList(),
      ]);

      _map3infoEntity = requestList[0];
      print("!!!!!1111 ${json.encode(_map3infoEntity.toJson())}");
      _map3Status = Map3InfoStatus.values[_map3infoEntity.status];

      if (_map3infoEntity != null && (_map3infoEntity?.address?.isNotEmpty ?? false)) {
        _nodeAddress = _map3infoEntity.address;

        var map3Address = EthereumAddress.fromHex(_nodeAddress);
        _map3nodeInformationEntity = await client.getMap3NodeInformation(map3Address);
        /*for (Microdelegations item in _map3nodeInformationEntity?.microdelegations ?? []) {
          print("[_loadDetailData] --> microdelegations.renew:${item.renewal.toJson()}");
        }*/

        _setupMicroDelegations();

        List<HynTransferHistory> tempMemberList =
            await _atlasApi.getMap3StakingLogList(_nodeAddress, page: _currentPage);
        _delegateRecordList = tempMemberList;
      }

      var providerList = requestList[1] as List;
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
      if (mounted) {
        setState(() {
          _currentState = null;
          _loadDataBloc.add(RefreshSuccessEvent());
        });

        if (_canEditNextPeriod) {
          _showEditPreNextAlert();
        }
      }
    } catch (e) {
      logger.e(e);
      LogUtil.toastException(e);

      if (mounted) {
        setState(() {
          _currentState = all_page_state.LoadFailState();
          _loadDataBloc.add(RefreshFailEvent());
        });
      }
    }
  }

  _setupMicroDelegations() {
    LogUtil.printMessage("[object] --> micro:${_map3nodeInformationEntity != null}");

    if (_map3nodeInformationEntity?.microdelegations?.isEmpty ?? true) {
      LogUtil.printMessage("[object] --> 1micro.length:${_map3nodeInformationEntity?.microdelegations?.length ?? 0}");

      return;
    }

    var creatorAddress = _map3nodeInformationEntity.map3Node.operatorAddress.toLowerCase();
    var joinerAddress = _address.toLowerCase();

    for (var item in _map3nodeInformationEntity?.microdelegations ?? []) {
      LogUtil.printMessage("[object] --> 2micro.length:${_map3nodeInformationEntity?.microdelegations?.length ?? 0}");

      var delegatorAddress = item.delegatorAddress.toLowerCase();
      if ((delegatorAddress == creatorAddress || delegatorAddress == joinerAddress)) {
        LogUtil.printMessage("[object] --> creatorAddress:$creatorAddress, joinerAddress:$joinerAddress");

        if (item.delegatorAddress == creatorAddress) {
          _microDelegationsCreator = item;
          LogUtil.printMessage("[object] --> creator.reward:${_microDelegationsCreator.renewal.toJson()}");
        }

        if (item.delegatorAddress == joinerAddress) {
          _microDelegationsJoiner = item;
          LogUtil.printMessage("[object] --> joiner.reward:${_microDelegationsJoiner.renewal.toJson()}");
        }
      }
    }
  }

  /// TODO:Action
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

  void _pushWalletManagerAction() {
    Application.router.navigateTo(
        context, Routes.map3node_create_wallet + "?pageType=${Map3NodeCreateWalletPage.CREATE_WALLET_PAGE_TYPE_JOIN}");
  }

  void _cancelAction() async {
    if (_isNoWallet) {
      _pushWalletManagerAction();
      return;
    }

    LogUtil.printMessage("_map3infoEntity.status:${_map3infoEntity.status}");

    if (_map3infoEntity != null) {
      var entryRouteName = Uri.encodeComponent(Routes.map3node_contract_detail_page);
      await Application.router.navigateTo(
        context,
        Routes.map3node_cancel_page +
            '?entryRouteName=$entryRouteName&info=${FluroConvertUtils.object2string(_map3infoEntity.toJson())}',
      );
      _nextAction();
    }
  }

  void _shareAction() {
    Application.router.navigateTo(
        context, Routes.map3node_share_page + "?info=${FluroConvertUtils.object2string(_map3infoEntity.toJson())}");
  }

  /*

  void _divideAction() {
    if (_isNoWallet) {
      _pushWalletManagerAction();
      return;
    }
    Application.router.navigateTo(context, Routes.map3node_divide_page);
  }
  */

  void _exitAction() async {
    if (_isNoWallet) {
      _pushWalletManagerAction();
      return;
    }
    if (_map3infoEntity != null) {
      var entryRouteName = Uri.encodeComponent(Routes.map3node_contract_detail_page);
      await Application.router.navigateTo(
        context,
        Routes.map3node_exit_page +
            '?entryRouteName=$entryRouteName&info=${FluroConvertUtils.object2string(_map3infoEntity.toJson())}',
      );
      _nextAction();
    }
  }

  void _collectAction() {
    if (_isNoWallet) {
      _pushWalletManagerAction();
      return;
    }

    Application.router.navigateTo(context, Routes.map3node_my_page);
  }

  void _editAction() async {
    if (_isNoWallet) {
      _pushWalletManagerAction();
      return;
    }

    if (_map3infoEntity != null) {
      var entryRouteName = Uri.encodeComponent(Routes.map3node_contract_detail_page);
      var encodeEntity = FluroConvertUtils.object2string(_map3infoEntity.toJson());

      await Application.router
          .navigateTo(context, Routes.map3node_edit_page + "?entryRouteName=$entryRouteName&entity=$encodeEntity");
      _nextAction();
    }
  }

  void _joinAction() async {
    if (_isNoWallet) {
      _pushWalletManagerAction();
      return;
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

  var _haveEditNext = false;
  void _preNextAction() async {
    if (!_canEditNextPeriod) return;

    if (_map3infoEntity != null) {
      var uploadInfo = 'currentEpoch:$_currentEpoch, info:${_map3infoEntity.toJson()}';
      print(uploadInfo);
      LogUtil.uploadException("[Map3NodeDetail] _preNextAction, uploadInfo", uploadInfo);
    }

    if (_map3nodeInformationEntity != null) {
      var uploadInfoAtlas = 'currentEpoch:$_currentEpoch, infoFromAtlas:${_map3nodeInformationEntity.toJson()}';
      print(uploadInfoAtlas);
      LogUtil.uploadException("[Map3NodeDetail] _preNextAction, uploadInfoAtlas", uploadInfoAtlas);
    }

    if (_microDelegationsCreator != null) {
      var uploadMicroCreator =
          'currentEpoch:$_currentEpoch, _microDelegationsCreator:${_microDelegationsCreator.renewal.toJson()}';
      print(uploadMicroCreator);
      LogUtil.uploadException("[Map3NodeDetail] _preNextAction, uploadMicroCreator", uploadMicroCreator);
    }

    if (_microDelegationsJoiner != null) {
      var uploadMicroJoiner =
          'currentEpoch:$_currentEpoch, _microDelegationsJoiner:${_microDelegationsJoiner.renewal.toJson()}';
      print(uploadMicroJoiner);
      LogUtil.uploadException("[Map3NodeDetail] _preNextAction, uploadMicroJoiner", uploadMicroJoiner);
    }

    if (_map3infoEntity != null) {
      var entryRouteName = Uri.encodeComponent(Routes.map3node_contract_detail_page);

      await Application.router.navigateTo(
          context,
          Routes.map3node_pre_edit_page +
              "?entryRouteName=$entryRouteName&info=${FluroConvertUtils.object2string(_map3infoEntity.toJson())}");

      _nextAction();
    }
  }

  void _nextAction({Map3NodeActionEvent action = Map3NodeActionEvent.MAP3_CREATE}) {
    final result = ModalRoute.of(context).settings?.arguments;

    LogUtil.printMessage("[detail] _next action, result:$result");

    if (result != null && result is Map && result["result"] is bool) {
      _loadDetailData();
    }
  }
}
