import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/config.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/load_data_bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/inject/injector.dart';
import 'package:titan/src/components/quotes/bloc/bloc.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/memory_cache.dart';
import 'package:titan/src/domain/transaction_interactor.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/map3page/map3_node_page.dart';
import 'package:titan/src/pages/node/map3page/map3_node_pronounce_page.dart';
import 'package:titan/src/pages/node/model/contract_delegator_item.dart';
import 'package:titan/src/pages/node/model/contract_detail_item.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/pages/node/model/map3_node_util.dart';
import 'package:titan/src/pages/node/model/node_item.dart';
import 'package:titan/src/pages/node/widget/custom_stepper.dart';
import 'package:titan/src/pages/node/widget/node_active_contract_widget.dart';
import 'package:titan/src/pages/node/widget/node_join_member_widget.dart';
import 'package:titan/src/pages/wallet/api/etherscan_api.dart';
import 'package:titan/src/pages/webview/webview.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart' as all_page_state;
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/widget/enter_wallet_password.dart';
import 'package:titan/src/widget/wallet_widget.dart';
import 'package:web3dart/json_rpc.dart';
import '../../../global.dart';
import 'map3_node_create_contract_page.dart';
import 'map3_node_create_wallet_page.dart';
import 'package:characters/characters.dart';

class Map3NodeContractDetailPage extends StatefulWidget {
  final int contractId;
  TransactionInteractor transactionInteractor = Injector.of(Keys.rootKey.currentContext).transactionInteractor;

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
  bool _haveNextEpisode = false;
  bool _visible = false;
  bool _isTransferring = false;
  String _lastActionTitle = "";
  String _actingTitle = "";
  bool _isDelegated = false; // todo:判断当前(钱包=用户)是否参与抵押, 不一定是180天
  VoidCallback onPressed = () {};
  var _actionTitle = "";

  LoadDataBloc _loadDataBloc = LoadDataBloc();
  int _currentPage = 0;
  NodeApi _nodeApi = NodeApi();
  List<ContractDelegateRecordItem> _delegateRecordList = [];

  get _stateColor => Map3NodeUtil.stateColor(_contractState);

  get _durationType => _contractNodeItem?.contract?.durationType ?? 0;

  get _isNoWallet => _wallet == null;

  get _isOwner => _contractDetailItem != null && _contractDetailItem.isOwner;

  get _is180DaysContract => (_durationType == 2);

  get _canGetPercent50Rewards => _isDelegated && _is180DaysContract;

  get _isUserDelegatable => double.parse(_contractNodeItem?.remainDelegation) > 0;

  get _currentStep {
    if (_contractState == null) return 0;

    int value = 0;

    if (_is180DaysContract && _userDelegateState != null) {
      switch (_userDelegateState) {
        case UserDelegateState.PRE_CREATE:
        case UserDelegateState.PENDING:
        case UserDelegateState.CANCELLED:
        case UserDelegateState.CANCELLED_COLLECTED:
        case UserDelegateState.PRE_CANCELLED_COLLECTED:
        case UserDelegateState.FAIL:
          value = 0;
          break;

        case UserDelegateState.ACTIVE:
          value = 1;
          break;

        case UserDelegateState.HALFDUE:
        case UserDelegateState.PRE_HALFDUE_COLLECTED:
        case UserDelegateState.HALFDUE_COLLECTED:
          value = 2;
          break;

        case UserDelegateState.DUE:
          value = 3;
          break;

        case UserDelegateState.PRE_DUE_COLLECTED:
        case UserDelegateState.DUE_COLLECTED:
          value = 4;
          break;

        default:
          break;
      }
    } else {
      switch (_contractState) {
        case ContractState.PRE_CREATE:
        case ContractState.PENDING:
        case ContractState.CANCELLED:
        case ContractState.CANCELLED_COMPLETED:
        case ContractState.FAIL:
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
    if (_contractState == null) return 0.0;

    double value = 0.0;

    if (_is180DaysContract && _userDelegateState != null) {
      switch (_userDelegateState) {
        case UserDelegateState.PRE_CREATE:
        case UserDelegateState.PENDING:
        case UserDelegateState.CANCELLED:
        case UserDelegateState.CANCELLED_COLLECTED:
        case UserDelegateState.PRE_CANCELLED_COLLECTED:
        case UserDelegateState.FAIL:
          value = _contractNodeItem.remainProgress;
          break;

        case UserDelegateState.ACTIVE:
          value = _contractNodeItem.expectHalfDueProgress;
          break;

        case UserDelegateState.HALFDUE:
        case UserDelegateState.PRE_HALFDUE_COLLECTED:
        case UserDelegateState.HALFDUE_COLLECTED:
          value = _contractNodeItem.expectDueProgress;
          break;

        case UserDelegateState.DUE:
        case UserDelegateState.PRE_DUE_COLLECTED:
        case UserDelegateState.DUE_COLLECTED:
          value = 0;
          break;

        default:
          break;
      }
    } else {
      switch (_contractState) {
        case ContractState.PRE_CREATE:
        case ContractState.PENDING:
        case ContractState.CANCELLED:
        case ContractState.CANCELLED_COMPLETED:
        case ContractState.FAIL:
          value = _contractNodeItem.remainProgress;

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

  get _contractStateDesc {
    if (_contractState == null) {
      return S.of(context).wait_to_launch;
    }
    ;

    var _contractStateDesc = "";

    switch (_contractState) {
      case ContractState.PRE_CREATE:
      case ContractState.PENDING:
        _contractStateDesc = S.of(context).wait_to_launch;
        break;

      case ContractState.ACTIVE:
        _contractStateDesc = S.of(context).contract_running;
        break;

      case ContractState.DUE:
        _contractStateDesc = S.of(context).contract_had_expired;
        break;

      case ContractState.CANCELLED:
      case ContractState.CANCELLED_COMPLETED:
      case ContractState.FAIL:
        _contractStateDesc = S.of(context).launch_fail;
        break;

      case ContractState.DUE_COMPLETED:
        _contractStateDesc = S.of(context).contract_had_stop;
        break;

      default:
        break;
    }
    return _contractStateDesc;
  }

  get _contractNotifyDetail {
    if (_userDelegateState == null) {
      return S.of(context).wait_block_chain_verification;
    }
    ;

    var _contractNotifyDetail = "";

    switch (_userDelegateState) {
      // create
      case UserDelegateState.PRE_CREATE:
      case UserDelegateState.PENDING:
        if (double.parse(_contractDetailItem?.amountPreDelegation ?? "0") == 0) {
          _contractNotifyDetail = "";
        } else {
          var input = "${FormatUtil.amountToString(_contractDetailItem.amountPreDelegation)}HYN";
          _contractNotifyDetail = S.of(context).your_last_input_to_contract_func(input, S.of(context).task_pending);
        }
        break;

      // cancel
      case UserDelegateState.CANCELLED:
        _contractNotifyDetail = S.of(context).contract_launch_fail_please_get_back;

        break;

      case UserDelegateState.FAIL:
        if (double.parse(_contractDetailItem?.amountPreDelegation ?? "0") > 0) {
          var input = "${FormatUtil.amountToString(_contractDetailItem.amountPreDelegation)}HYN";
          _contractNotifyDetail = S.of(context).your_last_input_to_contract_func(input, S.of(context).task_pending);
        }
        break;

      case UserDelegateState.PRE_CANCELLED_COLLECTED:
      case UserDelegateState.PRE_HALFDUE_COLLECTED:
      case UserDelegateState.PRE_DUE_COLLECTED:
        _contractNotifyDetail = S.of(context).collect_request_have_post_please_wait_hint;
        break;

      case UserDelegateState.CANCELLED_COLLECTED:
        _contractNotifyDetail = S.of(context).recovered_invested_capital;
        break;

      case UserDelegateState.HALFDUE_COLLECTED:
        _contractNotifyDetail = S.of(context).happy_get_half_reward_hint;
        break;

      case UserDelegateState.DUE_COLLECTED:
        /*if (double.parse(_contractDetailItem?.withdrawn??"0") == 0) {
          _contractNotifyDetail = "";
        } else {
          var output = "${FormatUtil.amountToString(_contractDetailItem.withdrawn)}HYN";
          _contractNotifyDetail = S.of(context).your_last_output_to_contract_func(output, S.of(context).task_finished);
        }*/

        if (double.parse(_contractDetailItem.lastRecord.amount) == 0) {
          _contractNotifyDetail = "";
        } else {
          BillsOperaState operaState = enumBillsOperaStateFromString(_contractDetailItem.lastRecord.operaType);
          var amount = "0";
          if (operaState == BillsOperaState.WITHDRAW) {
            amount = _contractDetailItem.lastRecord.amount;
          } else {
            amount = _contractDetailItem.withdrawn;
          }
          var output = "${FormatUtil.amountToString(amount)}HYN";
          _contractNotifyDetail = S.of(context).your_last_output_to_contract_func(output, S.of(context).task_finished);
        }

        break;

      default:
        break;
    }

    return _contractNotifyDetail;
  }

  get _contractStateDetail {
    if (_contractState == null) {
      return S.of(context).wait_block_chain_verification;
    }
    ;

    var _contractStateDetail = "";
    switch (_contractState) {
      case ContractState.PRE_CREATE:
      case ContractState.PENDING:
        if (double.parse(_contractNodeItem.remainDelegation) > 0) {
          var remainDelegation = FormatUtil.amountToString(_contractNodeItem.remainDelegation) + "HYN";
          _contractStateDetail = S.of(context).remain + remainDelegation;
        } else {
          _contractStateDetail = S.of(context).delegation_full_will_active_hint;
        }

        break;

      case ContractState.ACTIVE:
        var suffix = S.of(context).expire_date;
        _contractStateDetail =
            FormatUtil.timeStringSimple(context, _contractNodeItem.completeSecondsLeft.toDouble()) + suffix;
        break;

      case ContractState.DUE:
        _contractStateDetail = S.of(context).expired_can_withdraw_rewards;
        break;

      case ContractState.CANCELLED:
        _contractStateDetail = S.of(context).launch_fail;
        break;

      case ContractState.DUE_COMPLETED:
        _contractStateDetail = S.of(context).congratulation_reward_withdrawn;

        break;

      case ContractState.CANCELLED_COMPLETED:
      case ContractState.FAIL:
        _contractStateDetail = S.of(context).launch_fail;
        break;

      default:
        break;
    }

    if (_userDelegateState != null && _is180DaysContract) {
      switch (_userDelegateState) {
        case UserDelegateState.ACTIVE:
          var pre = S.of(context).left;
          var suffix = "，${S.of(context).can_withdraw_fifty_reward}";
          _contractStateDetail =
              pre + FormatUtil.timeStringSimple(context, _contractNodeItem.halfCompleteSecondsLeft) + suffix;
          break;

        case UserDelegateState.HALFDUE:
          _contractStateDetail = S.of(context).can_withdraw_fifty_reward;
          break;

        case UserDelegateState.PRE_HALFDUE_COLLECTED:
        case UserDelegateState.HALFDUE_COLLECTED:
          var suffix = S.of(context).expire_date;
          var pre = S.of(context).left;
          _contractStateDetail =
              pre + FormatUtil.timeStringSimple(context, _contractNodeItem.halfCompleteSecondsLeft) + suffix;
          break;

        default:
          break;
      }
    }
    return _contractStateDetail;
  }

  void _initBottomButtonData() {
    switch (_contractState) {
      case ContractState.PENDING:
        _actionTitle = _isDelegated ? S.of(context).increase_investment : S.of(context).join_delegate;
        _visible = true;
        break;

      case ContractState.CANCELLED:
        _actionTitle = S.of(context).withdrawRefund;
        _visible = _isDelegated;
        break;

      case ContractState.DUE:
        _actionTitle = S.of(context).extract;
        _visible = _isDelegated;
        break;

      default:
        _visible = false;
        break;
    }

    if (_userDelegateState != null && _isDelegated) {
      switch (_userDelegateState) {
        case UserDelegateState.HALFDUE:
          _actionTitle = S.of(context).withdraw_fifty_revenue;
          _visible = _canGetPercent50Rewards;
          break;

        case UserDelegateState.PENDING:
          BillsRecordState billsRecordState = enumBillsRecordStateFromString(_contractDetailItem.lastRecord?.state);
          switch (billsRecordState) {
            case BillsRecordState.PRE_CREATE:
              _visible = false;
              _actionTitle = "";
              break;

            case BillsRecordState.FAIL:
              _visible = _isUserDelegatable;
              _actionTitle = S.of(context).reset_input_contract;
              break;

            case BillsRecordState.CONFIRMED:
              _visible = _isUserDelegatable;
              _actionTitle = S.of(context).increase_investment;
              break;
          }

          break;

        case UserDelegateState.PRE_CREATE:
        case UserDelegateState.PRE_CANCELLED_COLLECTED:
        case UserDelegateState.CANCELLED_COLLECTED:
        case UserDelegateState.ACTIVE:
        case UserDelegateState.PRE_HALFDUE_COLLECTED:
        case UserDelegateState.HALFDUE_COLLECTED:
        case UserDelegateState.PRE_DUE_COLLECTED:
        case UserDelegateState.DUE_COLLECTED:
          _visible = false;
          break;

        case UserDelegateState.FAIL:
          _actionTitle = S.of(context).reset_input_contract;
          if (double.parse(_contractDetailItem?.amountPreDelegation ?? "0") > 0) {
            _visible = false;
            _actionTitle = "";
          }
          break;

        case UserDelegateState.DUE:
        case UserDelegateState.CANCELLED:
          BillsRecordState billsRecordState = enumBillsRecordStateFromString(_contractDetailItem.lastRecord?.state);
          switch (billsRecordState) {
            /*case BillsRecordState.PRE_CREATE:// PRE_DUE_COLLECTED, PRE_HALFDUE_COLLECTED, PRE_CANCELLED_COLLECTED
            case BillsRecordState.CONFIRMED: // DUE_COLLECTED, HALFDUE_COLLECTED ,CANCELLED_COLLECTED
              _visible = false;
              _actionTitle = "";
              break;*/

            case BillsRecordState.FAIL:
              BillsOperaState operaState = enumBillsOperaStateFromString(_contractDetailItem.lastRecord.operaType);
              if (operaState == BillsOperaState.WITHDRAW) {
                _visible = true;
                _actionTitle = S.of(context).reset_output_contract;
              }

              break;

            default:
              break;
          }
          break;

        default:
          break;
      }
    }

    if (_visible) {
      switch (_contractState) {
        case ContractState.PENDING:
          onPressed = () {
            if (_isNoWallet) {
              _pushWalletManagerAction();
            } else {
              _actingTitle = "进行中...";
              _joinContractAction();
            }
          };
          break;

        default:
          onPressed = () {
            if (_isNoWallet) {
              _pushWalletManagerAction();
            } else {
              _actingTitle = S.of(context).extracting;
              _collectAction();
            }
          };
          break;
      }

      _lastActionTitle = _actionTitle;
    } else {
      _actionTitle = "";
      _lastActionTitle = "";
    }
  }

  get _isShowLaunchDate =>
      _contractState.index <= ContractState.PENDING.index && double.parse(_contractNodeItem.remainDelegation) > 0;

  @override
  void onCreated() {
    _wallet = WalletInheritedModel.of(context).activatedWallet?.wallet;
    getContractDetailData();

    BlocProvider.of<QuotesCmpBloc>(context).add(UpdateGasPriceEvent());

    super.onCreated();
  }

  @override
  void initState() {
    super.initState();
  }

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
        appBar: AppBar(centerTitle: true, title: Text(S.of(context).node_contract_detail), actions: <Widget>[InkWell(
          onTap: (){
            Application.router.navigateTo(
                context,
                Routes.map3node_share_page +
                    "?contractNodeItem=${FluroConvertUtils.object2string(_contractNodeItem.toJson())}");
          },
          child: Padding(
            padding: EdgeInsets.only(right: 15),
            child: Icon(
              Icons.share,
              color: Colors.white,
            ),
          ),
        )],),
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
    if (_currentState != null || _contractNodeItem?.contract == null) {
      return Scaffold(
        //appBar: AppBar(centerTitle: true, title: Text(S.of(context).node_contract_detail)),
        body: AllPageStateContainer(_currentState, () {
          setState(() {
            _currentState = all_page_state.LoadingState();
            getContractDetailData();
          });
        }),
      );
    }

    var remainDay = S.of(context).left + FormatUtil.timeStringSimple(context, _contractNodeItem.launcherSecondsLeft);

    return Padding(
      padding: EdgeInsets.only(bottom: _visible ? 48 : 0),
      child: LoadDataContainer(
          bloc: _loadDataBloc,
          //enablePullDown: false,
          onRefresh: getContractDetailData,
          onLoadingMore: getJoinMemberMoreData,
          child: CustomScrollView(
            slivers: <Widget>[
              if (_haveNextEpisode) SliverToBoxAdapter(child: _topNextEpisodeNotifyWidget()),
              // 0.合约介绍信息
              SliverToBoxAdapter(child: _getMap3NodeInfoItem(context, _contractNodeItem),),
              _spacer(),
              SliverToBoxAdapter(child: _nodeWidget(context, _contractNodeItem.contract),),
              _spacer(),
              // 3.合约状态信息
              // 3.1最近已操作状态通知 + 总参与抵押金额及期望收益
              SliverToBoxAdapter(child: _contractNotifyWidget()),
              SliverToBoxAdapter(child: _lineSpacer()),
              _spacer(),

              // 3.1合约进度状态
              SliverToBoxAdapter(child: _contractProgressWidget()),
              _spacer(),

              // 4.参与人员列表信息
              SliverToBoxAdapter(
                child: Material(
                  color: Colors.white,
                  child: NodeJoinMemberWidget(
                    "${widget.contractId}",
                    remainDay,
                    _contractNodeItem.ownerName,
                    _contractNodeItem.shareUrl,
                    isShowInviteItem: false,
                    loadDataBloc: _loadDataBloc,
                  ),
                ),
              ),
              _spacer(),

              // 5.合约流水信息
              SliverToBoxAdapter(child: _delegateRecordHeaderWidget()),
              SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                return _delegateRecordItemWidget(_delegateRecordList[index]);
              }, childCount: _delegateRecordList.length)),
            ],
          )),
    );
  }

  Widget _topNextEpisodeNotifyWidget() {
    return Container(
      color: HexColor("#1FB9C7").withOpacity(0.08),
      //margin: const EdgeInsets.only(top: 8.0),
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
                "第二期已经开启，前往查看  >>",
                style: TextStyle(fontSize: 12, color: HexColor("#5C4304")),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomSureButtonWidget() {
    return Visibility(
      visible: _visible,
      child: Positioned(
        bottom: 0,
        height: _visible ? 48 : 0.01,
        width: MediaQuery.of(context).size.width,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 4.0,
              ),
            ],
          ),
          child: RaisedButton(
            textColor: Colors.white,
            disabledColor: Colors.grey[600],
            disabledTextColor: Colors.white,
            color: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
                side: BorderSide(color: _isTransferring ? Colors.grey[600] : Theme.of(context).primaryColor),
                borderRadius: BorderRadius.circular(0)),
            child: Text(_isTransferring ? _actingTitle : _lastActionTitle,
                style: TextStyle(fontSize: 16, color: Colors.white70)),
            onPressed: !_isTransferring ? onPressed : null,
          ),
        ),
      ),
    );
  }

  Widget _getMap3NodeInfoItem(BuildContext context, ContractNodeItem contractNodeItem) {
    if (contractNodeItem == null) return Container();

    var state = contractNodeItem.stateValue;

    var isNotFull = int.parse(contractNodeItem.remainDelegation) > 0;
    var fullDesc = "";
    var dateDesc = "";
    var isPending = false;
    switch (state) {
      case ContractState.PRE_CREATE:
      case ContractState.PENDING:
        dateDesc = S.of(context).left + FormatUtil.timeStringSimple(context, contractNodeItem.launcherSecondsLeft);
        dateDesc = S.of(context).active + dateDesc;
        fullDesc = !isNotFull ? S.of(context).delegation_amount_full : "";
        isPending = true;
        break;

      case ContractState.ACTIVE:
        dateDesc = S.of(context).left + FormatUtil.timeStringSimple(context, contractNodeItem.completeSecondsLeft);
        dateDesc = S.of(context).expired + dateDesc;
        break;

      case ContractState.DUE:
        dateDesc = S.of(context).contract_had_expired;
        break;

      case ContractState.CANCELLED:
      case ContractState.CANCELLED_COMPLETED:
      case ContractState.FAIL:
        dateDesc = S.of(context).launch_fail;
        break;

      case ContractState.DUE_COMPLETED:
        dateDesc = S.of(context).contract_had_stop;
        break;

      default:
        break;
    }


    String _pronounceText = "";
    _pronounceText = "大家快来参与我的节点吧，收益高高，收益真的很高，大家相信我，不会错的，快投吧，一会儿没机会了……";


    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16, top: 16, bottom: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                Image.asset(
                  "res/drawable/map3_node_default_avatar.png",
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                ),
                SizedBox(
                  width: 6,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text.rich(TextSpan(children: [
                      TextSpan(
                          text: "天道酬勤唐唐", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      TextSpan(text: " "+ S.of(context).number + "${contractNodeItem.contractCode ?? ""}", style: TextStyle(fontSize: 13, color: HexColor("#333333"))),
                    ])),
                    Container(
                      height: 4,
                    ),
                    Text("节点地址 ${UiUtil.shortEthAddress(contractNodeItem.owner, limitLength: 6)}", style: TextStyles.textC9b9b9bS12),
                  ],
                ),
                Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(dateDesc, style: TextStyle(color: Map3NodeUtil.stateColor(state), fontSize: 12)),
                    Container(
                      height: 4,
                    ),
                    Container(
                      color: HexColor("#1FB9C7").withOpacity(0.08),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text("第一期", style: TextStyle(fontSize: 12, color: HexColor("#5C4304"))),
                    ),
                  ],
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 12, right: 36),
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "节点公告：",
                        style: TextStyle(fontSize: 12, color: HexColor("#999999")),
                      ),
                      Flexible(
                        child: Text(
                          _pronounceText,
                          maxLines: 3,
                          textAlign: TextAlign.justify,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, color: HexColor("#333333")),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: InkWell(
                      //color: HexColor("#FF15B2D2"),
                      //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      onTap: () async{
                        String text = await Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                Map3NodePronouncePage()));
                        if (text.isNotEmpty) {
                          _pronounceText = text;
                          print("[Pronounce] _pronounceText:${_pronounceText}");
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Image.asset(
                            "res/drawable/map3_node_edit.png",
                            width: 12,
                            height: 12,
                          ),
                          SizedBox(width: 4,),
                          Text("编辑",
                              style: TextStyle(fontSize: 14, color: HexColor("#1F81FF"))),
                        ],
                      ),
                      //style: TextStyles.textC906b00S13),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              child: Divider(height: 1, color: Color(0x2277869e)),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                      Text("期满自动续约", style: TextStyle(color: HexColor("#333333"), fontSize: 14)),
                    ],
                  ),
                  Spacer(),
                  SizedBox(
                    height: 30,
//                width: 80,
                    child: InkWell(
                      //color: HexColor("#FF15B2D2"),
                      //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      onTap: () {
                        Application.router.navigateTo(
                            context, Routes.map3node_contract_detail_page + "?contractId=${contractNodeItem.id}");
                      },
                      child: Row(
                        children: <Widget>[
                          Text("已开启",
                              style: TextStyle(fontSize: 14, color: HexColor("#008EAA"))),
                          Image.asset(
                            "res/drawable/map3_node_arrow.png",
                            width: 12,
                            height: 12,
                          ),
                        ],
                      ),
                      //style: TextStyles.textC906b00S13),
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

  Widget _nodeWidget(BuildContext context, NodeItem nodeItem) {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          _nodeIntroductionWidget(context, nodeItem),
          _nodeBrowserWidget(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              height: 2,
            ),
          ),
          _nodeServerWidget(context, nodeItem),
        ],
      ),
    );
  }

  Widget _nodeBrowserWidget() {

    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: InkWell(
              onTap: (){
                print("[Pronounce] text:1111111");

              },
              child: Text(
                "节点细则",
                style: TextStyle(fontSize:14, color: HexColor("#1F81FF")),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: (){
                print("[Pronounce] text:2222");

              },
              child: Text(
                "访问节点",
                style: TextStyle(fontSize:14, color: HexColor("#1F81FF")),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nodeIntroductionWidget(BuildContext context, NodeItem nodeItem) {
    //var nodeItem = widget.contractNodeItem.contract;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        //mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Image.asset(
            "res/drawable/ic_map3_node_item_2.png",
            width: 62,
            height: 63,
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
                    Expanded(child: Text(nodeItem.name, style: TextStyle(fontWeight: FontWeight.bold)))
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                          "启动所需" +
                              " ${FormatUtil.formatTenThousandNoUnit(nodeItem.minTotalDelegation)}" +
                              S.of(context).ten_thousand,
                          style: TextStyles.textC99000000S13,
                          maxLines: 1,
                          softWrap: true),
                      Text("  |  ", style: TextStyle(fontSize: 12, color: HexColor("000000").withOpacity(0.2))),
                      Text(S.of(context).n_day(nodeItem.duration.toString()), style: TextStyles.textC99000000S13)
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: <Widget>[
              Text("${FormatUtil.formatPercent(nodeItem.annualizedYield)}", style: TextStyles.textCff4c3bS20),
              Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: Text(S.of(context).annualized_rewards, style: TextStyles.textC99000000S13),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _nodeServerWidget(BuildContext context, NodeItem nodeItem, {String provider="", String region=""}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [1, 2, 3, 4, 5, 6].map((value) {

          var title = "";
          var detail = "";
          switch (value) {
            case 1:
              title = S.of(context).service_provider;
              detail = provider;
              break;

            case 2:
              title = S.of(context).node_location;
              detail = region;
              break;

            case 3:
              title = "管理费";
              detail = "20%";
              break;

            case 4:
              title = "自动续约";
              detail = "是";
              break;

            case 5:
              title = "节点公告";
              detail = "欢迎参加我的合约，前10名参与者返10%管理。";
              break;

            default:
              return SizedBox(
                height: 8,
              );
              break;
          }

          return Padding(
            padding: EdgeInsets.only(top: value == 1 ? 0:12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    width: 80,
                    child:
                    Text(title, style: TextStyle(fontSize: 14, color: HexColor("#92979A")),)),
                Expanded(child: Text(detail, style: TextStyle(fontSize: 15, color: HexColor("#333333")), maxLines: 2, overflow: TextOverflow.ellipsis,))
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _contractNotifyWidget() {
    if (!_isDelegated || _contractDetailItem == null || _userDelegateState == null) {
      return Container();
    }

    var amountDelegation = FormatUtil.amountToString(_contractDetailItem.amountDelegation);
    var total = double.parse(_contractDetailItem.expectedYield) + double.parse(_contractDetailItem.amountDelegation);
    var expectedYield = FormatUtil.amountToString(total.toString());
    var commission = FormatUtil.amountToString(_contractDetailItem.commission);
    var textColor = _userDelegateState == UserDelegateState.CANCELLED ? HexColor("#B51414") : HexColor("#5C4304");
    var withdrawn = FormatUtil.amountToString(_contractDetailItem.withdrawn) + "HYN";
    var managerTip = Map3NodeUtil.managerTip(
        _contractNodeItem.contract, double.parse(_contractDetailItem.amountDelegation),
        isOwner: _isOwner);
    var endProfit =
        Map3NodeUtil.getEndProfit(_contractNodeItem.contract, double.parse(_contractDetailItem.amountDelegation));
    print(
        '[Detail] commission:$commission vs $managerTip, expectedYield:$expectedYield vs $endProfit ,withdrawn: $withdrawn}');

    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if ((_contractNotifyDetail as String).isNotEmpty)
            Container(
              color: HexColor("#1FB9C7").withOpacity(0.08),
              //margin: const EdgeInsets.only(top: 8.0),
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
                        style: TextStyle(fontSize: 12, color: textColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 18, top: 12),
                child: Text("我的金额（HYN）", style: TextStyle(fontSize: 16, color: HexColor("#333333"))),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: RichText(text: TextSpan(
                text: "总额: ",
                style: TextStyle(fontSize: 11, color: HexColor("#333333"), fontWeight: FontWeight.normal),
                children: [
                  TextSpan(
                    text: amountDelegation,
                    style: TextStyle(fontSize: 22, color: HexColor("#BF8D2A"), fontWeight: FontWeight.w600),
                  )
                ]),),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              color: HexColor("#F2F2F2"),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Text(
                  "昨日收益 0",
                  style: TextStyle(fontSize: 11, color: HexColor("#333333")),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              color: HexColor("#F2F2F2"),
              height: 0.5,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [1, 0.5, 2, 0.5, 3, 0.5, 4].map((value) {
                String title = "";
                String detail = "0";
                Color color = HexColor("#000000");

                switch (value) {
                  case 1:
                    title = S.of(context).you_have_invested_hyn;
                    detail = amountDelegation;
                    break;

                  case 2:
                    title = "可提金额";
                    detail = commission;
                    break;

                  case 3:
                    title = S.of(context).expected_output_hyn;
                    detail = expectedYield;
                    color = HexColor("#B4985F");
                    break;

                  case 4:
                    title = _isOwner ? S.of(context).get_manage_tip_hyn : S.of(context).out_mange_tip_hyn;
                    detail = commission;
                    break;

                  default:
                    return Container(
                      height: 20,
                      width: 1.0,
                      color: HexColor("#000000").withOpacity(0.2),
                    );
                    break;
                }

                var isPreCreate = (_userDelegateState == UserDelegateState.PRE_CREATE);
                if (isPreCreate) {
                  detail = "0";
                }

                TextStyle style = TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.w600);

                return Expanded(
                  child: Center(
                      child: Column(
                    children: <Widget>[
                      Text(detail, style: style),
                      Container(
                        height: 4,
                      ),
                      Text(title, style: TextStyles.textC333S11),
                    ],
                  )),
                );
              }).toList(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 18, top: 0),
                child: Text("本期账单", style: TextStyle(fontSize: 16, color: HexColor("#333333"))),
              ),
            ],
          ),
          _profitWidget(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 18, top: 0),
                child: Text("二期预设(HYN)", style: TextStyle(fontSize: 16, color: HexColor("#333333"))),
              ),
            ],
          ),
          _profitWidget(),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Divider(height: 1, color: Color(0x2277869e)),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 18, right: 12),
            child: Row(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[

                    Text("你已开启跟随自动续约", style: TextStyle(color: HexColor("#333333"), fontSize: 14)),
                  ],
                ),
                Spacer(),
                SizedBox(
                  height: 30,
//                width: 80,
                  child: Switch(
                    activeColor: Theme.of(context).primaryColor,
                    value: true,
                    onChanged: (value){

                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _profitWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [1, 2, 3, 4, 5].map((value) {

          var title = "";
          var detail = "";
          switch (value) {
            case 1:
              title = "节点总抵押";
              detail = "1,000,000";
              break;

            case 2:
              title = "节点总收益";
              detail = "1,000";
              break;

            case 3:
              title = "本期抵押";
              detail = "2,000,000";
              break;

            case 4:
              title = "本期收益";
              detail = "1,000";
              break;

            case 5:
              title = "付管理费";
              detail = "100";
              break;

            default:
              return SizedBox(
                height: 12,
              );
              break;
          }

          return Padding(
            padding: EdgeInsets.only(top: value == 1 ? 0:12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    width: 80,
                    child:
                    Text(title, style: TextStyle(fontSize: 14, color: HexColor("#92979A")),)),
                Expanded(child: Text(detail, style: TextStyle(fontSize: 15, color: HexColor("#333333")), maxLines: 2, overflow: TextOverflow.ellipsis,))
              ],
            ),
          );
        }).toList(),
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
                if (_isShowLaunchDate)
                  Text(
                    S.of(context).launcher_time_left(
                        FormatUtil.timeStringSimple(context, _contractNodeItem.launcherSecondsLeft)),
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
    List<String> titles = [];
    List<int> subtitles = [];
    List<String> progressHints = [];

    if (_is180DaysContract) {
      titles = [
        S.of(context).create_time,
        S.of(context).launch_success,
        "中期发放50%奖励",
        "到期时间",
      ];
      subtitles = [
        _contractNodeItem.instanceStartTime,
        _contractNodeItem.instanceActiveTime,
        0,
        _contractNodeItem.instanceDueTime,
      ];
      progressHints = [
        "",
        S.of(context).n_day(90.toString()),
        S.of(context).n_day(90.toString()),
        ""
      ];
    } else {
      titles = [
        S.of(context).create_time,
        S.of(context).launch_success,
        "到期时间",
      ];
      subtitles = [
        _contractNodeItem.instanceStartTime,
        _contractNodeItem.instanceActiveTime,
        _contractNodeItem.instanceDueTime,
      ];
      progressHints = [
        "",
        S.of(context).n_day(_contractNodeItem.contract.duration.toString()),
        "",
      ];
    }

    //print('[detail] _currentStep:$_currentStep， _currentStepProgress：${_currentStepProgress}');
    return CustomStepper(
      tickColor: _stateColor,
      tickText: _contractStateDetail,
      currentStepProgress: _currentStepProgress,
      currentStep: _currentStep,
      steps: titles.map(
        (title) {
          var index = titles.indexOf(title);
          var subtitle = subtitles[index] > 0 ? FormatUtil.formatDate(subtitles[index]) : "";
          var date = progressHints[index];
          var textColor = _currentStep != index ? HexColor("#A7A7A7") : HexColor('#1FB9C7');

          bool isMiddle = titles.length == 5 && index == 2;

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

  Widget _spacer() {
    return SliverToBoxAdapter(
      child: Container(
        height: 10,
//        color: DefaultColors.colorf5f5f5,
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

  Widget _delegateRecordItemWidget(ContractDelegateRecordItem item) {
    String userAddress = shortBlockChainAddress(" ${item.userAddress}", limitCharsLength: 8);
    var operaState = enumBillsOperaStateFromString(item.operaType);
    var recordState = enumBillsRecordStateFromString(item.state);
    var isPengding = operaState == BillsOperaState.WITHDRAW && recordState == BillsRecordState.PRE_CREATE;
    var isWithdrawDelegatePengding = operaState == BillsOperaState.DELEGATE && recordState == BillsRecordState.PRE_CREATE || isPengding;

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
                    child: walletHeaderWidget(item.userName, address: item.userAddress),
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
                              text: "${item.userName}",
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
                                isPengding ? "*" : FormatUtil.amountToString(item.amount),
                                style: TextStyle(fontSize: 14, color: HexColor("#333333"), fontWeight: FontWeight.bold),
                              ),
                            ),
                            _billStateWidget(item)
                          ],
                        ),
                        Container(
                          height: 8.0,
                        ),
                        Text(FormatUtil.formatDate(item.createAt, isSecond: true),
                            style: TextStyle(fontSize: 10, color: HexColor("#999999"))),
                        if(_delegateRecordList.last != item && (_wallet?.getEthAccount()?.address ?? "") == item.userAddress
                          && isWithdrawDelegatePengding)
                          speedTransactionView(item)
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
    var operaState = enumBillsOperaStateFromString(item.operaType);
    var recordState = enumBillsRecordStateFromString(item.state);

    switch (recordState) {
      case BillsRecordState.PRE_CREATE:
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
              operaState == BillsOperaState.DELEGATE
                  ? S.of(context).input_confirm_pending
                  : S.of(context).output_confirm_pending,
              style: TextStyle(fontSize: 6, color: HexColor("#FFFFFF"), fontWeight: FontWeight.normal),
            ),
          ),
        );
        break;

      case BillsRecordState.FAIL:
        return Container(
          decoration: BoxDecoration(color: HexColor("#F2F2F2"), borderRadius: BorderRadius.all(Radius.circular(12.0))),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
            child: Text(
              operaState == BillsOperaState.DELEGATE
                  ? S.of(context).input_confirm_fail
                  : S.of(context).output_confirm_fail,
              style: TextStyle(fontSize: 6, color: HexColor("#CC2D1E"), fontWeight: FontWeight.normal),
            ),
          ),
        );
        break;

      default:
        if (operaState == BillsOperaState.DELEGATE) {
          return Container(
            decoration:
                BoxDecoration(color: HexColor("#F2F2F2"), borderRadius: BorderRadius.all(Radius.circular(12.0))),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
              child: Text(
                S.of(context).input_confirm_success,
                style: TextStyle(fontSize: 6, color: HexColor("#999999"), fontWeight: FontWeight.normal),
              ),
            ),
          );
        } else {
          return Container(
            decoration:
                BoxDecoration(color: HexColor("#1FB9C7"), borderRadius: BorderRadius.all(Radius.circular(12.0))),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
              child: Text(
                S.of(context).output_confirm_success,
                style: TextStyle(fontSize: 6, color: HexColor("#FFFFFF"), fontWeight: FontWeight.normal),
              ),
            ),
          );
        }
        break;
    }
  }

  Future getJoinMemberData() async {
    try {
      _currentPage = 0;
      _delegateRecordList = [];

      List<ContractDelegateRecordItem> tempMemberList =
          await _nodeApi.getContractDelegateRecord(widget.contractId, page: _currentPage);

      if (tempMemberList.length > 0) {
        _delegateRecordList.addAll(tempMemberList);
        _loadDataBloc.add(LoadingMoreSuccessEvent());
      } else {
        _loadDataBloc.add(LoadMoreEmptyEvent());
      }

      //setState(() {});
    } catch (e) {
      _loadDataBloc.add(LoadMoreFailEvent());

      //setState(() {});
    }
  }

  Future getJoinMemberMoreData() async {
    try {
      _currentPage++;
      List<ContractDelegateRecordItem> tempMemberList =
          await _nodeApi.getContractDelegateRecord(widget.contractId, page: _currentPage);

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

  Future getContractDetailData() async {
    try {
      // 0.
      if (_isNoWallet) {
        _contractNodeItem = await _api.getContractInstanceItem("${widget.contractId}");
      } else {
        _isDelegated = await _api.checkIsDelegatedContractInstance(widget.contractId);
        if (_isDelegated) {
          _contractDetailItem = await _api.getContractDetail(widget.contractId);
          _contractNodeItem = _contractDetailItem?.instance;

          _userDelegateState = enumUserDelegateStateFromString(_contractDetailItem?.state ?? "");
        } else {
          _contractNodeItem = await _api.getContractInstanceItem("${widget.contractId}");
        }
      }

      // 1.
      _contractState = _contractNodeItem.stateValue;
      print(
          '[contract] getContractInstanceItem,_isDelegated:$_isDelegated, contractState:$_contractState, userDelegateState:$_userDelegateState');

      // 2.
      await getJoinMemberData();
      _initBottomButtonData();

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

  Future _collectAction() async {
    if (_wallet == null || _contractDetailItem == null) {
      return;
    }

    AppSource source;
    if (Config.APP_SOURCE == 'TITAN') {
      source = AppSource.TITAN;
    } else {
      source = AppSource.STARRICH;
    }

    if (_contractNodeItem.appSource != source.index) {
      Fluttertoast.showToast(msg: "该节点并非创建于${S.of(context).app_name}，提取失败");
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
        if (mounted) {
          setState(() {
            _lastActionTitle = _actionTitle;
            _isTransferring = true;
          });
        }

        var gasPriceRecommend = QuotesInheritedModel.of(context, aspect: QuotesAspect.gasPrice).gasPriceRecommend;
        var gasPrice = gasPriceRecommend.average.toInt();

        var gasLimit = SettingInheritedModel.ofConfig(context).systemConfigEntity.collectMap3NodeCreatorGasLimit;
        if (_userDelegateState == UserDelegateState.HALFDUE) {
          gasLimit = SettingInheritedModel.ofConfig(context).systemConfigEntity.collectHalfMap3NodeGasLimit;
        } else {
          if (_isOwner) {
            int delegatorCount = _contractDetailItem.delegatorCount;
            if (delegatorCount <= 21) {
              gasLimit = SettingInheritedModel.ofConfig(context).systemConfigEntity.collectMap3NodeCreatorGasLimit21;
            } else if (delegatorCount > 21 && delegatorCount <= 41) {
              gasLimit = SettingInheritedModel.ofConfig(context).systemConfigEntity.collectMap3NodeCreatorGasLimit41;
            } else if (delegatorCount > 41 && delegatorCount <= 61) {
              gasLimit = SettingInheritedModel.ofConfig(context).systemConfigEntity.collectMap3NodeCreatorGasLimit61;
            } else {
              gasLimit = SettingInheritedModel.ofConfig(context).systemConfigEntity.collectMap3NodeCreatorGasLimit81;
            }
            print("[detail]  delegatorCount:$delegatorCount, gasLimit:$gasLimit");
          } else {
            gasLimit = SettingInheritedModel.ofConfig(context).systemConfigEntity.collectMap3NodePartnerGasLimit;
          }
        }

        var success = await _api.withdrawContractInstance(
            _contractNodeItem, WalletVo(wallet: _wallet), walletPassword, gasPrice, gasLimit);
        if (success == "success") {
          _broadcastContractAction();
        } else {
          Fluttertoast.showToast(msg: S.of(context).transfer_fail);

          if (mounted) {
            setState(() {
              _isTransferring = false;
            });
          }
        }
      } catch (_) {
        logger.e(_);

        if (mounted) {
          setState(() {
            _isTransferring = false;
          });
        }

        if (_ is PlatformException) {
          if (_.code == WalletError.PASSWORD_WRONG) {
            Fluttertoast.showToast(msg: S.of(context).password_incorrect);
          } else {
            Fluttertoast.showToast(msg: S.of(context).transfer_fail);
          }
        } else if (_ is RPCError) {
          Fluttertoast.showToast(msg: MemoryCache.contractErrorStr(_.message), toastLength: Toast.LENGTH_LONG);
        } else {
          Fluttertoast.showToast(msg: S.of(context).transfer_fail);
        }
      }
    });
  }

  void _pushNodeInfoAction() {
    if (_contractNodeItem != null) {
      print('url:${_contractNodeItem.remoteNodeUrl}');

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WebViewContainer(
                    initUrl: _contractNodeItem.remoteNodeUrl ?? "https://www.map3.network",
                    title: "",
                  )));
    }
  }

  void _pushTransactionDetailAction(ContractDelegateRecordItem item) {
    var isChinaMainland = SettingInheritedModel.of(context).areaModel?.isChinaMainland == true;
    var url = EtherscanApi.getTxDetailUrl(item.txHash, isChinaMainland);
    if (url != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WebViewContainer(
                    initUrl: url,
                    title: "",
                  )));
    }
  }

  void _pushWalletManagerAction() {
    Application.router.navigateTo(
        context, Routes.map3node_create_wallet + "?pageType=${Map3NodeCreateWalletPage.CREATE_WALLET_PAGE_TYPE_JOIN}");
  }

  void _joinContractAction() async {
    if (mounted) {
      setState(() {
        _lastActionTitle = _actionTitle;
        _isTransferring = true;
      });
    }

    var entryRouteName = Uri.encodeComponent(Routes.map3node_contract_detail_page);
    await Application.router.navigateTo(context,
        Routes.map3node_join_contract_page + "?entryRouteName=$entryRouteName&contractId=${_contractNodeItem.id}");
    _nextAction();
  }

  void _broadcastContractAction() async {
    var entryRouteName = Uri.encodeComponent(Routes.map3node_contract_detail_page);
    await Application.router.navigateTo(
        context,
        Routes.map3node_broadcast_success_page +
            "?entryRouteName=$entryRouteName&actionEvent=${Map3NodeActionEvent.COLLECT}");
    _nextAction();
  }

  _nextAction() {
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

  Widget speedTransactionView(ContractDelegateRecordItem recordItem) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        SizedBox(
          width: 50,
          child: FlatButton(
              padding: EdgeInsets.all(0),
              child: Text("加速"),
              onPressed: () {
                UiUtil.showDialogWidget(context,
                    content: Text("确认提交该操作无法保证能够成功加速您的原始交易。如果加速成功，您将被收取更高的交易费用。"),
                    actions: [
                      FlatButton(
                          child: Text('确认'),
                          onPressed: () async {
                            BillsOperaState operaState = enumBillsOperaStateFromString(_contractDetailItem.lastRecord.operaType);
                            if(operaState == BillsOperaState.WITHDRAW){
                              await widget.transactionInteractor.speedMap3Withdraw(recordItem.txHash, () {
                                Fluttertoast.showToast(
                                    msg: "已发送加速操作，请稍后刷新。", toastLength: Toast.LENGTH_LONG);
                              }, (exception) {
                                Fluttertoast.showToast(
                                    msg: "交易即将完成，无法加速。", toastLength: Toast.LENGTH_LONG);
                              });
                            }else{
                              await widget.transactionInteractor.speedMap3Delegate("0x1bc34ecbd3faf22e1874d1ac1cbbd3db4d289288ac3792a29331ba508f325f14", recordItem.txHash, () {
                                Fluttertoast.showToast(
                                    msg: "已发送加速操作，请稍后刷新。", toastLength: Toast.LENGTH_LONG);
                              }, (exception) {
                                Fluttertoast.showToast(
                                    msg: "交易即将完成，无法加速。", toastLength: Toast.LENGTH_LONG);
                              });
                            }
//                                            onWidgetRefreshCallback();
                            Navigator.pop(context);
                          }),
                      FlatButton(
                          child: Text('取消'),
                          onPressed: () async {
                            Navigator.pop(context);
                          })
                    ]);
              }),
        )
      ],
    );
  }

}
