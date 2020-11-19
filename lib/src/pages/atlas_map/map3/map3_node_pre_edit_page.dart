import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/components/atlas/atlas_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_message.dart';
import 'package:titan/src/pages/atlas_map/entity/create_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_confirm_page.dart';
import 'package:titan/src/pages/wallet/model/hyn_transfer_history.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:web3dart/web3dart.dart';
import 'map3_node_public_widget.dart';
import 'package:web3dart/credentials.dart';
import 'map3_node_confirm_page.dart';
import 'package:titan/src/utils/log_util.dart';

/*
import 'dart:math';
import '../../../global.dart';
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart' as all_page_state;
import 'package:web3dart/src/models/map3_node_information_entity.dart';
import 'package:titan/src/pages/bio_auth/bio_auth_page.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/pages/atlas_map/entity/bls_key_sign_entity.dart';
*/

class Map3NodePreEditPage extends StatefulWidget {
  final Map3InfoEntity map3infoEntity;

  Map3NodePreEditPage({this.map3infoEntity});

  @override
  _Map3NodePreEditState createState() => _Map3NodePreEditState();
}

class _Map3NodePreEditState extends State<Map3NodePreEditPage> with WidgetsBindingObserver {
  bool _isAutoRenew = true;
  double _currentFeeRate = 10;
  // double _maxFeeRate = 100;
  // double _minFeeRate = 0;
  // double _avgFeeRate = 0;

  TextEditingController _rateCoinController = TextEditingController();

  get _isJoiner => widget?.map3infoEntity?.isJoiner ?? true;

  get _isDelegate => widget?.map3infoEntity?.mine != null;

  get _isEmptyBls => ((widget?.map3infoEntity?.blsKey?.isEmpty ?? true));

  int _status = 0;
  bool _isHaveRenew = false;

  /*
  all_page_state.AllPageState _currentState = all_page_state.LoadingState();

  var _address = "";
  */

  // get _inputFeeRateValue {
  //   var text = _rateCoinController?.text ?? '0';
  //   if (text.isEmpty) {
  //     text = '0';
  //   }
  //   var value = double.tryParse(text);
  //   if (value == null) return 0;
  //   return value;
  // }

  ConfirmEditMap3NodeMessage _editMessage;
  //Map3IntroduceEntity _map3introduceEntity;
  int nonce;

  get _canRenew =>
      (widget.map3infoEntity.status == Map3InfoStatus.CONTRACT_HAS_STARTED.index) && _isDelegate && (!_isHaveRenew);

  var _currentBlockHeight = 0;

  @override
  void initState() {
    setupData();

    /*
    if (!_isJoiner) {
      getNetworkData();
    } else {
      print("_currentFeeRate: $_currentFeeRate");
    }
    */

    getNetworkData();

    getMap3Bls();

    super.initState();
  }

  setupData() async {
    _currentFeeRate = (100 * double.parse(widget.map3infoEntity.getFeeRate()));

    _rateCoinController.text = "$_currentFeeRate";

    print("[Map3NodePreEditPage] info:${widget.map3infoEntity.toJson()}");

    var uploadStatus = '_isJoiner:$_isJoiner, _isEmptyBls:$_isEmptyBls';
    print(uploadStatus);
    LogUtil.uploadException("[Map3NodePreEditPage] initState, uploadStatus", uploadStatus);

    //_map3introduceEntity = await AtlasApi.getIntroduceEntity();

    /*
    setState(() {
      _maxFeeRate = 100 * double.parse(_map3introduceEntity?.feeMax ?? "100");
      _minFeeRate = 100 * double.parse(_map3introduceEntity?.feeMin ?? "0");
      _avgFeeRate = 100 * double.parse(_map3introduceEntity?.feeAvg ?? "10");
    });*/
  }

  getMap3Bls() async {
    if (_isJoiner) {
      return;
    }

    if (!_isEmptyBls) {
      return;
    }

    var blsKeySignEntity = await AtlasApi().getMap3Bls();

    var payload = CreateMap3Payload.onlyNodeId(widget.map3infoEntity.nodeId);
    payload.name = widget.map3infoEntity.name;
    payload.nodeId = null;
    payload.home = widget.map3infoEntity.home;
    payload.connect = widget.map3infoEntity.contact;
    payload.describe = widget.map3infoEntity.describe;
    payload.editType = 2;

    payload.blsRemoveKey = null;
    payload.blsAddSign = blsKeySignEntity?.blsSign ?? null;
    payload.blsAddKey = blsKeySignEntity?.blsKey ?? null;

    CreateMap3Entity createMap3Entity = CreateMap3Entity.onlyType(AtlasActionType.EDIT_MAP3_NODE);
    createMap3Entity.payload = payload;
    var map3NodeAddress = widget?.map3infoEntity?.address ?? "";
    _editMessage = ConfirmEditMap3NodeMessage(entity: createMap3Entity, map3NodeAddress: map3NodeAddress);

    final client = WalletUtil.getWeb3Client(true);

    var activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
    var _wallet = activatedWallet?.wallet;
    var _walletAddress = _wallet?.getEthAccount()?.address ?? "";
    nonce = await client.getTransactionCount(
      EthereumAddress.fromHex(_walletAddress),
      atBlock: const BlockNum.pending(),
    );
    createMap3Entity.nonce = nonce;
    print("[pre]  --> createMap3Entity.nonce:${createMap3Entity.nonce}");

    var uploadConfirmEditMap3NodeMessage = 'payload:${payload.toJson()}, nonce:$nonce';
    print(uploadConfirmEditMap3NodeMessage);
    LogUtil.uploadException(
        "[Map3NodePreEditPage] getMap3Bls, uploadConfirmEditMap3NodeMessage", uploadConfirmEditMap3NodeMessage);

    var uploadBlsKeySignEntity = 'blsKeySignEntity:${blsKeySignEntity.toJson()}, nonce:$nonce';
    print(uploadBlsKeySignEntity);
    LogUtil.uploadException("[Map3NodePreEditPage] getMap3Bls, uploadBlsKeySignEntity", uploadBlsKeySignEntity);
  }

  /*
  double getStaking() {
    var myDelegation = FormatUtil.clearScientificCounting(_microDelegations?.amount?.toDouble() ?? 0);
    var myDelegationValue = ConvertTokenUnit.weiToEther(weiBigInt: BigInt.parse(myDelegation)).toDouble();
    return myDelegationValue;
  }


  _updateRate() {
    var staking = getStaking();
    var createMin = double.parse(_map3introduceEntity?.startMin ?? '550000');
    var rate = (100 * (staking / createMin)).toDouble();

    if (rate >= 20) {
      _maxFeeRate = 20;
    } else if (rate < 20 && rate > 10) {
      _maxFeeRate = rate;
    } else {
      _maxFeeRate = 10;
    }

    setState(() {
      _currentFeeRate = min(_currentFeeRate, _maxFeeRate);
      _rateCoinController.text = "$_currentFeeRate";
    });
  }


  Future getNetworkData() async {
    try {
      var _wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet?.wallet;
      _address = _wallet.getAtlasAccount().address;

      var walletAddress = EthereumAddress.fromHex(_address);
      var map3Address = EthereumAddress.fromHex(widget.map3infoEntity.address);
      _microDelegations = await _client.getMap3NodeDelegation(
        map3Address,
        walletAddress,
      );
      //_updateRate();

      if (mounted) {
        setState(() {
          _currentState = null;
        });
      }
    } catch (e) {
      logger.e(e);
      LogUtil.toastException(e);

      if (mounted) {
        setState(() {
          _currentState = all_page_state.LoadFailState();
        });
      }
    }
  }
  */

  Future getNetworkData() async {
    try {
      var _wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet?.wallet;
      var _walletAddress = _wallet.getAtlasAccount().address;
      var _nodeAddress = widget?.map3infoEntity?.address ?? '';

      List<HynTransferHistory> list = await AtlasApi().getTxsList(
        _walletAddress,
        type: [MessageType.typeRenewMap3],
        map3Address: _nodeAddress,
        size: 1,
      );
      var isNotEmpty = list?.isNotEmpty ?? false;
      print("[${widget.runtimeType}], isNotEmpty:$isNotEmpty");
      if (isNotEmpty) {
        // 是否是当前这期的设置
        var lastTransaction = list.first;
        var epoch = lastTransaction.epoch;
        var startEpoch = widget.map3infoEntity?.startEpoch ?? 0;
        var endEpoch = widget.map3infoEntity?.endEpoch ?? 0;
        var inCurrentPeriod = epoch > startEpoch && epoch < endEpoch;

        // 已经过去30秒的话，可以执行后面操作
        var now = DateTime.now().millisecondsSinceEpoch;
        var last = lastTransaction.timestamp * 1000;
        var isOver30Seconds = (now - last) > (30 * 1000);

        //print("[${widget.runtimeType}],isOver30Seconds:$isOver30Seconds, inCurrentPeriod:$inCurrentPeriod");

        if (inCurrentPeriod || !isOver30Seconds) {
          _status = lastTransaction.status;
          _isHaveRenew = _status >= TransactionStatus.pending && _status <= TransactionStatus.success;
          //print("[${widget.runtimeType}], _status:$_status, _isHaveRenew:$_isHaveRenew");

          if ((lastTransaction?.dataDecoded ?? {}).keys.contains('isRenew')) {
            _isAutoRenew = (lastTransaction.dataDecoded["isRenew"] as bool);
            //print("[${widget.runtimeType}], _status:$_status, _isHaveRenew:$_isHaveRenew, _isAutoRenew:$_isAutoRenew");
          }
        } else {
          LogUtil.printMessage("[${widget.runtimeType}]--->epoch:$epoch, startEpoch:$startEpoch, endEpoch:$endEpoch");
        }
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      LogUtil.toastException(e);

      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: S.of(context).preset_for_next_period,
      ),
      backgroundColor: Colors.white,
      body: _pageView(context),
    );
  }

  Widget _pageView(BuildContext context) {
    var notification = '';
    switch (_status) {
      case TransactionStatus.pending:
        notification = '续约请求正处理中...';

        break;

      case TransactionStatus.success:
        notification = '续约请求已完成';
        break;
    }

    var _lastCurrentBlockHeight = _currentBlockHeight;

    _currentBlockHeight = AtlasInheritedModel.of(context).committeeInfo?.blockNum ?? 0;
    if (_lastCurrentBlockHeight == 0) {
      _lastCurrentBlockHeight = _currentBlockHeight;
    }

    if (_status == TransactionStatus.pending && (_currentBlockHeight > _lastCurrentBlockHeight)) {
      getNetworkData();
    }

    var divider = Container(
      color: HexColor("#F4F4F4"),
      height: 8,
    );
    return Column(
      children: <Widget>[
        topNotifyWidget(
          notification: notification,
          isWarning: false,
        ),
        Expanded(
          child: BaseGestureDetector(
            context: context,
            child: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Container(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _switchWidget(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                        ),
                        child: Divider(
                          color: HexColor("#F2F2F2"),
                          height: 0.5,
                        ),
                      ),
                      //_isJoiner ? _rateWidgetJoiner() : _rateWidgetCreator(),
                      divider,
                      _tipsWidget(),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
        _confirmButtonWidget(),
      ],
    );
  }

  /*
  Widget _rateWidgetJoiner() {
    var nextFeeRate = FormatUtil.formatPercent(double.parse(widget?.map3infoEntity?.rateForNextPeriod ?? "0"));
    if (nextFeeRate == '0%' || nextFeeRate == '0' || nextFeeRate.isEmpty || nextFeeRate == null) {
      nextFeeRate = FormatUtil.formatPercent(_currentFeeRate.toDouble() / 100.0);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
            child: RichText(
              text: TextSpan(
                  text: S.of(context).map3_next_period_manage_fee,
                  style: TextStyle(fontSize: 16, color: HexColor("#333333"), fontWeight: FontWeight.normal),
                  children: [
                    TextSpan(
                      text: "",
                      style: TextStyle(fontSize: 12, color: HexColor("#999999"), fontWeight: FontWeight.normal),
                    )
                  ]),
            ),
          ),
          Spacer(),
          RichText(
            text: TextSpan(
                text: nextFeeRate,
                style: TextStyle(fontSize: 16, color: HexColor("#333333"), fontWeight: FontWeight.normal),
                children: [
                  TextSpan(
                    text: "",
                    style: TextStyle(fontSize: 12, color: HexColor("#999999"), fontWeight: FontWeight.normal),
                  )
                ]),
          ),
        ],
      ),
    );
  }

  Widget _rateWidgetCreator() {
    return managerSpendWidget(
      context,
      _rateCoinController,
      reduceFunc: () {
        setState(() {
          _currentFeeRate--;
          if (_currentFeeRate <= _minFeeRate) {
            _currentFeeRate = _minFeeRate;
            Fluttertoast.showToast(msg: S.of(context).manage_fee_range(_minFeeRate, _maxFeeRate));
          }

          _rateCoinController.text = "$_currentFeeRate";
        });
      },
      addFunc: () {
        setState(() {
          _currentFeeRate++;
          if (_currentFeeRate >= _maxFeeRate) {
            _currentFeeRate = _maxFeeRate;
            Fluttertoast.showToast(msg: S.of(context).manage_fee_range(_minFeeRate, _maxFeeRate));
          }
          _rateCoinController.text = "$_currentFeeRate";
        });
      },
      maxFeeRate: _maxFeeRate,
      minFeeRate: _minFeeRate,
      avgFeeRate: _avgFeeRate,
    );
  }
  */

  Widget _switchWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      child: Row(
        children: <Widget>[
          Text(
            _isJoiner ? "期满跟随续约" : "期满自动续约",
            style: TextStyle(
              color: HexColor("#333333"),
              fontSize: 16,
            ),
          ),
          Spacer(),
          Switch(
            value: _isAutoRenew,
            activeColor: Theme.of(context).primaryColor,
            activeTrackColor: Theme.of(context).primaryColor,
            onChanged: _canRenew
                ? (bool newValue) {
                    setState(() {
                      _isAutoRenew = newValue;
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _tipsWidget() {
    //var amount = " ${FormatUtil.formatTenThousandNoUnit(_map3introduceEntity?.startMin?.toString() ?? "0")}" +
    //     S.of(context).ten_thousand;
    //var tip1 = S.of(context).map3_manage_fee_rule(amount, 20);

    var tip2 = _isJoiner
        ? "期满跟随续约每个节点周期只能修改一次，修改完之后直到下个节点周期才能再次修改，请谨慎操作！"
        : "期满自动续约和管理费每个节点周期只能修改一次，修改完之后直到下个节点周期才能再次修改，请谨慎操作！";
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8),
            child: Text(S.of(context).precautions, style: TextStyle(color: HexColor("#333333"), fontSize: 16)),
          ),
          rowTipsItem(tip2),
        ],
      ),
    );
  }

  Widget _confirmButtonWidget() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 37, vertical: 18),
      child: ClickOvalButton(
        S.of(context).confirm_mod,
        _confirmAction,
        /*
        () {
          // if (!_isJoiner) {
          //   if (_inputFeeRateValue <= _minFeeRate) {
          //     Fluttertoast.showToast(msg: S.of(context).please_setup_manage_fee);
          //     return;
          //   }
          //
          //   var feeRate = _inputFeeRateValue;
          //   if (feeRate < _minFeeRate || feeRate > _maxFeeRate) {
          //     Fluttertoast.showToast(msg: S.of(context).manage_fee_range(_minFeeRate, _maxFeeRate));
          //     return;
          //   }
          // }

          //showAlertView();
        },
        */
        height: 46,
        width: MediaQuery.of(context).size.width - 37 * 2,
        fontSize: 18,
        isLoading: !_canRenew,
      ),
    );
  }

  _confirmAction() async {
    try {
      if (widget?.map3infoEntity?.mine != null && (widget?.map3infoEntity?.address ?? "").isNotEmpty) {
        var activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
        var wallet = activatedWallet?.wallet;
        var map3Address = EthereumAddress.fromHex(widget.map3infoEntity.address);
        var walletAddress = EthereumAddress.fromHex(wallet?.getEthAccount()?.address ?? "");

        var microDelegations = await WalletUtil.getWeb3Client(true).getMap3NodeDelegation(
          map3Address,
          walletAddress,
        );
        var status = (microDelegations?.renewal?.status ?? 0);
        if (status > 0) {
          if (mounted) {
            setState(() {
              _status = status;
              _isHaveRenew = true;
            });
          }

          Fluttertoast.showToast(
            msg: '你的下期续约设置已完成！',
            gravity: ToastGravity.CENTER,
          );
          return;
        }
      }

      var lastTxIsPending = await AtlasApi.checkLastTxIsPending(
        MessageType.typeRenewMap3,
        map3Address: widget?.map3infoEntity?.address ?? '',
      );
      if (lastTxIsPending) {
        return;
      }
    } catch (e) {
      print(e);
      // Fluttertoast.showToast(
      //   msg: '未知错误，请稍后重试！',
      //   gravity: ToastGravity.CENTER,
      // );
      return;
    }

    var nextFeeRate = 100 * double.parse(widget?.map3infoEntity?.rateForNextPeriod ?? "0");
    // var feeRate = _isJoiner ? nextFeeRate : (_inputFeeRateValue ?? _maxFeeRate);
    var feeRate = nextFeeRate;

    var content = "";
    if (!_isAutoRenew) {
      if (!_isJoiner) {
        content = S.of(context).confirm_stop_auto_renew;
      } else {
        content = S.of(context).confirm_stop_follow_renew;
      }
    } else {
      if (!_isJoiner) {
        //content = S.of(context).confirm_open_auto_renew(feeRate);
        content = '你将开启自动续约，修改后不能撤回，确定修改吗？';
      } else {
        //content = S.of(context).confirm_follow_renew;
        content = '你将跟随续约，修改后不能撤回，确定修改吗？';
      }
    }

    UiUtil.showAlertView(
      context,
      title: S.of(context).preset_for_next_period,
      actions: [
        ClickOvalButton(
          S.of(context).cancel,
          () {
            Navigator.pop(context);
          },
          width: 120,
          height: 32,
          fontSize: 14,
          fontColor: DefaultColors.color999,
          btnColor: Colors.transparent,
        ),
        SizedBox(
          width: 8,
        ),
        ClickOvalButton(
          S.of(context).confirm,
          () {
            Navigator.pop(context);

            var message = ConfirmPreEditMap3NodeMessage(
              autoRenew: _isAutoRenew,
              map3NodeName: widget?.map3infoEntity?.name ?? "",
              feeRate: _isJoiner ? null : feeRate.toString(),
              map3NodeAddress: widget.map3infoEntity.address,
            );

            if (!_isJoiner && _isEmptyBls && nonce != null) {
              message.nonce = nonce + 1;
            }
            print("[pre]  --> createMap3Entity.preMsg.nonce:${message.nonce}");

            var uploadPreEditMsg = '_isOpen:$_isAutoRenew, preMsg.nonce:${message.nonce}';
            print(uploadPreEditMsg);
            LogUtil.uploadException("[Map3NodePreEditPage] showAlertView, uploadPreEditMsg", uploadPreEditMsg);

            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Map3NodeConfirmPage(
                    message: message,
                    editMessage: _editMessage,
                  ),
                ));
          },
          width: 120,
          height: 38,
          fontSize: 16,
        ),
      ],
      content: content,
    );
  }
}
