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
import 'package:titan/src/pages/red_pocket/entity/rp_promotion_rule_entity.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_util.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/round_border_textfield.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';

import 'api/rp_api.dart';
import 'entity/rp_my_level_info.dart';

class RpLevelUpgradePage extends StatefulWidget {
  final LevelRule levelRule;
  final RpPromotionRuleEntity promotionRuleEntity;
  final bool isStatic;

  RpLevelUpgradePage(this.levelRule, this.promotionRuleEntity, {this.isStatic});

  @override
  State<StatefulWidget> createState() {
    return _RpLevelUpgradeState();
  }
}

class _RpLevelUpgradeState extends BaseState<RpLevelUpgradePage> {
  final TextEditingController _textEditingController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final RPApi _rpApi = RPApi();
  final StreamController<String> _inputController = StreamController.broadcast();
  final LoadDataBloc _loadDataBloc = LoadDataBloc();

  RpMyLevelInfo _myLevelInfo;
  CoinVo _coinVo;
  WalletVo _activatedWallet;

  Decimal get _inputValue {
    var zeroValue = Decimal.zero;
    var inputValue = Decimal.tryParse(_textEditingController?.text ?? '0') ?? zeroValue;
    return inputValue;
  }

  Decimal get _balanceValue => Decimal.tryParse(FormatUtil.coinBalanceHumanRead(_coinVo)) ?? Decimal.zero;

  String get _walletName => _activatedWallet?.wallet?.keystore?.name ?? "";

  Decimal get _needTotalMinValue {
    var zeroValue = Decimal.zero;
    var holdValue = Decimal.tryParse(widget?.levelRule?.holdingStr ?? '0') ?? zeroValue;
    var burnValue = Decimal.tryParse(widget?.levelRule?.burnStr ?? '0') ?? zeroValue;

    var currentHoldValue = Decimal.tryParse(_myLevelInfo?.currentHoldingStr ?? '0') ?? zeroValue;
    var remainHoldValue = (holdValue - currentHoldValue);
    remainHoldValue = remainHoldValue > zeroValue ? remainHoldValue : zeroValue;

    var remainValue = remainHoldValue + burnValue;
    return remainValue > zeroValue ? remainValue : zeroValue;
  }

  Decimal get _needHoldMinValue {
    var zeroValue = Decimal.zero;
    var holdValue = Decimal.tryParse(widget?.levelRule?.holdingStr ?? '0') ?? zeroValue;

    var currentHoldValue = Decimal.tryParse(_myLevelInfo?.currentHoldingStr ?? '0') ?? zeroValue;
    var remainHoldValue = (holdValue - currentHoldValue);

    return remainHoldValue > zeroValue ? remainHoldValue : zeroValue;
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

    // _totalValue = Decimal.tryParse(widget?.levelRule?.burnStr ?? '0') ?? Decimal.fromInt(0);
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
                          title: '需燃烧',
                          amount: '${widget?.levelRule?.burnStr ?? '--'} RP',
                        ),
                        rpRowText(
                          title: widget.isStatic ? '最小持币' : '需增加持币',
                          amount:
                              widget.isStatic ? '${widget?.levelRule?.holdingStr ?? '--'} RP' : '$_needHoldMinValue RP',
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
                              Expanded(
                                child: Text('当前持币 ${_myLevelInfo?.currentHoldingStr ?? '0'} RP ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 12,
                                      color: HexColor('#999999'),
                                    )),
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

                                      var inputValue = Decimal.tryParse(textStr);
                                      if (inputValue == null) {
                                        return S.of(context).please_enter_correct_amount;
                                      }

                                      if (_needTotalMinValue > inputValue) {
                                        return _needTotalMinValueStr;
                                      }

                                      if (inputValue > _balanceValue) {
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

                              var inputValue = _inputValue > Decimal.zero ? _inputValue : Decimal.zero;

                              return Padding(
                                padding: const EdgeInsets.only(top: 30),
                                child: Row(
                                  children: <Widget>[
                                    Text('合计：', style: _textStyle),
                                    SizedBox(
                                      width: 16,
                                    ),
                                    Text('$inputValue RP', style: _textStyle),
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
                              var burnValue = Decimal.tryParse(widget?.levelRule?.burnStr ?? '0') ?? Decimal.zero;
                              var isFullBurn = _inputValue > burnValue;
                              var preBurnStr = isFullBurn ? widget?.levelRule?.burnStr : '0';

                              //var holdingValue = Decimal.tryParse(widget?.levelRule?.holdingStr ?? '0') ?? Decimal.zero;
                              var inputHoldValue = (_inputValue - burnValue);
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
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 4,
                            right: 8,
                          ),
                          child: Image.asset(
                            'res/drawable/error_rounded.png',
                            width: 12,
                            height: 12,
                            color: HexColor('#C3A16D'),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '如果你还没有推荐人，系统将为你随机设定一个量级 ${levelValueToLevelName(widget.promotionRuleEntity?.supplyInfo?.randomMinLevel ?? 4)} 以上的账户地址为推荐人',
                            style: TextStyle(
                              color: HexColor('#C3A16D'),
                              // color: Theme.of(context).primaryColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
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
        padding: const EdgeInsets.only(top: 30),
        child: Center(
          child: ClickOvalButton(
            '马上提升',
            _upgradeAction,
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
      BlocProvider.of<RedPocketBloc>(context).add(UpdateMyLevelInfoEntityEvent());
    }

    if (context != null) {
      BlocProvider.of<WalletCmpBloc>(context).add(UpdateActivatedWalletBalanceEvent());
    }

    if (mounted) {
      _loadDataBloc.add(RefreshSuccessEvent());
    }
  }

  _upgradeAction() async {
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

    var password = await UiUtil.showWalletPasswordDialogV2(context, _activatedWallet.wallet);
    if (password == null) {
      return;
    }

    var burningAmount = ConvertTokenUnit.strToBigInt(widget.levelRule.burnStr);
    var depositAmount = ConvertTokenUnit.strToBigInt(_textEditingController?.text ?? '0');

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
          depositAmount: depositAmount,
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

Widget rpRowText({String title, String amount, double width = 100,}) {
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
