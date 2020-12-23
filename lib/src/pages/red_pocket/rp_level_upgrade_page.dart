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
  final TextEditingController _textEditingController = new TextEditingController();
  final TextEditingController _addressEditController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _addressKey = GlobalKey<FormState>();

  final RPApi _rpApi = RPApi();
  final StreamController<String> _inputController = StreamController.broadcast();
  final LoadDataBloc _loadDataBloc = LoadDataBloc();

  RpMyLevelInfo _myLevelInfo;

  RpMinerInfo _inviter;

  CoinVo _coinVo;
  WalletVo _activatedWallet;
  String get _address => _activatedWallet?.wallet?.getEthAccount()?.address ?? "";
  String get _walletName => _activatedWallet?.wallet?.keystore?.name ?? "";

  Decimal get _inputValue {
    var inputValue = Decimal.tryParse(_textEditingController?.text ?? '0') ?? Decimal.zero;
    return inputValue > Decimal.zero ? inputValue : Decimal.zero;
  }

  Decimal get _balanceValue => Decimal.tryParse(FormatUtil.coinBalanceHumanRead(_coinVo)) ?? Decimal.zero;

  //Decimal get _currentHoldValue => Decimal.tryParse(_myLevelInfo?.currentHoldingStr ?? '0') ?? Decimal.zero;
  Decimal get _holdingValue => Decimal.tryParse(widget?.levelRule?.holdingStr ?? '0') ?? Decimal.zero;
  Decimal get _needHoldMinValue {
    var zeroValue = Decimal.zero;
    // var remainHoldValue = (_holdingValue - _currentHoldValue);
    var remainHoldValue = (_holdingValue);

    return remainHoldValue > zeroValue ? remainHoldValue : zeroValue;
  }

  //Decimal get _currentBurnValue => Decimal.tryParse(_myLevelInfo?.currBurningStr ?? '0') ?? Decimal.zero;
  Decimal get _burningValue => Decimal.tryParse(widget?.levelRule?.burnStr ?? '0') ?? Decimal.zero;
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

  String get _needTotalMinValueStr => '至少' + FormatUtil.stringFormatCoinNum(_needTotalMinValue.toString()) + ' RP';

  bool _isLoading = false;

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
    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: '提升量级',
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
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                                child: Text('提升量级',
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
                              Text('${levelValueToLevelName(widget?.levelRule?.level)} ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  )),
                            ],
                          ),
                        ),
                        rpRowText(
                          title: '需燃烧量',
                          amount: '$_needBurnValue RP',
                        ),
                        rpRowText(
                          title: '需增加持币',
                          amount: '$_needHoldMinValue RP',
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text('输入金额', style: _textStyle),
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
                                  child: RoundBorderTextField(
                                    onChanged: (text) {
                                      if (text?.isNotEmpty ?? false) {
                                        _formKey.currentState.validate();
                                      }

                                      _inputController.add(text);
                                    },
                                    controller: _textEditingController,
                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(18),
                                      FilteringTextInputFormatter.allow(RegExp("[0-9.]"))
                                    ],
                                    hint: _needTotalMinValueStr,
                                    validator: (textStr) {
                                      if (textStr.length == 0 && _needTotalMinValue > Decimal.zero) {
                                        return '请输入数量';
                                      }

                                      if (Decimal.tryParse(textStr) == null) {
                                        return S.of(context).please_enter_correct_amount;
                                      }

                                      if (_needTotalMinValue > _inputValue) {
                                        return _needTotalMinValueStr;
                                      }

                                      if (_inputValue > _balanceValue) {
                                        return '输入数量超过了钱包余额';
                                      }
                                    },
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
                                padding: const EdgeInsets.only(top: 8, left: 16,),
                                child: Text(
                                    '当前持币 ${FormatUtil.stringFormatCoinNum(_myLevelInfo?.currentHoldingStr ?? '0')} RP，燃烧量 ${FormatUtil.stringFormatCoinNum(_myLevelInfo?.currBurningStr ?? '0')} RP',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 12,
                                      color: HexColor('#999999'),
                                    )),
                              ),
                            ),
                          ],
                        ),
                        Row(
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
                            Text.rich(
                              TextSpan(
                                  text: '为防止因',
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
                                      text: '增长导致掉级，建议适当增加持币量',
                                      style: TextStyle(
                                        color: HexColor('#333333'),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ]),
                            )
                          ],
                        ),
                        StreamBuilder<Object>(
                            stream: _inputController.stream,
                            builder: (context, snapshot) {
                              var isOver = _inputValue > _balanceValue;

                              var content = '';
                              Color textColor;

                              if (isOver) {
                                content = '（余额不足）';
                                textColor = HexColor('#FF4C3B');
                              } else {
                                content = '';
                                textColor = Theme.of(context).primaryColor;
                              }

                              return Padding(
                                padding: const EdgeInsets.only(top: 30),
                                child: Row(
                                  children: <Widget>[
                                    Text('合计：', style: _textStyle),
                                    SizedBox(
                                      width: 16,
                                    ),
                                    Text('$_inputValue RP', style: _textStyle),
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
                              var isFullBurn = _inputValue > _needBurnValue;
                              var preBurnStr = isFullBurn ? widget?.levelRule?.burnStr : '0';

                              var inputHoldValue = (_inputValue - _needBurnValue);
                              var isFullHold = inputHoldValue > Decimal.zero;
                              var preHoldingStr = isFullHold ? inputHoldValue.toString() : '0';
                              return Padding(
                                padding: const EdgeInsets.only(top: 2, left: 50, right: 12),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        '(其中：燃烧:$preBurnStr RP, 持币:$preHoldingStr RP)',
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal, fontSize: 12, color: HexColor('#999999')),
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
                            '如果你还没有推荐人，系统将为你随机设定一个量级 ${levelValueToLevelName(widget.promotionRuleEntity?.supplyInfo?.randomMinLevel ?? 4)} 以上的账户地址为推荐人'),
                      ],
                    ),
                  ),
                  _confirmButtonWidget(),
                ])),
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
            '马上提升',
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
      BlocProvider.of<WalletCmpBloc>(context).add(UpdateActivatedWalletBalanceEvent());
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
    } catch (e) {}
  }

  _checkAction() {
    if (widget.levelRule == null) {
      Fluttertoast.showToast(
        msg: '请先选择想要升级的量级！',
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    FocusScope.of(context).requestFocus(FocusNode());

    if ((_needTotalMinValue > Decimal.zero) && (!_formKey.currentState.validate())) {
      return;
    }

    //  计算 holding + burning > balance + remain;
    if (_inputValue > _balanceValue) {
      Fluttertoast.showToast(
        msg: '钱包余额不足以升级到当前选中量级！',
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    // 检车是否有好友
    if (_inviter == null) {
      getRPMinerList();

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

    //var defaultHint = '请先设置推荐人的HYN地址';
    var _basicAddressReg = RegExp(r'^(0x)?[0-9a-f]{40}', caseSensitive: false);
    var addressExample = 'hyn1ntjklkvx9jlkrz9';
    var addressHint = S.of(context).example + ': $addressExample...';
    var addressErrorHint = '请输入合法的HYN地址';

    UiUtil.showAlertView(
      context,
      title: '设置推荐人',
      isInputValue: true,
      actions: [
        ClickOvalButton(
          '跳过',
          () {
            Navigator.pop(context, false);

            _showIgnoreAlertView();
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

              String inviteResult = await _rpApi.postRpInviter(inviteAddress, _activatedWallet?.wallet);
              if (inviteResult != null && inviteResult.isNotEmpty) {
                Fluttertoast.showToast(msg: "邀请成功, 继续升级吧！");

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
      detail: '请输入好友HYN地址。也可扫描好友钱包收款码、好友邀请码',
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
                      return '推荐人地址不能为空!';
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
                        UiUtil.showImagePickerSheet(context, callback: (String text) async {
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
    print("[扫描结果] scanStr:$scanStr");

    if (scanStr == null) {
      return '';
    } else if (scanStr.contains(PromoteQrCodePage.downloadDomain) || scanStr.contains(RpFriendInvitePage.shareDomain)) {
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
      title: '系统推荐提示',
      actions: [
        ClickOvalButton(
          '返回',
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
      content: '你还没设置推荐人，如果继续升级的话，系统会为你随机设置一个量级D以上的账户作为你的推荐人，我们不推荐此类做法，你确定继续升级吗？',
    );
  }

  _upgradeAction() async {
    var password = await UiUtil.showWalletPasswordDialogV2(context, _activatedWallet.wallet);
    if (password == null) {
      return;
    }

    var burningAmount = ConvertTokenUnit.strToBigInt(widget.levelRule.burnStr);

    var inputHoldValue = (_inputValue - _needBurnValue);
    inputHoldValue = inputHoldValue > Decimal.zero ? inputHoldValue : Decimal.zero;
    var holdingAmount = ConvertTokenUnit.strToBigInt(inputHoldValue?.toString() ?? '0');

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
          msg: '提升量级请求已广播！',
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
