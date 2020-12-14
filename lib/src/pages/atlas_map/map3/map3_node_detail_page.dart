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
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_message.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_introduce_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_user_entity.dart';
import 'package:titan/src/pages/atlas_map/event/node_event.dart';
import 'package:titan/src/pages/atlas_map/widget/custom_stepper.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/pages/node/model/map3_node_util.dart';
import 'package:titan/src/pages/node/model/node_provider_entity.dart';
import 'package:titan/src/pages/wallet/model/hyn_transfer_history.dart';
import 'package:titan/src/pages/wallet/model/transtion_detail_vo.dart';
import 'package:titan/src/pages/webview/webview.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/map3_nodes_widget.dart';
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

class _Map3NodeDetailState extends BaseState<Map3NodeDetailPage> with TickerProviderStateMixin {
  LoadDataBloc _loadDataBloc = LoadDataBloc();

  final AtlasApi _atlasApi = AtlasApi();
  final _web3Client = WalletUtil.getWeb3Client(true, true);

  // 0映射中;1 创建提交中；2创建失败; 3募资中,没在撤销节点;4募资中，撤销节点提交中，如果撤销失败将回到3状态；5撤销节点成功；6合约已启动；7合约期满终止；
  get _map3Status => Map3InfoStatus.values[_map3infoEntity?.status ?? 1];

  Map3InfoEntity _map3infoEntity;
  Map3NodeInformationEntity _map3nodeInformationEntity;

  Microdelegations _microDelegationsCreator;
  Microdelegations _microDelegationsJoiner;

  int _currentPageTxLog = 0;
  int _currentPageUserList = 0;
  List<HynTransferHistory> _txLogList = [];
  List<Map3UserEntity> _userList = [];

  bool _showLoadingTxLog = true;
  bool _showLoadingUserList = true;
  bool _loadTxLogsFinished = false;
  bool _loadUserListFinished = false;

  HynTransferHistory _lastPendingTx;

  var _walletAddress = "";

  String get _nodeId => _map3infoEntity?.nodeId ?? _map3nodeInformationEntity?.map3Node?.description?.identity ?? '';
  String get _nodeAddress => _map3infoEntity?.address ?? _map3nodeInformationEntity?.map3Node?.map3Address ?? '';
  String get _nodeCreatorAddress =>
      _map3infoEntity?.creator ?? _map3nodeInformationEntity?.map3Node?.operatorAddress ?? '';

  NodeProviderEntity _selectProviderEntity;
  Regions _selectedRegion;
  var _haveShowedAlertView = false;
  Map3IntroduceEntity _map3introduceEntity;

  bool _isLoading = false;

  get _isRunning => _map3Status == Map3InfoStatus.CONTRACT_HAS_STARTED;
  get _isPending => _map3Status == Map3InfoStatus.FUNDRAISING_NO_CANCEL;
  get _isTerminal => _map3Status == Map3InfoStatus.CANCEL_NODE_SUCCESS;

  get _statusCreator => _microDelegationsCreator?.renewal?.status ?? 0;
  get _statusJoiner => _microDelegationsJoiner?.renewal?.status ?? 0;

  // get isHiddenRenew => (statusCreator == 1 && _isDelegate && !_isCreator);

  get _notifyMessage {
    if (_isLoading) {
      return S.of(Keys.rootKey.currentContext).map3_refresh_data;
    }

    switch (_map3Status) {
      case Map3InfoStatus.FUNDRAISING_CANCEL_SUBMIT:
        return S.of(Keys.rootKey.currentContext).map3_exit_doing;
        break;

      case Map3InfoStatus.CANCEL_NODE_SUCCESS:
        return S.of(Keys.rootKey.currentContext).map3_exit_done;
        //return '终止请求已完成, 请前往【钱包】查看退款情况!';
        break;

      case Map3InfoStatus.FUNDRAISING_NO_CANCEL:
        if (_isFullDelegate) {
          var startMinValue = FormatUtil.formatTenThousandNoUnit(startMin.toString()) + S.of(context).ten_thousand;
          return S.of(Keys.rootKey.currentContext).map3_pending_delegate_full(startMinValue);
        } else {
          if (_lastPendingTx != null) {
            var type = _lastPendingTx.type;
            switch (type) {
              case MessageType.typeTerminateMap3:
                return S.of(Keys.rootKey.currentContext).map3_exit_doing;
                break;

              case MessageType.typeUnMicroDelegate:
                TransactionDetailVo transactionDetail =
                    TransactionDetailVo.fromHynTransferHistory(_lastPendingTx, 0, "HYN");

                var amount = FormatUtil.stringFormatCoinNum(transactionDetail.getDecodedAmount());
                return S.of(Keys.rootKey.currentContext).map3_cancel_doing(amount);
                break;

              case MessageType.typeEditMap3:
                return S.of(Keys.rootKey.currentContext).map3_edit_doing;
                break;

              case MessageType.typeMicroDelegate:
                TransactionDetailVo transactionDetail =
                    TransactionDetailVo.fromHynTransferHistory(_lastPendingTx, 0, "HYN");

                var amount = FormatUtil.stringFormatCoinNum(transactionDetail.getDecodedAmount());
                return S.of(Keys.rootKey.currentContext).map3_delegate_doing(amount);
                break;
            }
          }
        }
        break;

      case Map3InfoStatus.CONTRACT_IS_END:
        //print("[text] _currentEpoch:$_currentEpoch, _releaseEpoch:$_releaseEpoch");
        if (_currentEpoch <= (_releaseEpoch + 1)) {
          return S.of(Keys.rootKey.currentContext).map3_end_done;
        }
        break;

      case Map3InfoStatus.CONTRACT_HAS_STARTED:
        if (_isDelegate) {
          if (_lastPendingTx != null) {
            var type = _lastPendingTx.type;
            switch (type) {
              case MessageType.typeCollectMicroStakingRewards:
                return S.of(Keys.rootKey.currentContext).map3_collect_doing;
                break;

              case MessageType.typeRenewMap3:
                return S.of(Keys.rootKey.currentContext).map3_renew_doing;
                break;

              case MessageType.typeEditMap3:
                return S.of(Keys.rootKey.currentContext).map3_edit_doing;
                break;

              case MessageType.typeReDelegate:
                return S.of(Keys.rootKey.currentContext).map3_re_delegate_doing;
                break;

              case MessageType.typeUnReDelegate:
                return S.of(Keys.rootKey.currentContext).map3_un_re_delegate_doing;
                break;

              case MessageType.typeCollectReStakingReward:
                return S.of(Keys.rootKey.currentContext).map3_collect_in_atlas_doing;
                break;
            }
          }

          if (_map3infoEntity.atlas == null) {
            return S.of(Keys.rootKey.currentContext).map3_notification_redelegate;
          }

          if (_isCreator) {
            /*
            * 没有设置过，开始提示
            * */
            var periodEpoch14 = _releaseEpoch - 14 + 1;
            //var periodEpoch7 = _releaseEpoch - 7;

            var leftEpoch = periodEpoch14 - _currentEpoch;

            if (_statusCreator == 0 && leftEpoch > 0) {
              return S.of(Keys.rootKey.currentContext).map3_notification_left_epoch(leftEpoch);
            }
          } else {
            /*
            * 没有设置过，开始提示
            * */
            //var periodEpoch14 = _releaseEpoch - 14 + 1;
            var periodEpoch7 = _releaseEpoch - 7 + 1;

            var leftEpoch = periodEpoch7 - _currentEpoch;

            if (_statusJoiner == 0 && leftEpoch > 0) {
              if (_statusCreator == 0) {
                return S.of(Keys.rootKey.currentContext).map3_notification_left_epoch(leftEpoch);
              } else if (_statusCreator == 1) {
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

  get _visibleBottomBar => ((_isRunning && _isDelegate) || (_isPending)); // 提取奖励 or 参与抵押

  get _isNoWallet => _walletAddress?.isEmpty ?? true;

  get _endRemainEpoch => (_releaseEpoch ?? 0) - (_currentEpoch ?? 0) + 1;

  var _currentEpoch = 0;
  var _currentBlockHeight = 0;

  // 到期纪元
  get _releaseEpoch =>
      _map3infoEntity?.endEpoch ?? double.parse(_map3nodeInformationEntity?.map3Node?.releaseEpoch ?? "0").toInt();
  get _activeEpoch => _map3infoEntity?.startEpoch ?? _map3nodeInformationEntity?.map3Node?.activationEpoch ?? 0;
  get _pendingEpoch => _map3nodeInformationEntity?.map3Node?.pendingEpoch ?? 0;
  // get _pendingUnlockEpoch =>
  //     double.tryParse(_microDelegationsCreator?.pendingDelegation?.unlockedEpoch ?? '0')?.toInt() ?? 0;

  get _closeRenewDefaultText => S.of(Keys.rootKey.currentContext).map3_notification_expired;

  /*
  tips:
  “创建者“显示编辑： 倒数14个纪元到倒数7纪元 且 状态为未设置  开始显示。
  如果已经设置了关闭，就显示【关闭】，其他情况显示【已开启】

  ”抵押者“显示编辑： 倒数7纪元后  且 （“创建者”设置为【已开启】或【未设置】） 且  自己状态为未设置，    或“创建者”已设置为【已开启】 且 自己状态为未设置，  开始显示。
  如果已经设置了关闭，就显示【关闭】，其他情况显示【已开启】
  */
  get _canRenewNextPeriod {
    // 周期
    var periodEpoch14 = (_releaseEpoch - 14) > 0 ? _releaseEpoch - 14 : 0;
    var periodEpoch7 = _releaseEpoch - 7 > 0 ? _releaseEpoch - 7 : 0;

    //  创建者
    if (_isCreator) {
      var isInActionPeriodCreator = (_currentEpoch > periodEpoch14) && (_currentEpoch <= periodEpoch7);
      //LogUtil.printMessage("【isCreator】statusCreator:$statusCreator, isInActionPeriodCreator:$isInActionPeriodCreator");

      if (isInActionPeriodCreator && _statusCreator == 0) {
        //在可编辑时间内，且未修改过
        return true;
      }
      return false;
    }

    // 参与者
    var isInActionPeriodJoiner = _currentEpoch > periodEpoch7 && _currentEpoch <= _releaseEpoch;
    //LogUtil.printMessage("[statusJoiner] statusJoiner:$statusJoiner, statusCreator:$statusCreator");

    if (_isDelegate) {
      var isCreatorSetOpen = _statusCreator == 2; //创建人已开启
      var isCreatorSetClose = _statusCreator == 1; //创建人已开启

      if ((_statusJoiner == 0 && isCreatorSetOpen) ||
          (_statusJoiner == 0 && isInActionPeriodJoiner && !isCreatorSetClose)) {
        return true;
      }
    }

    return false;
  }

  // 0.募集中
  // 1.纪元已经过7天；
  // get _canExit => _isCreator && _isPending && _isOver7Epoch;
  get _canExit => _isCreator && (_isPending || _isTerminal);

  //get _isOver7Epoch => (_currentEpoch - _pendingUnlockEpoch) > 0 && (_pendingUnlockEpoch > 0) && (_currentEpoch > 0);

  get _canEditNode =>
      _isCreator &&
      (_map3Status != Map3InfoStatus.CANCEL_NODE_SUCCESS &&
          _map3Status != Map3InfoStatus.FUNDRAISING_CANCEL_SUBMIT &&
          _map3Status != Map3InfoStatus.CREATE_SUBMIT_ING);

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

  get _isDelegate => _map3infoEntity?.mine != null;

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
        if (_isCreator) {
          var periodEpoch14 = _releaseEpoch - 14 + 1;
          var periodEpoch7 = _releaseEpoch - 7;

          // 没有设置过
          if (_statusCreator == 0) {
            if (_currentEpoch < periodEpoch14) {
              value = 1;
            } else {
              value = 2;
            }
          }
          // 已设置过
          else {
            value = 2;
          }
        } else {
          var periodEpoch7 = _releaseEpoch - 7 + 1;

          if (_statusJoiner == 0) {
            if (_statusCreator == 0) {
              if (_currentEpoch < periodEpoch7) {
                value = 1;
              } else {
                value = 2;
              }
            } else if (_statusCreator == 1) {
              value = 1;
            } else if (_statusCreator == 2) {
              value = 2;
            }
          } else {
            value = 2;
          }
        }

        break;

      case Map3InfoStatus.CONTRACT_IS_END:
        value = 3;
        break;

      default:
        break;
    }

    return value;
  }

  //最小启动所需
  double get startMin => double.tryParse(_map3introduceEntity?.startMin ?? "0") ?? 0;

  //当前抵押量
  double get staking => double.tryParse(_map3infoEntity?.getStaking() ?? "0") ?? 0;

  get _isFullDelegate => (startMin > 0) && (staking > 0) && (staking >= startMin);

  get _currentStepProgress {
    if (_map3Status == null) return 0.0;

    double value = 0.0;

    switch (_map3Status) {
      case Map3InfoStatus.FUNDRAISING_NO_CANCEL:
        var left = staking / startMin;

        if (left.isNaN) {
          left = 0.1;
        }

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

        if (_currentStep == 2) {
          left = (_currentEpoch - _renewEpoch).toDouble() / (_releaseEpoch - _renewEpoch).toDouble();
        } else {
          left = (_currentEpoch - _activeEpoch).toDouble() / (_renewEpoch - _activeEpoch).toDouble();
        }

        if (left.isNaN) {
          left = 0.1;
        }

        if (left <= 0.1) {
          value = 0.1;
        } else if (left > 0.1 && left < 1.0) {
          value = left;
        } else {
          value = 1.0;
        }

        break;

      /*
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
       */

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
          _map3StatusDesc =
              S.of(Keys.rootKey.currentContext).map3_notification_expired_left_epoch(_endRemainEpochValue);
        } else {
          //_map3StatusDesc = "距离到期仅剩1个纪元";
          _map3StatusDesc = "";
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
          _map3StatusDesc = S.of(Keys.rootKey.currentContext).delegation_full_will_active_hint;
        } else {
          var remain = startMin - staking;
          var remainDelegation = FormatUtil.formatPrice(remain);
          _map3StatusDesc =
              S.of(Keys.rootKey.currentContext).remain + remainDelegation + S.of(Keys.rootKey.currentContext).active;
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

  List<Map3NodeDetailTabBarModel> _delegateRecordTabModels;
  TabController _detailTabController;
  Map3NodeDetailType _detailCurrentIndex = Map3NodeDetailType.tx_log;

  @override
  void initState() {
    //WidgetsBinding.instance.addPostFrameCallback(_afterLayout);

    _setupData();

    super.initState();
  }

  @override
  void onCreated() {
    super.onCreated();

    _delegateRecordTabModels = [
      Map3NodeDetailTabBarModel(S.of(context).account_flow, Map3NodeDetailType.tx_log),
      Map3NodeDetailTabBarModel(S.of(context).join_address, Map3NodeDetailType.user_list),
    ];
    _detailTabController = TabController(length: _delegateRecordTabModels.length, vsync: this);

    _refreshData();
  }

  _setupData() async {
    _map3infoEntity = widget.map3infoEntity;

    var _wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet?.wallet;
    _walletAddress = _wallet?.getEthAccount()?.address ?? "";

    _map3introduceEntity = await AtlasApi.getIntroduceEntity();

    _selectedRegion = await NodeApi.getProviderEntity(_map3infoEntity?.region);

    if (_nodeAddress.isNotEmpty) {
      print("[Map3Detail] --> _nodeAddress:$_nodeAddress");

      setState(() {
        _loadDataBloc.add(RefreshSuccessEvent());
      });
    }
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
            S.of(context).map3_node_setting_now,
            () {
              setState(() {
                _haveShowedAlertView = true;
              });
              Navigator.pop(context);

              _renewAction();
            },
            width: 160,
            height: 38,
            fontSize: 16,
          ),
        ],
        content: _isCreator ? S.of(context).map3_renew_content_creator : S.of(context).map3_renew_content_joiner,
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
    var _lastCurrentBlockHeight = _currentBlockHeight;
    _currentEpoch = AtlasInheritedModel.of(context).committeeInfo?.epoch ?? 0;

    _currentBlockHeight = AtlasInheritedModel.of(context).committeeInfo?.blockNum ?? 0;
    if (_lastCurrentBlockHeight == 0) {
      _lastCurrentBlockHeight = _currentBlockHeight;
    }
    // LogUtil.printMessage(
    //     "[${widget.runtimeType}] _currentEpoch:$_currentEpoch, _releaseEpoch: $_releaseEpoch, endEpoch:${_map3infoEntity.endEpoch}, _activeEpoch:$_activeEpoch, startEpoch:${_map3infoEntity.startEpoch}");

    List<Widget> actions = [];

    var config = SettingInheritedModel.ofConfig(context).systemConfigEntity;
    var hasShare = config?.canShareMap3Node ?? true;

    if ((_map3Status == Map3InfoStatus.CREATE_SUBMIT_ING || _lastPendingTx != null) &&
        (_currentBlockHeight > _lastCurrentBlockHeight)) {
      // LogUtil.printMessage("[${widget.runtimeType}] build, _refreshData");
      _refreshData();
    }

    if (_canExit) {
      actions = [
        FlatButton(
          onPressed: _exitAction,
          child: Text(
            S.of(context).map3_node_exit,
            style: TextStyle(
              color: HexColor("#999999"),
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ];
    }

    if (hasShare) {
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

      actions.add(shareWidget);
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

  bool get _hasFootView {
    if (_detailCurrentIndex == Map3NodeDetailType.tx_log) {
      if (_showLoadingTxLog) {
        return false;
      } else {
        if (_txLogList.isEmpty) {
          return false;
        } else {
          return true;
        }
      }
    } else {
      if (_showLoadingUserList) {
        return false;
      } else {
        if (_userList.isEmpty) {
          return false;
        } else {
          return true;
        }
      }
    }
  }

  /// TODO:Widget
  Widget _pageWidget(BuildContext context) {
    return Column(
      children: <Widget>[
        // 0.通知
        _topNextEpisodeNotifyWidget(),

        Expanded(
          child: LoadDataContainer(
              bloc: _loadDataBloc,
              //enablePullDown: false,
              enablePullUp: _nodeAddress?.isNotEmpty ?? false,
              hasFootView: _hasFootView,
              onRefresh: _refreshData,
              onLoadingMore: _loadDelegateMoreData,
              child: CustomScrollView(
                //physics: AlwaysScrollableScrollPhysics(),
                slivers: <Widget>[
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

                  _detailTabWidget(),
                  _detailWidget(),

                  /*
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
                            map3CreatorAddress: _nodeCreatorAddress,
                          );
                        }, childCount: _delegateRecordList.length))
                      : emptyListWidget(title: "节点记录为空"),

                   */
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
    //LogUtil.printMessage("_invisibleBottomBar:$_visibleBottomBar");

    if (!_visibleBottomBar || _map3nodeInformationEntity == null) return Container();

    List<Widget> children = [];

    switch (_map3Status) {
      case Map3InfoStatus.CONTRACT_HAS_STARTED:
        children = <Widget>[
          ClickOvalButton(
            S.of(context).collect_reward,
            _collectAction,
            width: 160,
            height: 36,
            fontSize: 14,
            //btnColor: HexColor("#FFC900"),
          )
        ];
        break;

      case Map3InfoStatus.FUNDRAISING_NO_CANCEL:
        children = <Widget>[
          Spacer(),
          ClickOvalButton(
            S.of(context).map3_node_cancel_staking,
            _cancelAction,
            width: 120,
            height: 32,
            fontSize: 14,
            fontColor: HexColor("#999999"),
            btnColor: [Colors.transparent],
          ),
          Spacer(),
          ClickOvalButton(
            S.of(context).map3_node_delegate,
            _joinAction,
            width: 120,
            height: 32,
            fontSize: 14,
          ),
          Spacer(),
        ];

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
    if (notification == null || _map3nodeInformationEntity == null) {
      return Container();
    }

    // var bgColor = (_isRunning) ? HexColor("#FF4C3B") : HexColor("#1FB9C7").withOpacity(0.08);
    // var contentColor = (_isRunning) ? HexColor("#FFFFFF") : HexColor("#333333");

    var bgColor = HexColor("#1FB9C7").withOpacity(0.08);
    var contentColor = HexColor("#333333");

    if (_lastPendingTx != null || _isLoading) {
      bgColor = HexColor("#1FB9C7").withOpacity(0.08);
      contentColor = HexColor("#333333");
    }
    if (_isLoading) {
      return Container(
        color: bgColor,
        padding: const EdgeInsets.fromLTRB(23, 0, 16, 0),
        child: Row(
          children: <Widget>[
            Spacer(),
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
                strokeWidth: 1.5,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text(
                notification,
                style: TextStyle(fontSize: 12, color: contentColor),
              ),
            ),
            Spacer(),
          ],
        ),
      );
    }

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

    var nodeName = _map3nodeInformationEntity?.map3Node?.description?.name ?? _map3infoEntity?.name ?? "***";
    var oldYear = double.parse(_map3nodeInformationEntity?.map3Node?.age ?? "0").toInt();
    var oldYearValue = oldYear > 0 ? "${S.of(context).node_age}：${FormatUtil.formatPrice(oldYear.toDouble())}" : "";

    var nodeAddress =
        "${UiUtil.shortEthAddress(WalletUtil.ethAddressToBech32Address(_nodeAddress) ?? "***", limitLength: 8)}";
    var nodeIdPre = "${S.of(context).node_num} ";

    var descPre = S.of(context).map3_node_notification;
    var describe = _map3nodeInformationEntity?.map3Node?.description?.details ?? _map3infoEntity?.describe ?? "";
    var desc = describe.isEmpty ?? false ? S.of(context).map3_node_notification_default : describe;
    var home = _map3nodeInformationEntity?.map3Node?.description?.website ?? _map3infoEntity?.home ?? '';
    var contact = _map3nodeInformationEntity?.map3Node?.description?.securityContact ?? _map3infoEntity?.contact ?? '';

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
                            text: _nodeId,
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
                  if (home.isNotEmpty ?? false)
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
                                home,
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
                  if (contact.isNotEmpty ?? false)
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
                                contact,
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
                    visible: _canEditNode,
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
                            Text(S.of(context).map3_node_edit,
                                style: TextStyle(fontSize: 14, color: HexColor("#1F81FF"))),
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

    var lastFeeRate = FormatUtil.formatPercent(double.parse(_map3infoEntity?.getFeeRate() ?? "0"));
    var rateForNextPeriod = _map3nodeInformationEntity?.map3Node?.commission?.rateForNextPeriod ?? "0";
    var newFeeRate = FormatUtil.formatPercent(double.parse(rateForNextPeriod));

    var statusDesc = S.of(context).map3_renew_open;
    var feeRate = lastFeeRate;

    // 参与者，没设置，没到期
    bool isShowEpoch = false;
    bool isShowAlert = false;
    var alertContent = "";
    var _renewRemainEpoch = 0;
    HexColor alertColor = HexColor('999999');

    var isCloseRenew = (_statusCreator == 1 && _isDelegate && !_isCreator);

    var status = _isDelegate ? _statusJoiner : -1;

    switch (status) {
      case -1:
        statusDesc = S.of(context).map3_renew_delegate_no;

        alertContent = '';
        isShowAlert = false;
        feeRate = lastFeeRate;

        break;

      case 0: // 未编辑，默认，开启，取上传rate

        // 周期
        var periodEpoch14 = _releaseEpoch - 14;
        var periodEpoch7 = _releaseEpoch - 7;

        if (_isCreator) {
          var isOutActionPeriodCreator = _currentEpoch > periodEpoch7;

          isShowEpoch = !isOutActionPeriodCreator;

          if (isOutActionPeriodCreator) {
            statusDesc = S.of(context).map3_renew_setting_expired;
            alertColor = HexColor('999999');
          } else {
            statusDesc = S.of(context).map3_renew_setting_no;
            alertColor = _canRenewNextPeriod ? HexColor('#FF5041') : HexColor('#FEC500');
          }

          alertContent = "（${S.of(context).map_renew_setting_date_func(periodEpoch14 + 1, periodEpoch7)}）";

          if (_canRenewNextPeriod) {
            _renewRemainEpoch = periodEpoch7 - _currentEpoch + 1;
          } else {
            _renewRemainEpoch = periodEpoch14 - _currentEpoch + 1;
          }
        } else {
          var isOutActionPeriodJoiner = _currentEpoch > _releaseEpoch;

          isShowEpoch = !isOutActionPeriodJoiner;

          if (isOutActionPeriodJoiner) {
            statusDesc = S.of(context).map3_renew_setting_expired;
            alertColor = HexColor('#999999');
          } else {
            statusDesc = S.of(context).map3_renew_setting_no;
            alertColor = _canRenewNextPeriod ? HexColor('#FF5041') : HexColor('#FEC500');
          }

          var periodEpoch7Add = periodEpoch7 + 1;
          var releaseEpoch = _releaseEpoch;
          alertContent = "（${S.of(context).map_renew_setting_date_func(periodEpoch7Add, releaseEpoch)}）";

          if (_canRenewNextPeriod) {
            _renewRemainEpoch = _releaseEpoch - _currentEpoch + 1;
          } else {
            _renewRemainEpoch = periodEpoch7 - _currentEpoch + 1;
          }

          if (_statusCreator == 2 && _canRenewNextPeriod) {
            alertContent = "（${S.of(context).map3_renew_setting_pre}）";
            _renewRemainEpoch = _releaseEpoch - _currentEpoch + 1;
          }
        }

        // 保险起见：
        if (_renewRemainEpoch <= 0) {
          isShowEpoch = false;
        }

        if (periodEpoch14 < 0 || periodEpoch7 < 0) {
          alertContent = "";
        }

        isShowAlert = true;

        if (isCloseRenew) {
          isShowAlert = false;
          alertContent = '';
        }

        feeRate = lastFeeRate;
        break;

      case 1:
        statusDesc = S.of(context).map3_renew_setting_close;
        feeRate = newFeeRate;

        alertContent = "（${S.of(context).map3_renew_setting_finished}）";
        isShowAlert = false;

        break;

      case 2:
        statusDesc = S.of(context).map3_renew_setting_open;
        feeRate = newFeeRate;

        alertContent = "（${S.of(context).map3_renew_setting_finished}）";
        isShowAlert = false;

        break;
    }

    if (_isDelegate && _canRenewNextPeriod) {
      _map3infoEntity.rateForNextPeriod = rateForNextPeriod;
    }

    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 20),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text.rich(TextSpan(children: [
                  TextSpan(
                      text: S.of(context).map3_renew_next_period,
                      style: TextStyle(fontSize: 16, color: HexColor("#333333"))),
                ])),
                Visibility(
                  visible: isShowAlert,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 3,
                      left: 4,
                    ),
                    child: Icon(
                      Icons.report_problem,
                      color: alertColor,
                      size: 15,
                    ),
                  ),
                ),
                Text.rich(TextSpan(children: [
                  TextSpan(text: alertContent, style: TextStyle(fontSize: 12, color: HexColor("#999999"))),
                ])),
                Spacer(),
                Visibility(
                  visible: _isDelegate,
                  child: SizedBox(
                    height: 30,
                    child: InkWell(
                      onTap: _canRenewNextPeriod ? _renewAction : null,
                      child: Center(
                          child: Text(
                        isCloseRenew ? '' : S.of(context).setting,
                        style: TextStyle(
                          fontSize: 14,
                          color: _canRenewNextPeriod ? HexColor("#1F81FF") : HexColor("#999999"),
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
                            _isCreator ? S.of(context).map3_renew_auto : S.of(context).map3_renew_join,
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
                          S.of(context).map3_node_no_action_hint,
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
                            S.of(context).manage_fee,
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
            if (isShowEpoch)
              Padding(
                padding: const EdgeInsets.only(
                  top: 16,
                ),
                child: Text.rich(TextSpan(children: [
                  TextSpan(
                      text: "${S.of(context).atlas_current_age} ",
                      style: TextStyle(fontSize: 14, color: HexColor("#999999"))),
                  TextSpan(
                      text: '$_currentEpoch',
                      style: TextStyle(
                        fontSize: 14,
                        color: HexColor("#1096B1"),
                        fontWeight: FontWeight.w600,
                      )),
                ])),
              ),
            if (isShowEpoch)
              Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                ),
                child: Text.rich(TextSpan(children: [
                  TextSpan(
                      text: _canRenewNextPeriod
                          ? '${S.of(context).map3_setting_epoch_left} '
                          : '${S.of(context).map3_setting_epoch_need} ',
                      style: TextStyle(fontSize: 14, color: HexColor("#999999"))),
                  TextSpan(
                      text: '$_renewRemainEpoch',
                      style: TextStyle(
                        fontSize: 14,
                        color: HexColor("#1096B1"),
                        fontWeight: FontWeight.w600,
                      )),
                  TextSpan(text: ' ${S.of(context).epoch}', style: TextStyle(fontSize: 14, color: HexColor("#999999"))),
                ])),
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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 3,
                        ),
                        child: Icon(
                          Icons.report_problem,
                          color: HexColor('#FF5041'),
                          size: 15,
                        ),
                      ),
                      Expanded(
                        child: Text.rich(
                          TextSpan(children: [
                            TextSpan(
                                text: S.of(context).map3_node_re_staking_hint,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: HexColor("#333333"),
                                )),
                          ]),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
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
                          text: S.of(context).map3_node_re_staking_title,
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
                        text: S.of(context).map3_node_re_staking_ing,
                        style: TextStyle(
                          fontSize: 16,
                          color: HexColor("#333333"),
                        )),
                  ])),
                ],
              ),
              InkWell(
                onTap: () {
                  Application.router.navigateTo(
                    context,
                    Routes.atlas_detail_page +
                        '?atlasNodeId=${FluroConvertUtils.fluroCnParamsEncode(atlasEntity?.nodeId ?? _nodeId)}&atlasNodeAddress=${FluroConvertUtils.fluroCnParamsEncode(atlasEntity?.address ?? _nodeAddress)}',
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
                                  _item("${S.of(context).node_num}：", atlasEntity?.nodeId ?? ''),
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
                                Text(S.of(context).atlas_reward_rate,
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
                  TextSpan(
                      text: S.of(context).map3_node_service,
                      style: TextStyle(fontSize: 16, color: HexColor("#333333"))),
                ])),
                Spacer(),
                Visibility(
                  visible: false,
                  child: SizedBox(
                    height: 30,
                    child: InkWell(
                      onTap: _pushNodeInfoAction,
                      child: Center(
                          child: Text(S.of(context).click_view_detail,
                              style: TextStyle(fontSize: 14, color: HexColor("#1F81FF")))),
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
                          var titles = [S.of(context).map3_node_device, S.of(context).position];
                          var details = [
                            _selectProviderEntity?.name ?? S.of(context).amazon_cloud,
                            _selectedRegion?.name ?? ""
                          ];

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

    //print("myDelegationString: --->$myDelegationString, _isDelegate:$_isDelegate");

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
                child: Text(S.of(context).node_amount, style: TextStyle(fontSize: 16, color: HexColor("#333333"))),
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
                      S.of(context).total_staking,
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
                      S.of(context).map3_current_reward,
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
                  {S.of(context).node_cumulative_reward: totalRewardString},
                  {S.of(context).atlas_fee_rate: feeRate},
                  {
                    S.of(context).my_staking: (_isDelegate || myDelegationString != '0')
                        ? myDelegationString
                        : S.of(context).map3_node_un_staking
                  },
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
                Text(S.of(context).map3_node_progress, style: TextStyle(fontSize: 16, color: HexColor("#333333"))),
                Spacer(),
                Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: '${S.of(context).atlas_current_age} ',
                      style: TextStyle(
                        fontSize: 14,
                        color: HexColor('#999999'),
                      ),
                    ),
                    TextSpan(
                      text: '$_currentEpoch',
                      style: TextStyle(fontSize: 14, color: HexColor('#1096B1')),
                    ),
                  ]),
                ),
              ],
            ),
          ),
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
          Container(
            height: 140,
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: _customStepperWidget(),
          ),
        ],
      ),
    );
  }

  int get _renewEpoch {
    var periodEpoch14 = _releaseEpoch - 14 + 1;
    var periodEpoch7 = _releaseEpoch - 7 + 1;

    var renewEpoch = _isCreator ? periodEpoch14 : periodEpoch7;
    if (_currentStep == 2 && _statusCreator == 2) {
      renewEpoch = periodEpoch14;
    }
    return renewEpoch;
  }

  Widget _customStepperWidget() {
    var titles = [
      _pendingEpoch > 0 ? "${S.of(context).create} #$_pendingEpoch" : S.of(context).create,
      _activeEpoch > 0 ? "${S.of(context).active} #$_activeEpoch" : S.of(context).active,
      _renewEpoch > 0 ? '${S.of(context).map3_renew} #$_renewEpoch' : S.of(context).map3_renew,
      _releaseEpoch > 0 ? "${S.of(context).expired} #$_releaseEpoch" : S.of(context).expired,
    ];

    var createdAt = FormatUtil.formatDate(_map3infoEntity?.createTime ?? 0, isSecond: false);
    var startTime = FormatUtil.formatDate(_map3infoEntity?.startTime ?? 0, isSecond: false);
    var endTime = FormatUtil.formatDate(_map3infoEntity?.endTime ?? 0, isSecond: false);

    var subtitles = [
      createdAt,
      startTime,
      endTime,
      '',
    ];
    var progressHints = [
      '',
      '', //"${_map3introduceEntity?.days}纪元",
      '',
      '',
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

  _detailTabWidget() {
    return SliverToBoxAdapter(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                ),
                child: TabBar(
                  controller: _detailTabController,
                  isScrollable: true,
                  labelColor: HexColor('#228BA1'),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorColor: HexColor('#228BA1'),
                  indicatorWeight: 2,
                  indicatorPadding: EdgeInsets.only(bottom: 2),
                  unselectedLabelColor: HexColor("#333333"),
                  onTap: (int index) {
                    var type = Map3NodeDetailType.values[index];
                    setState(() {
                      _detailCurrentIndex = type;
                    });

                    print("[$runtimeType] onTap:$index, type:${type.toString()}");

                    if (type == Map3NodeDetailType.tx_log) {
                      if (_txLogList.isEmpty) {
                        _loadTxLogData();
                      } else {
                        if (!_loadTxLogsFinished) {
                          print("[$runtimeType] _loadTxLogsFinished:$_loadTxLogsFinished");

                          if (_currentPageTxLog > 1) {
                            print("[$runtimeType] _loadTxLogsFinished:$_loadTxLogsFinished, >1");

                            _loadDataBloc.add(LoadingMoreSuccessEvent());
                          } else {
                            print("[$runtimeType] _loadTxLogsFinished:$_loadTxLogsFinished, >2");

                            _loadDataBloc.add(RefreshSuccessEvent());
                          }
                        }
                      }
                    } else {
                      if (_userList.isEmpty) {
                        _loadUserListData();
                      } else {
                        if (!_loadUserListFinished) {
                          print("[$runtimeType] _loadUserListFinished:$_loadUserListFinished");

                          if (_currentPageUserList > 1) {
                            print("[$runtimeType] _loadUserListFinished:$_loadUserListFinished, >1");

                            _loadDataBloc.add(LoadingMoreSuccessEvent());
                          } else {
                            print("[$runtimeType] _loadUserListFinished:$_loadUserListFinished, >2");

                            _loadDataBloc.add(RefreshSuccessEvent());
                          }
                        }
                      }
                    }
                  },
                  tabs: _delegateRecordTabModels
                      .map((model) => Tab(
                            child: Text(
                              model.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailWidget() {
    return SliverToBoxAdapter(
      child: Stack(
        children: [
          Visibility(
            visible: _detailCurrentIndex == Map3NodeDetailType.tx_log,
            child: Stack(
              children: <Widget>[
                Visibility(
                  visible: !_showLoadingTxLog,
                  child: _txLogView(),
                ),
                _loadingWidget(visible: _showLoadingTxLog),
              ],
            ),
          ),
          Visibility(
            visible: _detailCurrentIndex == Map3NodeDetailType.user_list,
            child: Stack(
              children: <Widget>[
                Visibility(
                  visible: !_showLoadingUserList,
                  child: _userListView(),
                ),
                _loadingWidget(visible: _showLoadingUserList),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _txLogView() {
    if (_txLogList.isEmpty) {
      return Container(
        width: double.infinity,
        child: emptyListWidget(
          title: S.of(context).map3_node_record_is_empty,
          isAdapter: false,
        ),
      );
    }

    return Column(
      children: <Widget>[
        /*
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                color: Colors.white,
                child: Text('共 ${_txLogList?.length ?? 0}个',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                      color: HexColor('#999999'),
                    )),
              ),
            ),
          ],
        ),
        */
        ListView.builder(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            return delegateRecordItemWidget(
              _txLogList[index],
              map3CreatorAddress: _nodeCreatorAddress,
            );
          },
          itemCount: _txLogList.length,
        ),
      ],
    );
  }

  _userListView() {
    if (_userList.isEmpty) {
      return Container(
        width: double.infinity,
        child: emptyListWidget(
          title: S.of(context).map3_join_delegate_address_is_empty_hint,
          isAdapter: false,
        ),
      );
    }

    var totalCount = _userList?.length ?? 0;
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                color: Colors.white,
                child: Text(S.of(context).map3_join_total_count(totalCount),
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                      color: HexColor('#999999'),
                    )),
              ),
            ),
          ],
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            var item = _userList[index];

            var itemAddress = item.address.toLowerCase();
            var isYou = itemAddress == _walletAddress;
            var isCreator = itemAddress == _nodeCreatorAddress.toLowerCase();
            var recordName =
                "${isCreator && !isYou ? " (${S.of(Keys.rootKey.currentContext).creator})" : ""}${!isCreator && isYou ? " (${S.of(Keys.rootKey.currentContext).you})" : ""}${isCreator && isYou ? " (${S.of(Keys.rootKey.currentContext).creator})" : ""}";

            var amount = FormatUtil.stringFormatCoinNum(
                    ConvertTokenUnit.weiToEther(weiBigInt: BigInt.parse(item.staking)).toString()) +
                ' HYN';

            return Container(
              color: Colors.white,
              child: Stack(
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      AtlasApi.goToHynScanPage(context, item.address);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 40,
                            width: 40,
                            child: iconWidget("", item.name, item.address, isCircle: true),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 2,
                                        child: RichText(
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          text: TextSpan(
                                            text: item.name,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: HexColor("#000000"),
                                              fontWeight: FontWeight.w500,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: recordName,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: HexColor("#999999"),
                                                    fontWeight: FontWeight.w500),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: 8.0,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        shortBlockChainAddress("${WalletUtil.ethAddressToBech32Address(itemAddress)}",
                                            limitCharsLength: 8),
                                        style: TextStyle(fontSize: 12, color: HexColor("#999999")),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            amount,
                            style: TextStyle(
                              fontSize: 14,
                              color: HexColor('#333333'),
                              fontWeight: FontWeight.w600,
                            ),
                          )
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
          },
          itemCount: _userList.length,
        ),
      ],
    );
  }

  Widget _loadingWidget({bool visible = true, double height = 100}) {
    return Visibility(
      visible: visible,
      child: Container(
        width: double.infinity,
        height: height,
        alignment: Alignment.center,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
        ),
      ),
    );
  }

  /// TODO:Request

  void _loadDelegateMoreData() {
    if (_detailCurrentIndex == Map3NodeDetailType.tx_log) {
      _loadTxLogMoreData();
    } else {
      _loadUserListMoreData();
    }
  }

  _refreshDelegateData() {
    if (_detailCurrentIndex == Map3NodeDetailType.tx_log) {
      _loadTxLogData();
    } else {
      _loadUserListData();
    }
  }

  // txLog
  _loadTxLogData() async {
    if (_nodeAddress.isEmpty) {
      if (mounted) {
        setState(() {
          _showLoadingTxLog = false;
        });
      }
      return;
    }

    try {
      _currentPageTxLog = 1;
      _loadTxLogsFinished = false;
      List<HynTransferHistory> tempMemberList = await _atlasApi.getMap3StakingLogList(
        _nodeAddress,
        page: _currentPageTxLog,
      );

      if (mounted) {
        setState(() {
          _showLoadingTxLog = false;
          _txLogList = tempMemberList;
          _loadDataBloc.add(RefreshSuccessEvent());
        });
      }
    } catch (e) {
      // setState(() {
      //   _showLoadingTxLog = false;
      //   _loadDataBloc.add(RefreshFailEvent());
      // });
    }
  }

  Future _loadTxLogMoreData() async {
    if (_nodeAddress.isEmpty) {
      if (mounted) {
        setState(() {
          _showLoadingTxLog = false;
        });
      }
      return;
    }

    try {
      _currentPageTxLog++;
      print("[getMap3StakingLogList]  more, _currentPage:$_currentPageTxLog");

      List<HynTransferHistory> tempMemberList = await _atlasApi.getMap3StakingLogList(
        _nodeAddress,
        page: _currentPageTxLog,
      );

      if (tempMemberList.length > 0) {
        _txLogList.addAll(tempMemberList);
        _loadDataBloc.add(LoadingMoreSuccessEvent());
      } else {
        _loadTxLogsFinished = true;
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

  // userList
  void _loadUserListData() async {
    if (_nodeAddress.isEmpty) {
      if (mounted) {
        setState(() {
          _showLoadingUserList = false;
        });
      }
      return;
    }

    try {
      _currentPageUserList = 1;
      _loadUserListFinished = false;
      List<Map3UserEntity> tempMemberList = await _atlasApi.getMap3UserList(
        _nodeId,
        page: _currentPageUserList,
      );

      // print("[widget] --> build, length:${tempMemberList.length}");
      if (mounted) {
        setState(() {
          _showLoadingUserList = false;

          if (tempMemberList.length > 0) {
            _userList = [];
          }
          _userList.addAll(tempMemberList);
          _loadDataBloc.add(RefreshSuccessEvent());
        });
      }
    } catch (e) {
      // if (mounted) {
      //   setState(() {
      //     _loadDataBloc.add(LoadMoreFailEvent());
      //   });
      // }
    }
  }

  void _loadUserListMoreData() async {
    if (_nodeAddress.isEmpty) {
      if (mounted) {
        setState(() {
          _showLoadingUserList = false;
        });
      }
      return;
    }

    _currentPageUserList++;

    try {
      List<Map3UserEntity> tempMemberList = await _atlasApi.getMap3UserList(
        _nodeId,
        page: _currentPageUserList,
        size: 10,
      );

      if (tempMemberList.length > 0) {
        _userList.addAll(tempMemberList);
        _loadDataBloc.add(LoadingMoreSuccessEvent());
      } else {
        _loadUserListFinished = true;
        _loadDataBloc.add(LoadMoreEmptyEvent());
      }
      setState(() {});
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadDataBloc.add(LoadMoreFailEvent());
        });
      }
    }
  }

  // lastTx
  _loadLastPendingTxData() async {
    if (_nodeAddress.isEmpty || _walletAddress.isEmpty) {
      return;
    }

    List<HynTransferHistory> pendingList = await AtlasApi().getTxsList(
      _walletAddress,
      map3Address: _nodeAddress,
      // status: [TransactionStatus.success],
      status: [TransactionStatus.pending, TransactionStatus.pending_for_receipt],
      size: 1,
    );

    if (pendingList?.isNotEmpty ?? false) {
      var firstObject = pendingList.first;

      var now = DateTime.now().millisecondsSinceEpoch;
      var last = firstObject.timestamp * 1000;
      var isOver6Seconds = (now - last) > (10 * 1000);
      print(
          "[Map3Detail] _clearLastPendingTx, now:$now, last:$last, over:${(now - last)},  isOver6Seconds:$isOver6Seconds");

      if (isOver6Seconds) {
        _lastPendingTx = null;
      } else {
        _lastPendingTx = firstObject;
      }
    } else {
      _lastPendingTx = null;
    }

    if (mounted) {
      setState(() {});
    }
  }

  // refresh
  Future _refreshData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      await _loadDetailData();

      await _loadDetailDataInAtlas();

      _refreshDelegateData();

      _loadLastPendingTxData();

      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadDataBloc.add(RefreshSuccessEvent());
        });
      }

      if (_canRenewNextPeriod && _lastPendingTx == null) {
        _showEditPreNextAlert();
      }
    } catch (e) {
      logger.e(e);
      LogUtil.toastException(e);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadDataBloc.add(RefreshFailEvent());
        });
      }
    }
  }

  _loadDetailData() async {
    _map3infoEntity = await _atlasApi.getMap3Info(_walletAddress, _nodeId);

    if (mounted && _map3infoEntity != null) {
      setState(() {});
    }
  }

  _loadDetailDataInAtlas() async {
    if (_nodeAddress.isEmpty) {
      return;
    }

    print("[$runtimeType]  WalletConfig.netType:${WalletConfig.netType}");

    var map3Address = EthereumAddress.fromHex(_nodeAddress);
    _map3nodeInformationEntity = await _web3Client.getMap3NodeInformation(map3Address);

    var microDelegations = _map3nodeInformationEntity?.microdelegations ?? [];
    if (microDelegations?.isEmpty ?? true) {
      return;
    }

    var creatorAddress = _nodeCreatorAddress.toLowerCase();
    var joinerAddress = _walletAddress.toLowerCase();

    int tag = 0;
    for (var item in microDelegations) {
      var delegateAddress = item.delegatorAddress.toLowerCase();

      if (delegateAddress == creatorAddress) {
        _microDelegationsCreator = item;
        tag += 1;
      }

      if (delegateAddress == joinerAddress && _walletAddress.isNotEmpty) {
        _microDelegationsJoiner = item;
        tag += 1;
      }

      if (tag == 2) {
        break;
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

    Application.router.navigateTo(context, Routes.map3node_my_page_reward_new);
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

  void _renewAction() async {
    if (!_canRenewNextPeriod) return;

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

    LogUtil.printMessage("[Map3NodeDetail] _next action, result:$result");

    if (result != null && result is Map && result["result"] is bool) {
      _loadLastPendingTxData();
      _refreshDelegateData();
    }
  }
}

class Map3NodeDetailTabBarModel {
  String name;
  Map3NodeDetailType type;
  Map3NodeDetailTabBarModel(this.name, this.type);
}

enum Map3NodeDetailType {
  tx_log,
  user_list,
}
