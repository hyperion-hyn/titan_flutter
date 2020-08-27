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
import 'package:titan/src/components/quotes/bloc/bloc.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/data/cache/memory_cache.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/map3page/map3_node_exit_page.dart';
import 'package:titan/src/pages/node/map3page/map3_node_cancel_page.dart';
import 'package:titan/src/pages/node/map3page/map3_node_collect_page.dart';
import 'package:titan/src/pages/node/map3page/map3_node_pronounce_page.dart';
import 'package:titan/src/pages/node/model/contract_delegator_item.dart';
import 'package:titan/src/pages/node/model/contract_detail_item.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/pages/node/model/map3_node_util.dart';
import 'package:titan/src/pages/node/model/node_item.dart';
import 'package:titan/src/pages/node/widget/custom_stepper.dart';
import 'package:titan/src/pages/node/widget/node_join_member_widget.dart';
import 'package:titan/src/pages/wallet/api/etherscan_api.dart';
import 'package:titan/src/pages/webview/webview.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart' as all_page_state;
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/widget/enter_wallet_password.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/wallet_widget.dart';
import 'package:web3dart/json_rpc.dart';
import '../../../global.dart';
import 'map3_node_create_wallet_page.dart';
import 'map3_node_divide_page.dart';

class Map3NodeDetailPage extends StatefulWidget {
  final int contractId;

  Map3NodeDetailPage(this.contractId);

  @override
  _Map3NodeDetailState createState() => new _Map3NodeDetailState();
}

class _Map3NodeDetailState extends BaseState<Map3NodeDetailPage> {
  all_page_state.AllPageState _currentState = all_page_state.LoadingState();
  NodeApi _api = NodeApi();

  ContractDetailItem _contractDetailItem;
  UserDelegateState _userDelegateState;
  ContractNodeItem _contractNodeItem;
  ContractState _contractState;

  Wallet _wallet;
  bool _haveNextEpisode = true;
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
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          centerTitle: true,
          title: Text(
            S.of(context).node_contract_detail,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => Map3NodeDividePage("1")));
              },
              child: Text(
                "裂变",
                style: TextStyle(color: HexColor("#228BA1"), fontSize: 14),
              ),
            ),
            InkWell(
              onTap: () {
                Application.router.navigateTo(
                    context,
                    Routes.map3node_share_page +
                        "?contractNodeItem=${FluroConvertUtils.object2string(_contractNodeItem.toJson())}");
              },
              child: Padding(
                padding: EdgeInsets.only(right: 15),
                child: Image.asset(
                  "res/drawable/node_share.png",
                  width: 15,
                  height: 18,
                ),
              ),
            )
          ],
        ),
        body: _pageWidget(context),
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
                  if (_haveNextEpisode) SliverToBoxAdapter(child: _topNextEpisodeNotifyWidget()),
                  // 0.合约介绍信息
                  SliverToBoxAdapter(
                    child: _getMap3NodeInfoItem(context, _contractNodeItem),
                  ),
                  _spacer(),
                  SliverToBoxAdapter(
                    child: _nodeNextTimesWidget(),
                  ),
                  _spacer(),

                  // 3.合约状态信息
                  // 3.1最近已操作状态通知 + 总参与抵押金额及期望收益
                  SliverToBoxAdapter(child: _contractProfitWidget()),
                  _spacer(),

                  SliverToBoxAdapter(child: _remortgageWidget()),
                  _spacer(),

                  SliverToBoxAdapter(child: _nodeServerWidget()),

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
        ),
        _bottomBtnBarWidget(),
      ],
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
          ClickOvalButton(
            "撤销抵押",
            () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Map3NodeCancelPage()));
              //Navigator.push(context, MaterialPageRoute(builder: (context) => Map3NodeCancelConfirmPage()));
            },
            width: 90,
            height: 32,
            fontSize: 14,
            textColor: DefaultColors.color999,
            btnColor: Colors.transparent,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 14),
            child: ClickOvalButton(
              "提取奖励",
              () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Map3NodeCollectPage()));
              },
              width: 90,
              height: 32,
              fontSize: 14,
            ),
          ),
          ClickOvalButton(
            "抵押",
            () async {
              var walletList = await WalletUtil.scanWallets();
              if (walletList.length == 0) {
                Application.router.navigateTo(context,
                    Routes.map3node_create_wallet + "?pageType=${Map3NodeCreateWalletPage.CREATE_WALLET_PAGE_TYPE_CREATE}");
              } else {
                var entryRouteName = Uri.encodeComponent(Routes.map3node_contract_detail_page);
                Application.router.navigateTo(
                    context, Routes.map3node_join_contract_page + "?entryRouteName=$entryRouteName&contractId=${1}");
              }
            },
            width: 90,
            height: 32,
            fontSize: 14,
          ),
          SizedBox(
            width: 15,
          )
        ],
      ),
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
                //"第二期已经开启，前往查看  >>",
                //style: TextStyle(fontSize: 12, color: HexColor("#5C4304")),
                "你的最新抵押：60,000HYN，待处理中…",
                style: TextStyle(fontSize: 12, color: HexColor("#333333")),
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

    var nodeName = "天道酬勤唐唐";
    var nodeYearOld = "   节龄: 12天";
    var nodeAddress = "节点地址 oxfdaf89fdaff ${UiUtil.shortEthAddress(contractNodeItem.owner, limitLength: 6)}";
    var nodeIdPre = "节点号";
    var nodeId = " ${contractNodeItem.contractCode ?? "PB2020"}";

    var descPre = "节点公告：";
    var desc = contractNodeItem.announcement ?? _pronounceText;

    var times = "第一期";

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
                Image.asset(
                  "res/drawable/map3_node_default_avatar.png",
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
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
                      Text.rich(TextSpan(children: [
                        TextSpan(
                            text: nodeIdPre,
                            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: HexColor("#333333"))),
                        TextSpan(
                            text: nodeId,
                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: HexColor("#333333"))),
                      ])),
                      Container(
                        height: 4,
                      ),
                      Text(nodeAddress, style: TextStyles.textC9b9b9bS10),
                    ],
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(dateDesc, style: TextStyle(color: Map3NodeUtil.stateColor(state), fontSize: 12)),
                      Container(
                        height: 4,
                      ),
                      Container(
                        color: HexColor("#1FB9C7").withOpacity(0.08),
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(times, style: TextStyle(fontSize: 12, color: HexColor("#5C4304"))),
                      ),
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
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: InkWell(
                      //color: HexColor("#FF15B2D2"),
                      //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      onTap: () {

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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nodeNextTimesWidget() {
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
                  TextSpan(text: "（请在 2020.8.29 之前修改）", style: TextStyle(fontSize: 12, color: HexColor("#999999"))),
                ])),
                Spacer(),
                SizedBox(
                  height: 30,
                  child: InkWell(
                    onTap: () {
                      Application.router.navigateTo(context, Routes.map3node_contract_detail_page + "?contractId=${1}");
                    },
                    child: Center(child: Text("修改", style: TextStyle(fontSize: 14, color: HexColor("#1F81FF")))),
                    //style: TextStyles.textC906b00S13),
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
                      "已开启",
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
                      "20%",
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
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text.rich(TextSpan(children: [
                  TextSpan(text: "复投Atlas共识节点", style: TextStyle(fontSize: 16, color: HexColor("#333333"))),
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
                          Image.asset(
                            "res/drawable/map3_node_default_avatar.png",
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
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
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 20, 6),
                        child: Image.asset(
                          "res/drawable/node_server_map.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 24,
                  ),
                  Expanded(
                    child: Column(
                      children: [0, 1, 2].map((index) {
                        var titles = ["API调用", "设备", "位置"];
                        var details = ["1000万/日", "阿里云机器", "中国香港"];

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
//    if (!_isDelegated || _contractDetailItem == null || _userDelegateState == null) {
//      return Container();
//    }

    var amount = _contractDetailItem?.amountDelegation ?? "0";
    var amountDelegation = FormatUtil.amountToString(amount);
    var total = double.parse(_contractDetailItem?.expectedYield ?? "0") + double.parse(amount);
    var expectedYield = FormatUtil.amountToString(total.toString());
    var commission = FormatUtil.amountToString(_contractDetailItem?.commission ?? "0");
    var textColor = _userDelegateState == UserDelegateState.CANCELLED ? HexColor("#B51414") : HexColor("#5C4304");
    var withdrawn = FormatUtil.amountToString(_contractDetailItem?.withdrawn ?? "0") + "HYN";
    var managerTip = Map3NodeUtil.managerTip(_contractNodeItem.contract, double.parse(amount), isOwner: _isOwner);
    var endProfit = Map3NodeUtil.getEndProfit(_contractNodeItem.contract, double.parse(amount));
    print(
        '[Detail] commission:$commission vs $managerTip, expectedYield:$expectedYield vs $endProfit ,withdrawn: $withdrawn}');

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
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              "800,000",
              style: TextStyle(fontSize: 22, color: HexColor("#BF8D2A"), fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              "总抵押",
              style: TextStyle(fontSize: 14, color: HexColor("#333333"), fontWeight: FontWeight.normal),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16, top: 32),
            child: Row(
              children: [1, 0.5, 2, 0.5, 3, 0.5, 4].map((value) {
                String title = "";
                String detail = "0";

                switch (value) {
                  case 1:
                    title = "管理费";
                    detail = "20%";
                    break;

                  case 2:
                    title = "预期年化";
                    detail = "10.3%";
                    break;

                  case 3:
                    title = "我的抵押";
                    detail = "110，000";
                    break;

                  case 4:
                    title = "奖励";
                    detail = "1，000";
                    break;

                  default:
                    return Container(
                      height: 20,
                      width: 0.5,
                      color: HexColor("#F2F2F2"),
                    );
                    break;
                }

                var isPreCreate = (_userDelegateState == UserDelegateState.PRE_CREATE);
                if (isPreCreate) {
                  detail = "0";
                }

                return Expanded(
                  child: Center(
                      child: Column(
                    children: <Widget>[
                      Text(detail,
                          style: TextStyle(
                            fontSize: 14,
                            color: HexColor("#333333"),
                          )),
                      Container(
                        height: 4,
                      ),
                      Text(title, style: TextStyle(fontSize: 10, color: HexColor("#999999"))),
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
      progressHints = ["", S.of(context).n_day(90.toString()), S.of(context).n_day(90.toString()), ""];
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
    var isWithdrawDelegatePengding =
        operaState == BillsOperaState.DELEGATE && recordState == BillsRecordState.PRE_CREATE || isPengding;

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
}
