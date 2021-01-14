import 'dart:async';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/rp/bloc/bloc.dart';
import 'package:titan/src/components/rp/redpocket_component.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/vo/coin_vo.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/config/extends_icon_font.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/pages/mine/promote_qr_code_page.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_promotion_rule_entity.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_util.dart';
import 'package:titan/src/pages/red_pocket/rp_friend_invite_page.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/round_border_textfield.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';

import 'api/rp_api.dart';
import 'entity/rp_miners_entity.dart';
import 'entity/rp_my_level_info.dart';

class RpLevelUpgradePage extends StatefulWidget {
  final LevelRule levelRule;
  final RpPromotionRuleEntity promotionRuleEntity;

  RpLevelUpgradePage(this.levelRule, this.promotionRuleEntity);

  @override
  State<StatefulWidget> createState() {
    return _RpLevelUpgradeState();
  }
}

class _RpLevelUpgradeState extends BaseState<RpLevelUpgradePage> {
  final TextEditingController _textEditingController =
      new TextEditingController();
  final TextEditingController _addressEditController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _addressKey = GlobalKey<FormState>();

  final RPApi _rpApi = RPApi();
  final StreamController<String> _inputController =
      StreamController.broadcast();
  final LoadDataBloc _loadDataBloc = LoadDataBloc();

  RpMyLevelInfo _myLevelInfo;

  RpMinerInfo _inviter;

  CoinVo _coinVo;
  WalletVo _activatedWallet;

  String get _address =>
      _activatedWallet?.wallet?.getEthAccount()?.address ?? "";

  String get _walletName => _activatedWallet?.wallet?.keystore?.name ?? "";

  Decimal get _inputValue {
    var inputValue =
        Decimal.tryParse(_textEditingController?.text ?? '0') ?? Decimal.zero;
    return inputValue > Decimal.zero ? inputValue : Decimal.zero;
  }

  Decimal get _balanceValue =>
      Decimal.tryParse(FormatUtil.coinBalanceHumanRead(_coinVo)) ??
      Decimal.zero;

  //Decimal get _currentHoldValue => Decimal.tryParse(_myLevelInfo?.currentHoldingStr ?? '0') ?? Decimal.zero;
  Decimal get _holdingValue =>
      Decimal.tryParse(widget?.levelRule?.holdingStr ?? '0') ?? Decimal.zero;

  Decimal get _needHoldMinValue {
    var zeroValue = Decimal.zero;
    // var remainHoldValue = (_holdingValue - _currentHoldValue);
    var remainHoldValue = (_holdingValue);

    return remainHoldValue > zeroValue ? remainHoldValue : zeroValue;
  }

  //Decimal get _currentBurnValue => Decimal.tryParse(_myLevelInfo?.currBurningStr ?? '0') ?? Decimal.zero;
  Decimal get _burningValue =>
      Decimal.tryParse(widget?.levelRule?.burnStr ?? '0') ?? Decimal.zero;

  Decimal get _needBurnValue {
    var zeroValue = Decimal.zero;
    // var remainBurnValue = (_burningValue - _currentBurnValue);
    var remainBurnValue = (_burningValue);

    return remainBurnValue > zeroValue ? remainBurnValue : zeroValue;
  }

  Decimal get _needTotalMinValue {
    var zeroValue = Decimal.zero;

    var remainValue = _needHoldMinValue + _needBurnValue;
    return remainValue > zeroValue ? remainValue : zeroValue;
  }

  String get _needTotalMinValueStr =>
      S.of(context).at_least +
      FormatUtil.stringFormatCoinNum(_needTotalMinValue.toString()) +
      ' RP';

  bool _isLoading = false;
  bool _haveFinishRequest = false;

  TextStyle _textStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14,
  );

  @override
  void initState() {
    super.initState();

    var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext);
    _coinVo = wallet.getCoinVoBySymbol('RP');
    _activatedWallet = wallet.activatedWallet;
  }

  @override
  void onCreated() {
    getNetworkData();

    super.onCreated();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _myLevelInfo = RedPocketInheritedModel.of(context).rpMyLevelInfo;
  }

  @override
  void dispose() {
    print("[${widget.runtimeType}] dispose");

    _loadDataBloc.close();
    _inputController.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    var levelName = levelValueToLevelName(widget.promotionRuleEntity?.supplyInfo?.randomMinLevel ?? 4);
    var tips = S.of(context).rp_upgrade_tips_func(levelName);

    var currentHoldingStr = FormatUtil.stringFormatCoinNum(_myLevelInfo?.currentHoldingStr ?? '0');
    var currBurningStr = FormatUtil.stringFormatCoinNum(_myLevelInfo?.currBurningStr ?? '0');
    var currentHoldingBurning = S.of(context).rp_upgrade_current_func(currentHoldingStr, currBurningStr);

    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: S.of(context).rp_level_up,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Expanded(
            child: LoadDataContainer(
              bloc: _loadDataBloc,
              enablePullUp: false,
              onRefresh: getNetworkData,
              isStartLoading: false,
              child: BaseGestureDetector(
                context: context,
                child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          color: Colors.white,
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(top: 18),
                                child: Row(
                                  children: <Widget>[
                                    SizedBox(
                                      width: 100,
                                      child: Text(S.of(context).rp_level_up,
                                          style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12,
                                            color: HexColor('#999999'),
                                          )),
                                    ),
                                    Text(
                                      '${levelValueToLevelName(_myLevelInfo?.currentLevel)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                        color: HexColor('#999999'),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 12,
                                        right: 20,
                                      ),
                                      child: Text(
                                        '->',
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12,
                                          color: HexColor('#999999'),
                                        ),
                                      ),
                                    ),
                                    Text(
                                        '${levelValueToLevelName(widget?.levelRule?.level)} ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 18,
                                        )),
                                  ],
                                ),
                              ),
                              rpRowText(
                                title: S.of(context).rp_need_burn_amount,
                                amount: '$_needBurnValue RP',
                              ),
                              rpRowText(
                                title: S.of(context).rp_need_add_amount,
                                amount: '$_needHoldMinValue RP',
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 30),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Text(S.of(context).input_balance,
                                        style: _textStyle),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                        '${S.of(context).mortgage_wallet_balance(_walletName, FormatUtil.coinBalanceHumanReadFormat(_coinVo))}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12,
                                          color: HexColor('#999999'),
                                        )),
                                    SizedBox(
                                      width: 10,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 16,
                                  right: 50,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Flexible(
                                      flex: 1,
                                      child: Form(
                                        key: _formKey,
                                        child: Container(
                                          color: Colors.white,
                                          child: RoundBorderTextField(
                                            onChanged: (text) {
                                              if (text?.isNotEmpty ?? false) {
                                                _formKey.currentState.validate();
                                              }

                                              _inputController.add(text);
                                            },
                                            controller: _textEditingController,
                                            keyboardType:
                                                TextInputType.numberWithOptions(
                                                    decimal: true),
                                            inputFormatters: [
                                              LengthLimitingTextInputFormatter(
                                                  18),
                                              FilteringTextInputFormatter.allow(
                                                  RegExp("[0-9.]"))
                                            ],
                                            hint: _needTotalMinValueStr,
                                            validator: (textStr) {
                                              if (textStr.length == 0 &&
                                                  _needTotalMinValue >
                                                      Decimal.zero) {
                                                return S
                                                    .of(context)
                                                    .input_num_please;
                                              }

                                              if (Decimal.tryParse(textStr) ==
                                                  null) {
                                                return S
                                                    .of(context)
                                                    .please_enter_correct_amount;
                                              }

                                              if (_needTotalMinValue >
                                                  _inputValue) {
                                                return _needTotalMinValueStr;
                                              }

                                              if (_inputValue > _balanceValue) {
                                                return S
                                                    .of(context)
                                                    .input_count_over_wallet_balance;
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        top: 8,
                                        left: 16,
                                      ),
                                      child: Text(
                                          currentHoldingBurning,
                                          style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12,
                                            color: HexColor('#999999'),
                                          )),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4,),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 8,
                                      ),
                                      child: Text(
                                        '*',
                                        style: TextStyle(
                                          color: HexColor('#FF4C3B'),
                                          fontSize: 24,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 6,
                                    ),
                                    Expanded(
                                      child: Text.rich(
                                        TextSpan(
                                            text: S
                                                .of(context)
                                                .rp_add_holding_prevent_level_drop_1,
                                            style: TextStyle(
                                              color: HexColor('#333333'),
                                              fontSize: 12,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: ' Y ',
                                                style: TextStyle(
                                                  color: HexColor('#333333'),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              TextSpan(
                                                text: S
                                                    .of(context)
                                                    .rp_add_holding_prevent_level_drop_2,
                                                style: TextStyle(
                                                  color: HexColor('#333333'),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ]),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              StreamBuilder<Object>(
                                  stream: _inputController.stream,
                                  builder: (context, snapshot) {
                                    var isOver = _inputValue > _balanceValue;

                                    var content = '';
                                    Color textColor;

                                    if (isOver) {
                                      content =
                                          '（${S.of(context).insufficient_balance}）';
                                      textColor = HexColor('#FF4C3B');
                                    } else {
                                      content = '';
                                      textColor =
                                          Theme.of(context).primaryColor;
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.only(top: 30),
                                      child: Row(
                                        children: <Widget>[
                                          Text('${S.of(context).total}：',
                                              style: _textStyle),
                                          SizedBox(
                                            width: 16,
                                          ),
                                          Text('$_inputValue RP',
                                              style: _textStyle),
                                          SizedBox(
                                            width: 16,
                                          ),
                                          Text(
                                            content,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: textColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                              StreamBuilder<Object>(
                                  stream: _inputController.stream,
                                  builder: (context, snapshot) {
                                    var isFullBurn =
                                        _inputValue >= _needBurnValue;
                                    var preBurnStr = isFullBurn
                                        ? widget?.levelRule?.burnStr
                                        : '0';

                                    var inputHoldValue =
                                        (_inputValue - _needBurnValue);
                                    var isFullHold =
                                        inputHoldValue > Decimal.zero;
                                    var preHoldingStr = isFullHold
                                        ? inputHoldValue.toString()
                                        : '0';
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          top: 2, left: 50, right: 12),
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              S.of(context).rp_upgrade_detail_func(preBurnStr, preHoldingStr),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 12,
                                                  color: HexColor('#999999')),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 60,
                            left: 16,
                            right: 16,
                            bottom: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 16.0,
                                  bottom: 8,
                                ),
                                child: Text(S.of(context).precautions,
                                    style: TextStyle(
                                      color: HexColor("#333333"),
                                      fontSize: 16,
                                    )),
                              ),
                              rowTipsItem(
                                  tips),
                            ],
                          ),
                        ),
                        _confirmButtonWidget(),
                      ]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _confirmButtonWidget() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 30,
          bottom: 30,
        ),
        child: Center(
          child: ClickOvalButton(
            S.of(context).rp_level_up_now,
            _checkAction,
            height: 42,
            width: MediaQuery.of(context).size.width - 37 * 2,
            fontSize: 18,
            btnColor: [HexColor('#FF0527'), HexColor('#FF4D4D')],
            isLoading: _isLoading,
          ),
        ),
      ),
    );
  }

  Future getNetworkData() async {
    if (context != null) {
      BlocProvider.of<RedPocketBloc>(context).add(UpdateMyLevelInfoEvent());
    }

    if (context != null) {
      BlocProvider.of<WalletCmpBloc>(context)
          .add(UpdateActivatedWalletBalanceEvent());
    }

    if (mounted) {
      _loadDataBloc.add(RefreshSuccessEvent());
    }

    getRPMinerList();
  }

  void getRPMinerList() async {
    try {
      var netData = await _rpApi.getRPMinerList(
        _address,
        page: 1,
      );

      _inviter = netData.inviter;
      _haveFinishRequest = true;
    } catch (e) {
      LogUtil.toastException(e);
    }
  }

  _checkAction() {
    if (widget.levelRule == null) {
      Fluttertoast.showToast(
        msg: S.of(context).rp_select_upgrade_level,
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    FocusScope.of(context).requestFocus(FocusNode());

    if ((_needTotalMinValue > Decimal.zero) &&
        (!_formKey.currentState.validate())) {
      return;
    }

    //  计算 holding + burning > balance + remain;
    if (_inputValue > _balanceValue) {
      Fluttertoast.showToast(
        msg: S.of(context).rp_not_enough_to_selected_level,
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    // 检车是否有好友
    if (!_haveFinishRequest) {
      Fluttertoast.showToast(
        msg: S.of(context).get_recommender_failed,
        gravity: ToastGravity.CENTER,
      );

      getRPMinerList();

      return;
    }

    if (_inviter == null) {
      Future.delayed(Duration(milliseconds: 111)).then((_) {
        _showInviteAlertView();
      });
      return;
    }

    _upgradeAction();
  }

  _showInviteAlertView() {
    var border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(
        color: HexColor('#FFF2F2F2'),
        width: 0.5,
      ),
    );

    _addressEditController.text = "";

    var _basicAddressReg = RegExp(r'^(0x)?[0-9a-f]{40}', caseSensitive: false);
    var addressExample = 'hyn1ntjklkvx9jlkrz9';
    var addressHint = S.of(context).example + ': $addressExample...';
    var addressErrorHint = S.of(context).input_valid_hyn_address;

    UiUtil.showAlertView(
      context,
      title: S.of(context).set_recommender,
      isInputValue: true,
      actions: [
        ClickOvalButton(
          S.of(context).skip,
          () {
            Navigator.pop(context, false);

            Future.delayed(Duration(milliseconds: 111)).then((_) {
              _showIgnoreAlertView();
            });
          },
          width: 115,
          height: 36,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          fontColor: DefaultColors.color999,
          btnColor: [Colors.transparent],
        ),
        SizedBox(
          width: 20,
        ),
        ClickOvalButton(
          S.of(context).confirm,
          () async {
            if (!_addressKey.currentState.validate()) {
              return;
            }

            try {
              var inviteAddress = _addressEditController?.text ?? '';

              String inviteResult = await _rpApi.postRpInviter(
                  inviteAddress, _activatedWallet?.wallet);
              if (inviteResult?.isNotEmpty ?? false) {
                Fluttertoast.showToast(msg: S.of(context).rp_upgrade_continue_toast);

                getRPMinerList();

                _upgradeAction();
              }
            } catch (error) {
              LogUtil.toastException(error);
            }

            Navigator.pop(context, true);
          },
          width: 115,
          height: 36,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ],
      detail: S.of(context).input_friend_hyn_address_or_qrcode,
      contentItem: Material(
        child: Form(
          key: _addressKey,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.only(
              left: 22,
              right: 22,
              bottom: 16,
            ),
            child: Column(
              children: <Widget>[
                TextFormField(
                  autofocus: true,
                  controller: _addressEditController,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    var ethAddress = WalletUtil.bech32ToEthAddress(value);
                    if (ethAddress?.isEmpty ?? true) {
                      return S.of(context).recommender_address_can_not_empty;
                    } else if (!value.startsWith('hyn1')) {
                      return addressErrorHint;
                    } else if (!_basicAddressReg.hasMatch(ethAddress)) {
                      return addressErrorHint;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: HexColor('#FFF2F2F2'),
                    hintText: addressHint,
                    hintStyle: TextStyle(
                      color: HexColor('#FF999999'),
                      fontSize: 13,
                    ),
                    focusedBorder: border,
                    focusedErrorBorder: border,
                    enabledBorder: border,
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Colors.red,
                        width: 0.5,
                      ),
                    ),
                    suffixIcon: InkWell(
                      onTap: () async {
                        UiUtil.showScanImagePickerSheet(context,
                            callback: (String text) async {
                          _addressEditController.text = await _parseText(text);
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(
                          ExtendsIconFont.qrcode_scan,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    //contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  style: TextStyle(fontSize: 13),
                  onSaved: (value) {
                    // print("[$runtimeType] onSaved, inputValue:$value");
                  },
                  onChanged: (String value) {
                    // print("[$runtimeType] onChanged, inputValue:$value");
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> _parseText(String scanStr) async {
    if (scanStr == null) {
      return '';
    } else if (scanStr.contains(PromoteQrCodePage.downloadDomain) ||
        scanStr.contains(RpFriendInvitePage.shareDomain)) {
      var fromArr = scanStr.split("from=");
      if (fromArr[1].length > 0) {
        fromArr = fromArr[1].split("&");
        if (fromArr[0].length > 0) {
          return fromArr[0];
        }
      }
    } else if (scanStr.startsWith('hyn1')) {
      return scanStr;
    }
    return '';
  }

  _showIgnoreAlertView() async {
    UiUtil.showAlertView(
      context,
      title: S.of(context).system_recommend_hint,
      actions: [
        ClickOvalButton(
          S.of(context).back,
          () {
            Navigator.pop(context, false);

            _showInviteAlertView();
          },
          width: 115,
          height: 36,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          fontColor: DefaultColors.color999,
          btnColor: [Colors.transparent],
        ),
        SizedBox(
          width: 20,
        ),
        ClickOvalButton(
          S.of(context).confirm,
          () {
            Navigator.pop(context, true);
            _upgradeAction();
          },
          width: 115,
          height: 36,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ],
      content: S.of(context).rp_upgrade_no_recommender_warning,
    );
  }

  _upgradeAction() async {
    var password = await UiUtil.showWalletPasswordDialogV2(
        context, _activatedWallet.wallet);
    if (password == null) {
      return;
    }

    var burningAmount = ConvertTokenUnit.strToBigInt(widget.levelRule.burnStr);

    var inputHoldValue = (_inputValue - _needBurnValue);
    inputHoldValue =
        inputHoldValue > Decimal.zero ? inputHoldValue : Decimal.zero;
    var holdingAmount =
        ConvertTokenUnit.strToBigInt(inputHoldValue?.toString() ?? '0');

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    Future.delayed(Duration(milliseconds: 111)).then((_) async {
      try {
        await _rpApi.postRpDepositAndBurn(
          from: _myLevelInfo?.currentLevel ?? 0,
          to: widget.levelRule.level,
          depositAmount: holdingAmount,
          burningAmount: burningAmount,
          activeWallet: _activatedWallet,
          password: password,
        );

        Fluttertoast.showToast(
          msg: S.of(context).rp_level_up_broadcast_sent,
          gravity: ToastGravity.CENTER,
        );
        Navigator.of(context)..pop()..pop();

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        LogUtil.toastException(e);
      }
    });
  }
}

Widget rpRowText({
  String title,
  String amount,
  double width = 100,
}) {
  return Padding(
    padding: const EdgeInsets.only(top: 18),
    child: Row(
      children: <Widget>[
        SizedBox(
          width: width,
          child: Text(title,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 12,
                color: HexColor('#999999'),
              )),
        ),
        Text(amount,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: HexColor('#333333'),
            )),
      ],
    ),
  );
}
