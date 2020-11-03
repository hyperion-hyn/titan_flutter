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
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_introduce_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/pledge_map3_entity.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/round_border_textfield.dart';
import 'package:titan/src/widget/wallet_widget.dart';

import 'package:web3dart/credentials.dart';
import 'map3_node_confirm_page.dart';
import 'map3_node_public_widget.dart';
import 'package:titan/src/utils/log_util.dart';
import '../../../global.dart';
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart'
    as all_page_state;
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
  all_page_state.AllPageState _currentState = all_page_state.LoadingState();
  Map3InfoEntity _map3infoEntity;
  Microdelegations _microdelegations;
  Map3IntroduceEntity _map3introduceEntity;
  AtlasApi _atlasApi = AtlasApi();
  var _address = "string";
  var _nodeId = "string";
  var _walletName = "";
  var _walletAddress = "";

  var _currentEpoch;
  var _unlockEpoch;

  final _client = WalletUtil.getWeb3Client(true);

  @override
  void onCreated() {
    var _wallet = WalletInheritedModel.of(Keys.rootKey.currentContext)
        .activatedWallet
        ?.wallet;
    _address = _wallet.getAtlasAccount().address;
    _nodeId = widget.map3infoEntity.nodeId;

    print("_nodeId:${widget.map3infoEntity.toJson()}");

    var activatedWallet = WalletInheritedModel.of(
      context,
      aspect: WalletAspect.activatedWallet,
    ).activatedWallet;

    _walletName = activatedWallet.wallet.keystore.name;
    _walletAddress = activatedWallet.wallet.getEthAccount().address;

    getNetworkData();

    super.onCreated();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    print("[${widget.runtimeType}] dispose");

    _loadDataBloc.close();
    super.dispose();
  }

  Future getNetworkData() async {
    try {
      var walletAddress = EthereumAddress.fromHex(_address);
      print("[${widget.runtimeType}] getNetworkData");

      _map3infoEntity = await _atlasApi.getMap3Info(_address, _nodeId);

      if (_map3infoEntity.mine != null &&
          (widget?.map3infoEntity?.address ?? "").isNotEmpty) {
        var map3Address =
            EthereumAddress.fromHex(widget.map3infoEntity.address);
        print('map3: $map3Address wallet: $walletAddress');

        _microdelegations = await _client.getMap3NodeDelegation(
          map3Address,
          walletAddress,
        );
      }

      _map3introduceEntity = await AtlasApi.getIntroduceEntity();

      _unlockEpoch = _microdelegations?.pendingDelegation?.unlockedEpoch ?? 0;

      _currentEpoch = AtlasInheritedModel.of(context).currentEpoch;

      print(
          '[Map3-node-cancel] UnlockEpoch(client): $_unlockEpoch CurrentEpoch(api): $_currentEpoch');

      if (mounted) {
        setState(() {
          _currentState = null;
          _loadDataBloc.add(RefreshSuccessEvent());
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

  @override
  Widget build(BuildContext context) {
    if (_currentState != null || _map3infoEntity == null) {
      return Scaffold(
        appBar: BaseAppBar(
          baseTitle: S.of(context).cancel_delegate,
        ),
        body: AllPageStateContainer(_currentState, () {
          setState(() {
            _currentState = all_page_state.LoadingState();
          });
          getNetworkData();
        }),
      );
    }

    var walletAddressStr =
        "${S.of(context).wallet_address} ${UiUtil.shortEthAddress(WalletUtil.ethAddressToBech32Address(_address) ?? "***", limitLength: 9)}";

    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: S.of(context).cancel_delegate,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Expanded(
            child: LoadDataContainer(
              bloc: _loadDataBloc,
              enablePullUp: false,
              onRefresh: getNetworkData,
              child: BaseGestureDetector(
                context: context,
                child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Container(
                        color: Colors.white,
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 16.0, top: 18),
                              child: Row(
                                children: <Widget>[
                                  Text(S.of(context).receive_wallet,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16)),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0, top: 16, right: 8, bottom: 18),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text.rich(TextSpan(children: [
                                        TextSpan(
                                            text: _walletName,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16)),
                                        TextSpan(
                                            text: "",
                                            style: TextStyles.textC333S14bold),
                                      ])),
                                      Container(
                                        height: 4,
                                      ),
                                      Text(walletAddressStr,
                                          style: TextStyles.textC9b9b9bS12),
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
                              padding:
                                  const EdgeInsets.only(left: 16.0, top: 16),
                              child: Row(
                                children: <Widget>[
                                  Text(S.of(context).node_amount,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15)),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 16.0, top: 12),
                              child: profitListBigLightWidget(
                                [
                                  {
                                    S.of(context).node_total_staking:
                                        '${FormatUtil.formatPrice(double.parse(_nodeStartMin()))}'
                                  },
                                  {S.of(context).my_staking: '${_myStakingAmount()}'},
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 16.0, top: 18),
                              child: Row(
                                children: <Widget>[
                                  Text(S.of(context).cancel_amount,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15)),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0, top: 16, right: 18),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "HYN",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: HexColor("#35393E")),
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
                                        keyboardType: TextInputType.number,
                                        //inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                                        hint: S.of(context).please_enter_withdraw_amount,
                                        validator: (textStr) {
                                          if (textStr.length == 0) {
                                            return S
                                                .of(context)
                                                .please_input_hyn_count;
                                          }

                                          var inputValue =
                                              Decimal.tryParse(textStr);
                                          if (inputValue == null) {
                                            return S.of(context).please_enter_correct_amount;
                                          }

                                          if (inputValue > _myStakingAmount()) {
                                            return S.of(context).over_your_staking;
                                          }

                                          if (Decimal.parse(textStr) >
                                              ConvertTokenUnit.weiToEther(
                                                  weiBigInt: BigInt.parse(
                                                      _map3infoEntity
                                                              ?.staking ??
                                                          "0"))) {
                                            return S.of(context).over_node_total_staking;
                                          }

                                          /*
                                          if (_map3infoEntity.isCreator() &&
                                              _myStakingAmount() -
                                                      Decimal.parse(textStr) <
                                                  _minRemain()) {
                                            return S.of(context).remain_delegation_not_less_than('${_minRemain()}');
                                          } else {
                                            return null;
                                          }
                                          */
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0, top: 12, bottom: 18, right: 8),
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

  _minRemain() {
    print('[delegateMin]${_map3introduceEntity.delegateMin}');
    if (_map3infoEntity.isCreator()) {
      var min = Decimal.parse(_nodeStartMin()) *
          ConvertTokenUnit.weiToEther(
              weiBigInt: BigInt.parse(_map3infoEntity.feeRate));
      print('_minRemain feeRate: ${_map3infoEntity.feeRate} min: $min');
      return min;
    } else {
      return Decimal.parse('0');
    }
  }

  String _nodeStartMin() {
    return _map3introduceEntity.startMin ?? '0';
  }

  Decimal _myStakingAmount() {
    if (_map3infoEntity.mine == null || _microdelegations == null)
      return Decimal.parse("0");

    return ConvertTokenUnit.weiToEther(
        weiBigInt: BigInt.parse(
            '${FormatUtil.clearScientificCounting((_microdelegations?.pendingDelegation?.amount ?? 0).toDouble())}'));
  }

  bool _canCancelDelegation() {
    return _remainEpoch() < Decimal.parse('0');
  }

  Decimal _remainEpoch() {
    return Decimal.parse('${_unlockEpoch ?? 0}') -
        Decimal.parse('${_currentEpoch ?? 0}');
  }

  _epochHint() {
    if (!_canCancelDelegation()) {
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
                S.of(context).unlock_remain_epoch('${(_remainEpoch().toInt()).toString()}'),
                style: TextStyle(
                  color: DefaultColors.color999,
                ),
              )
            ],
          ),
        ),
      );
    } else {
      return SizedBox();
    }
  }

  Widget _confirmButtonWidget() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18.0, top: 10),
        child: Center(
          child: ClickOvalButton(
            S.of(context).confirm_cancel,
            () {
              if (!_formKey.currentState.validate()) {
                return;
              }

              var amount = _textEditingController?.text;

              var entity = PledgeMap3Entity(
                  payload: Payload(
                userIdentity: widget.map3infoEntity.nodeId,
              ));

              var message = ConfirmCancelMap3NodeMessage(
                entity: entity,
                map3NodeAddress: widget.map3infoEntity.address,
                amount: amount,
              );

              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Map3NodeConfirmPage(
                      message: message,
                    ),
                  ));
            },
            height: 46,
            width: MediaQuery.of(context).size.width - 37 * 2,
            fontSize: 18,
            isLoading: !_canCancelDelegation(),
          ),
        ),
      ),
    );
  }
}
