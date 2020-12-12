import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
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
  final RpMyLevelInfo rpMyLevelInfo;
  final LevelRule levelRule;
  final RpPromotionRuleEntity promotionRuleEntity;

  RpLevelUpgradePage(this.rpMyLevelInfo, this.levelRule, this.promotionRuleEntity);

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

  Decimal _totalValue;

  Decimal get _totalNeedValue {
    var zeroValue = Decimal.zero;
    var burnValue = Decimal.tryParse(widget?.levelRule?.burnStr ?? '0') ?? zeroValue;
    return _remainValue + burnValue;
  }

  Decimal get _balanceValue => Decimal.tryParse(FormatUtil.coinBalanceHumanRead(_coinVo)) ?? Decimal.zero;

  String get _address => _activatedWallet?.wallet?.getEthAccount()?.address ?? "";
  String get _walletName => _activatedWallet?.wallet?.keystore?.name ?? "";

  Decimal get _remainValue {
    var zeroValue = Decimal.zero;
    var holdValue = Decimal.tryParse(widget?.levelRule?.holdingStr ?? '0') ?? zeroValue;
    var currentHoldValue = Decimal.tryParse(widget?.rpMyLevelInfo?.currentHoldingStr ?? '0') ?? zeroValue;
    var remainValue = holdValue - currentHoldValue;
    return remainValue > zeroValue ? remainValue : zeroValue;
  }

  String get _remainStr => '至少' + FormatUtil.stringFormatCoinNum(_remainValue.toString()) + ' RP';

  @override
  void initState() {
    super.initState();

    _myLevelInfo = widget.rpMyLevelInfo;

    var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext);
    _coinVo = wallet.getCoinVoBySymbol('RP');
    _activatedWallet = wallet.activatedWallet;

    _totalValue = Decimal.tryParse(widget?.levelRule?.burnStr ?? '0') ?? Decimal.fromInt(0);
  }

  @override
  void onCreated() {
    getNetworkData();

    super.onCreated();
  }

  @override
  void dispose() {
    print("[${widget.runtimeType}] dispose");

    _loadDataBloc.close();
    _inputController.close();

    super.dispose();
  }

  Future getNetworkData() async {
    try {
      _myLevelInfo = await _rpApi.getRPMyLevelInfo(_address);

      if (mounted) {
        setState(() {
          _loadDataBloc.add(RefreshSuccessEvent());
        });
      }
    } catch (e) {
      if (mounted) {
        LogUtil.toastException(e);

        setState(() {
          _loadDataBloc.add(RefreshFailEvent());
        });
      }
    }
  }

  TextStyle _textStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14,
  );

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
              isStartLoading: true,
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
                              Text('提升到量级 ${levelValueToLevelName(widget?.levelRule?.level)} ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  )),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Row(
                            children: <Widget>[
                              Text('需燃烧', style: _textStyle),
                              SizedBox(
                                width: 16,
                              ),
                              Text('${widget?.levelRule?.burnStr ?? '0'} RP', style: _textStyle),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text('转入持币', style: _textStyle),
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

                                      var inputValue = Decimal.tryParse(text ?? '0') ?? Decimal.zero;
                                      var burnValue =
                                          Decimal.tryParse(widget?.levelRule?.burnStr ?? '0') ?? Decimal.zero;
                                      //print("1, text:$text, holdValue:$holdValue");

                                      _totalValue = (inputValue + burnValue);
                                      _inputController.add(text);
                                    },
                                    controller: _textEditingController,
                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    hint: _remainStr,
                                    validator: (textStr) {
                                      if (textStr.length == 0 && _remainValue > Decimal.zero) {
                                        return '请输入数量';
                                      }

                                      var inputValue = Decimal.tryParse(textStr);
                                      if (inputValue == null && _remainValue > Decimal.zero) {
                                        return S.of(context).please_enter_correct_amount;
                                      }

                                      if (_remainValue > inputValue) {
                                        return _remainStr;
                                      }

                                      //print("2, inputValue:$inputValue, balanceValue:$balanceValue");

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
                            Text(
                              '为防止因Y增长导致掉级，建议适当增加持币量',
                              style: TextStyle(
                                color: HexColor('#333333'),
                                fontSize: 12,
                              ),
                            )
                          ],
                        ),
                        StreamBuilder<Object>(
                            stream: _inputController.stream,
                            builder: (context, snapshot) {
                              var isOver = _totalValue != null && _totalValue > _balanceValue;
                              var isFull = _totalValue != null && _totalValue >= _totalNeedValue;
                              var content = '';
                              Color textColor;

                              if (isOver) {
                                content = '（余额不足）';
                                textColor = HexColor('#FF4C3B');
                              } else {
                                if (isFull) {
                                  content = '（满足要求）';
                                  textColor = Theme.of(context).primaryColor;
                                } else {
                                  content = '（未满足要求）';
                                  textColor = HexColor('#999999');
                                }
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Row(
                                  children: <Widget>[
                                    Text('合计：', style: _textStyle),
                                    SizedBox(
                                      width: 16,
                                    ),
                                    Text('${_totalValue ?? '0'} RP', style: _textStyle),
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
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 60,
                      left: 16,
                      right: 16,
                    ),
                    child: Text(
                      '提示：如果你还没有推荐人，系统将为你随机设定一个量级 ${levelValueToLevelName(widget.promotionRuleEntity?.supplyInfo?.randomMinLevel ?? 4)} 以上的账户地址为推荐人',
                      style: TextStyle(
                        color: HexColor('#C3A16D'),
                        fontSize: 12,
                      ),
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

  bool _isLoading = false;

  _upgradeAction() async {
    if (widget.levelRule == null) {
      Fluttertoast.showToast(
        msg: '请先选择想要升级的量级！',
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    FocusScope.of(context).requestFocus(FocusNode());

    if ((_remainValue > Decimal.zero) && (!_formKey.currentState.validate())) {
      return;
    }

    // todo: 计算 holding + burning > balance;
    if (_totalValue > _balanceValue) {
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
