import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/atlas/atlas_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_message.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_introduce_entity.dart';
import 'package:titan/src/pages/wallet/model/hyn_transfer_history.dart';
import 'package:titan/src/pages/wallet/model/transtion_detail_vo.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/round_border_textfield.dart';
import 'package:titan/src/widget/wallet_widget.dart';

import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';
import 'map3_node_confirm_page.dart';
import 'map3_node_public_widget.dart';
import 'package:titan/src/utils/log_util.dart';
import '../../../global.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:web3dart/src/models/map3_node_information_entity.dart';

class Map3NodeCancelPage extends StatefulWidget {
  final Map3InfoEntity map3infoEntity;

  Map3NodeCancelPage({this.map3infoEntity});

  @override
  State<StatefulWidget> createState() {
    return _Map3NodeCancelState();
  }
}

class _Map3NodeCancelState extends BaseState<Map3NodeCancelPage> {
  TextEditingController _textEditingController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  double minTotal = 0;
  double remainTotal = 0;

  LoadDataBloc _loadDataBloc = LoadDataBloc();
  Map3InfoEntity _map3infoEntity;
  Microdelegations _microDelegationsJoiner;
  Map3IntroduceEntity _map3introduceEntity;
  Map3NodeInformationEntity _map3nodeInformationEntity;
  AtlasApi _atlasApi = AtlasApi();

  String get _nodeId => _map3infoEntity?.nodeId ?? _map3nodeInformationEntity?.map3Node?.description?.identity ?? '';
  String get _nodeAddress => _map3infoEntity?.address ?? _map3nodeInformationEntity?.map3Node?.map3Address ?? '';

  var _walletName = "";
  var _walletAddress = "";

  double get _unlockEpoch => double.tryParse(_microDelegationsJoiner?.pendingDelegation?.unlockedEpoch ?? '0') ?? 0;
  int _currentEpoch = 0;
  var _currentBlockHeight = 0;

  int get _remainEpochInt {
    var remain = _unlockEpoch - _currentEpoch.toDouble();
    if (remain >= 1) {
      return remain.toInt();
    } else if (remain > 0 && remain < 1) {
      return 1;
    }
    return 0;
  }

  final _client = WalletUtil.getWeb3Client(true);

  _minRemain() {
    if (_map3infoEntity?.isCreator() ?? false) {
      return Decimal.tryParse(_nodeCreateMin()) ?? Decimal.parse('0');
    } else {
      return Decimal.parse('0');
    }
  }

  String _nodeCreateMin() {
    return _map3introduceEntity?.createMin ?? '0';
  }

  Decimal _myStakingAmount() {
    if (_map3infoEntity.mine == null || _microDelegationsJoiner == null) return Decimal.parse("0");

    return ConvertTokenUnit.weiToEther(
        weiBigInt: BigInt.parse(
            '${FormatUtil.clearScientificCounting((_microDelegationsJoiner?.pendingDelegation?.amount ?? 0).toDouble())}'));
  }

  get _canCancel =>
      (_map3infoEntity.status == Map3InfoStatus.FUNDRAISING_NO_CANCEL.index) &&
      (_remainEpochInt <= 0) &&
      (_map3infoEntity?.mine != null ?? false) &&
      (_lastPendingTx == null);

  HynTransferHistory _lastPendingTx;

  @override
  void initState() {
    _setupData();

    super.initState();
  }

  @override
  void onCreated() {
    getNetworkData();

    super.onCreated();
  }

  _setupData() {
    var activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
    var _wallet = activatedWallet?.wallet;
    _walletAddress = _wallet?.getEthAccount()?.address ?? "";
    _walletName = _wallet?.keystore?.name ?? "";

    _map3infoEntity = widget.map3infoEntity;
  }

  @override
  void dispose() {
    print("[${widget.runtimeType}] dispose");

    _loadDataBloc.close();
    super.dispose();
  }

  Future getNetworkData() async {
    try {
      var map3Address = EthereumAddress.fromHex(_nodeAddress);
      _map3infoEntity = await _atlasApi.getMap3Info(_walletAddress, _nodeId);

      List<HynTransferHistory> list = await AtlasApi().getTxsList(
        _walletAddress,
        type: [MessageType.typeUnMicroDelegate],
        status: [TransactionStatus.pending],
        map3Address: _nodeAddress,
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

      _map3nodeInformationEntity = await _client.getMap3NodeInformation(map3Address);
      _setupMicroDelegations();

      _map3introduceEntity = await AtlasApi.getIntroduceEntity();

      if (mounted) {
        setState(() {
          _loadDataBloc.add(RefreshSuccessEvent());
        });
      }
    } catch (e) {
      logger.e(e);
      LogUtil.toastException(e);

      if (mounted) {
        setState(() {
          _loadDataBloc.add(RefreshFailEvent());
        });
      }
    }
  }

  _setupMicroDelegations() {
    if (_map3nodeInformationEntity?.microdelegations?.isEmpty ?? true) {
      return;
    }

    var joinerAddress = _walletAddress.toLowerCase();

    for (var item in _map3nodeInformationEntity.microdelegations) {
      var delegatorAddress = item.delegatorAddress;
      if (delegatorAddress.isNotEmpty && (delegatorAddress.toLowerCase()) == joinerAddress) {
        _microDelegationsJoiner = item;
        break;
      }
    }
  }

  String get _notifyMessage {
    if (_lastPendingTx == null) return null;

    TransactionDetailVo transactionDetail = TransactionDetailVo.fromHynTransferHistory(_lastPendingTx, 0, "HYN");
    var amount = FormatUtil.stringFormatCoinNum(transactionDetail.getDecodedAmount());

    return '部分撤销${amount}HYN请求正处理中...';
  }

  @override
  Widget build(BuildContext context) {
    var _lastCurrentBlockHeight = _currentBlockHeight;
    _currentEpoch = AtlasInheritedModel.of(context).committeeInfo?.epoch ?? 0;

    _currentBlockHeight = AtlasInheritedModel.of(context).committeeInfo?.blockNum ?? 0;
    if (_lastCurrentBlockHeight == 0) {
      _lastCurrentBlockHeight = _currentBlockHeight;
    }
    // LogUtil.printMessage(
    //     "[${widget.runtimeType}] _currentEpoch: $_currentEpoch, _currentBlockHeight:$_currentBlockHeight");

    var walletAddressStr =
        "${S.of(context).wallet_address} ${UiUtil.shortEthAddress(WalletUtil.ethAddressToBech32Address(_walletAddress) ?? "***", limitLength: 9)}";

    if (((_map3infoEntity.status == Map3InfoStatus.FUNDRAISING_NO_CANCEL.index) && (_lastPendingTx != null)) &&
        (_currentBlockHeight > _lastCurrentBlockHeight)) {
      getNetworkData();
    }

    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: S.of(context).cancel_delegate,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          topNotifyWidget(
            notification: _notifyMessage,
            isWarning: false,
          ),
          Expanded(
            child: LoadDataContainer(
              bloc: _loadDataBloc,
              enablePullUp: false,
              onRefresh: getNetworkData,
              child: BaseGestureDetector(
                context: context,
                child: SingleChildScrollView(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 18),
                          child: Row(
                            children: <Widget>[
                              Text(S.of(context).receive_wallet,
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 16, right: 8, bottom: 18),
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: 42,
                                height: 42,
                                child: walletHeaderWidget(
                                  _walletName,
                                  isShowShape: false,
                                  address: _walletAddress,
                                  isCircle: true,
                                ),
                              ),
                              SizedBox(
                                width: 6,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text.rich(TextSpan(children: [
                                    TextSpan(
                                        text: _walletName, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                    TextSpan(text: "", style: TextStyles.textC333S14bold),
                                  ])),
                                  Container(
                                    height: 4,
                                  ),
                                  Text(walletAddressStr, style: TextStyles.textC9b9b9bS12),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                    child: Container(
                      color: HexColor("#F4F4F4"),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 16),
                          child: Row(
                            children: <Widget>[
                              Text(S.of(context).node_amount,
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 12),
                          child: profitListBigLightWidget(
                            [
                              {
                                S.of(context).node_total_staking:
                                    '${FormatUtil.formatPrice(double.parse(_nodeCreateMin()))}'
                              },
                              {S.of(context).my_staking: '${_myStakingAmount()}'},
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 18),
                          child: Row(
                            children: <Widget>[
                              Text(S.of(context).cancel_amount,
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 16, right: 18),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "HYN",
                                style: TextStyle(fontSize: 18, color: HexColor("#35393E")),
                              ),
                              SizedBox(
                                width: 12,
                              ),
                              Flexible(
                                flex: 1,
                                child: Form(
                                  key: _formKey,
                                  child: RoundBorderTextField(
                                    onChanged: (text) {
                                      _formKey.currentState.validate();
                                    },
                                    controller: _textEditingController,
                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    //inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                                    hint: S.of(context).please_enter_withdraw_amount,
                                    validator: (textStr) {
                                      if (textStr.length == 0) {
                                        return S.of(context).please_input_hyn_count;
                                      }

                                      var inputValue = Decimal.tryParse(textStr);
                                      if (inputValue == null) {
                                        return S.of(context).please_enter_correct_amount;
                                      }

                                      if (inputValue > _myStakingAmount()) {
                                        return S.of(context).over_your_staking;
                                      }

                                      if (Decimal.parse(textStr) >
                                          ConvertTokenUnit.weiToEther(
                                              weiBigInt: BigInt.parse(_map3infoEntity?.staking ?? "0"))) {
                                        return S.of(context).over_node_total_staking;
                                      }

                                      if (_map3infoEntity.isCreator() &&
                                          _myStakingAmount() - Decimal.parse(textStr) < _minRemain()) {
                                        return S.of(context).remain_delegation_not_less_than('${_minRemain()}');
                                      } else {
                                        return null;
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 12, bottom: 18, right: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                width: 48,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  _epochHint(),
                ])),
              ),
            ),
          ),
          _confirmButtonWidget(),
        ],
      ),
    );
  }

  _epochHint() {
    if (_remainEpochInt == 0) return Container();

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Column(
          children: [
            Text(S.of(context).cant_cancel_staking),
            SizedBox(
              height: 9,
            ),
            Text(
              S.of(context).unlock_remain_epoch(_remainEpochInt),
              style: TextStyle(
                color: DefaultColors.color999,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _confirmButtonWidget() {
    if (_map3nodeInformationEntity == null ?? true) return Container();

    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18.0, top: 10),
        child: Center(
          child: ClickOvalButton(
            S.of(context).confirm_cancel,
            _confirmAction,
            height: 46,
            width: MediaQuery.of(context).size.width - 37 * 2,
            fontSize: 18,
            isDisable: !_canCancel,
          ),
        ),
      ),
    );
  }

  _confirmAction() async {
    if (!_formKey.currentState.validate() || _nodeAddress.isEmpty) {
      return;
    }

    var amount = _textEditingController?.text;

    var entity = await createPledgeMap3Entity(
      context,
      _nodeId,
      action: 'cancel',
    );

    var message = ConfirmCancelMap3NodeMessage(
      entity: entity,
      map3NodeAddress: _nodeAddress,
      amount: amount,
    );

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Map3NodeConfirmPage(
            message: message,
          ),
        ));
  }
}
