import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/atlas/atlas_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_message.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/pledge_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_confirm_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/pages/wallet/model/hyn_transfer_history.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';

import '../../../../env.dart';

class Map3NodeRewardListPage extends StatefulWidget {
  Map3NodeRewardListPage();

  @override
  State<StatefulWidget> createState() {
    return Map3NodeRewardListPageState();
  }
}

class Map3NodeRewardListPageState extends State<Map3NodeRewardListPage> {
  AtlasApi _atlasApi = AtlasApi();
  final _client = WalletUtil.getWeb3Client(true);

  List<Map3InfoEntity> _joinNodeList = List();
  List<Map3InfoEntity> _createdNodeList = List();

  LoadDataBloc _loadDataBloc = LoadDataBloc();

  var _walletName = '';
  String _address = '';

  Map<String, dynamic> _rewardMap = {};
  Decimal _totalAmount = Decimal.fromInt(0);

  int _currentPage = 1;
  int _pageSize = 30;

  HynTransferHistory _lastPendingTx;
  var _currentBlockHeight = 0;

  String get _notification {
    var notification = '';
    if (_lastPendingTx == null) return null;

    switch (_lastPendingTx.status) {
      case TransactionStatus.pending:
      case TransactionStatus.pending_for_receipt:
        notification = S.of(context).extracting_reward_request_processing;

        break;

      case TransactionStatus.success:
        notification = S.of(context).successful_withdrawal_rewards_sent_your_wallet;
        break;
    }
    return notification;
  }

  @override
  void initState() {
    super.initState();
    var activatedWallet =
        WalletInheritedModel.of(Keys.rootKey.currentContext)?.activatedWallet;
    _address = activatedWallet?.wallet?.getAtlasAccount()?.address ?? "";
    _walletName = activatedWallet?.wallet?.keystore?.name ?? "";

    _getData();
    _loadDataBloc.add(LoadingEvent());
  }

  @override
  void dispose() {
    super.dispose();
    _loadDataBloc.close();
  }

  _getData() {
    _getCreatedNodeList();
    _getRewardMap();
    _getLastTxData();
  }

  _getCreatedNodeList() async {
    ///not use pagination, use 9999 as size to request list
    ///
    try {
      var _list = await _atlasApi.getMap3NodeListByMyCreate(
        _address,
        page: 1,
        size: 9999,
        status: [
          Map3InfoStatus.CONTRACT_HAS_STARTED.index,
        ],
      );

      if (_list != null && _list.isNotEmpty) {
        _createdNodeList.clear();
        _createdNodeList.addAll(_list);
      }
    } catch (e) {}
    if (mounted) setState(() {});
  }

  Future _getLastTxData() async {
    try {
      List<HynTransferHistory> list = await AtlasApi().getTxsList(
        _address,
        type: [MessageType.typeCollectMicroStakingRewards],
        //status: [TransactionStatus.pending,TransactionStatus.pending_for_receipt],
        size: 1,
      );

      var isNotEmpty = list?.isNotEmpty ?? false;
      if (isNotEmpty) {
        // 已经过去30秒的话，可以执行后面操作
        var lastTransaction = list.first;
        var now = DateTime.now().millisecondsSinceEpoch;
        var last = lastTransaction.timestamp * 1000;
        var isOver30Seconds = (now - last) > (30 * 1000);
        //print("my--->now:$now, last:$last, isOver30Seconds:$isOver30Seconds");
        if (isOver30Seconds) {
          _lastPendingTx = null;
        } else {
          _lastPendingTx = lastTransaction;
        }
      } else {
        _lastPendingTx = null;
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      //LogUtil.toastException(e);

      if (mounted) {
        setState(() {});
      }
    }
  }

  _getRewardMap() async {
    _rewardMap = await _client.getAllMap3RewardByDelegatorAddress(
      EthereumAddress.fromHex(_address),
    );

    if (_rewardMap.isNotEmpty) {
      ///clear amount first;
      _totalAmount = Decimal.fromInt(0);

      _rewardMap.forEach((key, value) {
        var bigIntValue = BigInt.tryParse(value) ?? BigInt.from(0);
        Decimal valueByDecimal = ConvertTokenUnit.weiToEther(
          weiBigInt: bigIntValue,
        );
        _totalAmount = _totalAmount + valueByDecimal;
      });
    } else {
      _totalAmount = Decimal.fromInt(0);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var _lastCurrentBlockHeight = _currentBlockHeight;

    _currentBlockHeight =
        AtlasInheritedModel.of(context).committeeInfo?.blockNum ?? 0;
    if (_lastCurrentBlockHeight == 0) {
      _lastCurrentBlockHeight = _currentBlockHeight;
    }

    //LogUtil.printMessage("[${widget.runtimeType}]   _currentBlockHeight:$_currentBlockHeight");

    if ((_lastPendingTx != null) &&
        (_currentBlockHeight > _lastCurrentBlockHeight)) {
      _getData();
    }

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            topNotifyWidget(
              notification: _notification,
              isWarning: false,
            ),
            Expanded(
              child: LoadDataContainer(
                  bloc: _loadDataBloc,
                  onLoadData: () async {
                    _getData();
                    await _refreshData();
                  },
                  onRefresh: () async {
                    _getData();
                    await _refreshData();
                  },
                  onLoadingMore: () {
                    _getData();
                    _loadMoreData();
                  },
                  child: CustomScrollView(
                    slivers: <Widget>[
                      SliverToBoxAdapter(
                        child: _collectableRewardWidget(),
                      ),
                      _myCreateNodeList(),
                      _myJoinNodeList(),
                      _emptyListHint(),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  _collectableRewardWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 32.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[200],
              blurRadius: 15.0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 36.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '${FormatUtil.stringFormatCoinNum(_totalAmount.toString())}',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 4.0,
              ),
              child: Text(
                S.of(context).currently_available,
                style: TextStyle(
                  fontSize: 13,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: ClickOvalButton(
                S.of(context).action_atals_receive_award,
                _collect,
                fontSize: 14,
                width: 160,
                height: 36,
                fontWeight: FontWeight.normal,
              ),
            ),
            SizedBox(
              height: 16,
            )
          ],
        ),
      ),
    );
  }

  _emptyListHint() {
    if (_createdNodeList.isEmpty && _joinNodeList.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  'res/drawable/ic_empty_contract.png',
                  width: 100,
                  height: 100,
                ),
              ),
              Text(
                S.of(context).exchange_empty_list,
                style: TextStyle(
                  fontSize: 13,
                  color: DefaultColors.color999,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return SliverToBoxAdapter(
        child: Container(),
      );
    }
  }

  _myCreateNodeList() {
    if (_createdNodeList.isNotEmpty) {
      return SliverList(
          delegate: SliverChildBuilderDelegate(
        (context, index) {
          return _nodeCollectItem(
            _createdNodeList[index],
            isShowDivider: true,
          );
        },
        childCount: _createdNodeList.length,
      ));
    } else {
      return SliverToBoxAdapter(
        child: Container(),
      );
    }
  }

  _myJoinNodeList() {
    if (_joinNodeList.isNotEmpty) {
      return SliverList(
          delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index != _joinNodeList.length - 1) {
            return _nodeCollectItem(
              _joinNodeList[index],
              isShowDivider: true,
            );
          } else {
            return _nodeCollectItem(_joinNodeList[index]);
          }
        },
        childCount: _joinNodeList.length,
      ));
    } else {
      return SliverToBoxAdapter(
        child: Container(),
      );
    }
  }

  _collect() async {
    ///refresh reward map
    await _getRewardMap();

    try {
      var lastTxIsPending = await AtlasApi.checkLastTxIsPending(
        MessageType.typeCollectMicroStakingRewards,
      );

      if (lastTxIsPending) {
        Fluttertoast.showToast(msg: S.of(context).wait_for_completion_previous_transaction);
        return;
      }

      if (_rewardMap.isEmpty) {
        Fluttertoast.showToast(msg: S.of(context).current_reward_zero);
        return;
      }
    } catch (e) {
      print(e);
      LogUtil.toastException(e);
      return;
    }

    UiUtil.showAlertView(
      context,
      title: S.of(context).collect_reward,
      actions: [
        ClickOvalButton(
          S.of(context).confirm_collect,
          () {
            Navigator.pop(context);

            var entity = PledgeMap3Entity();
            var message = ConfirmCollectMap3NodeMessage(
              entity: entity,
              amount: _totalAmount.toString(),
              addressList:
                  _rewardMap?.keys?.map((e) => e.toString())?.toList() ?? [],
            );
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Map3NodeConfirmPage(
                    message: message,
                  ),
                ));
          },
          width: 160,
          height: 38,
          fontSize: 14,
        ),
      ],
      content: S.of(context).confirm_collect_reward_to_wallet(
            '',
            "${FormatUtil.stringFormatCoinNum(_totalAmount.toString())}",
          ),
      boldContent: "($_walletName)",
      boldStyle: TextStyle(
        color: HexColor("#999999"),
        fontSize: 12,
        height: 1.8,
      ),
      suffixContent: " ？",
    );
  }

  _refreshData() async {
    _currentPage = 1;
    try {
      var _list = await _atlasApi.getMap3NodeListByMyJoin(_address,
          page: _currentPage,
          size: _pageSize,
          status: [
            Map3InfoStatus.CONTRACT_HAS_STARTED.index,
          ]);

      if (_list != null) {
        _joinNodeList.clear();
        _joinNodeList.addAll(_list);
      }
      _loadDataBloc.add(RefreshSuccessEvent());
    } catch (e) {
      _loadDataBloc.add(RefreshFailEvent());
    }
    if (mounted) setState(() {});
  }

  _loadMoreData() async {
    try {
      var _list = await _atlasApi.getMap3NodeListByMyJoin(_address,
          page: _currentPage + 1,
          size: _pageSize,
          status: [
            Map3InfoStatus.CONTRACT_HAS_STARTED.index,
          ]);

      if (_list != null && _list.isNotEmpty) {
        _joinNodeList.addAll(_list);
        _currentPage++;
        _loadDataBloc.add(LoadingMoreSuccessEvent());
      } else {
        _loadDataBloc.add(LoadMoreEmptyEvent());
      }
    } catch (e) {
      _loadDataBloc.add(LoadMoreFailEvent());
    }
    if (mounted) setState(() {});
  }

  _nodeCollectItem(
    Map3InfoEntity map3infoEntity, {
    bool isShowDivider = false,
  }) {
    if (map3infoEntity == null) return Container();
    var nodeName = map3infoEntity?.name ?? "";
    var nodeAddress = '${UiUtil.shortEthAddress(
      WalletUtil.ethAddressToBech32Address(map3infoEntity?.address ?? ""),
      limitLength: 8,
    )}';
    var valueInRewardMap =
        _rewardMap?.containsKey(map3infoEntity.address?.toLowerCase()) ?? false
            ? _rewardMap[map3infoEntity.address?.toLowerCase()]
            : '0';
    var bigIntValue = BigInt.tryParse(valueInRewardMap) ?? BigInt.from(0);
    var _collectible = ConvertTokenUnit.weiToEther(
      weiBigInt: bigIntValue,
    );

    return InkWell(
      onTap: () {
        if (!showLog) {
          return;
        }
        Application.router.navigateTo(
          context,
          Routes.map3node_contract_detail_page + '?info=${FluroConvertUtils.object2string(map3infoEntity.toJson())}',
        );
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                iconMap3Widget(map3infoEntity),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text.rich(TextSpan(children: [
                        TextSpan(
                            text: nodeName,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            )),
                        TextSpan(text: "", style: TextStyles.textC333S14bold),
                      ])),
                      Container(
                        height: 4,
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            '${S.of(context).node_addrees}: ${nodeAddress}',
                            style: TextStyle(
                                color: DefaultColors.color999, fontSize: 11),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        '${FormatUtil.stringFormatCoinNum(_collectible.toString())}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      height: 4,
                    ),
                    Text(
                      S.of(context).map3_current_reward,
                      style: TextStyle(
                        color: DefaultColors.color999,
                        fontSize: 12,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          if (isShowDivider)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.0,
              ),
              child: Divider(height: 0, color: HexColor('#FFF2F2F2')),
            )
        ],
      ),
    );
  }
}
