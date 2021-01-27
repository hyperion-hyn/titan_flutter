import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/rp/bloc/bloc.dart';
import 'package:titan/src/components/rp/bloc/redpocket_bloc.dart';
import 'package:titan/src/components/rp/redpocket_component.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/vo/coin_view_vo.dart';
import 'package:titan/src/components/wallet/vo/wallet_view_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/pages/red_pocket/api/rp_api.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_util.dart';
import 'package:titan/src/pages/red_pocket/rp_level_upgrade_page.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/round_border_textField.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';

import 'entity/rp_my_level_info.dart';
import 'entity/rp_promotion_rule_entity.dart';

class RpLevelWithdrawPage extends StatefulWidget {
  RpLevelWithdrawPage();

  @override
  State<StatefulWidget> createState() {
    return _RpLevelWithdrawState();
  }
}

class _RpLevelWithdrawState extends BaseState<RpLevelWithdrawPage> {
  final TextEditingController _textEditingController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final StreamController<String> _inputController = StreamController.broadcast();
  final LoadDataBloc _loadDataBloc = LoadDataBloc();
  final RPApi _rpApi = RPApi();

  RpMyLevelInfo _myLevelInfo;

  int get _currentLevel => _myLevelInfo?.currentLevel ?? 0;

  RpPromotionRuleEntity _promotionRuleEntity;
  List<LevelRule> get _staticDataList => (_promotionRuleEntity?.static ?? []).toList();

  LevelRule get _currentLevelRule {
    LevelRule current;

    if (_staticDataList.isNotEmpty) {
      for (var model in _staticDataList) {
        if (model.level == _currentLevel && _currentLevel > 0) {
          current = model;
          break;
        }
      }
    }
    return current;
  }

  CoinViewVo _coinVo;
  WalletViewVo _activatedWallet;
  String get _walletName => _activatedWallet?.wallet?.keystore?.name ?? "";

  bool _isLoading = false;

  Decimal get _inputValue =>
      Decimal.tryParse(
        _textEditingController?.text ?? '0',
      ) ??
      Decimal.zero;

  Decimal get _currentHoldValue =>
      Decimal.tryParse(
        _myLevelInfo?.currentHoldingStr ?? '0',
      ) ??
      Decimal.zero;

  int get _toLevel {
    var holding = _currentHoldValue;

    var remainHolding = holding - _inputValue;
    var needHolding = Decimal.tryParse(
          _currentLevelRule?.holdingStr ?? '0',
        ) ??
        Decimal.zero;
    var level = _currentLevel;

    // 1.先和当前量级需持币比较
    if ((needHolding > Decimal.zero) && (remainHolding > Decimal.zero) && (remainHolding >= needHolding)) {
      level = _currentLevel;
    } else {
      // 2.不然，从筛选出对应下降量级
      var filterDataList = _staticDataList.where((element) => element.level < _currentLevel).toList().reversed.toList();
      if ((filterDataList?.isNotEmpty ?? false) && remainHolding > Decimal.zero) {
        var firstObj = filterDataList?.firstWhere((levelRule) {
          var holding = Decimal.tryParse(
                levelRule?.holdingStr ?? '0',
              ) ??
              Decimal.zero;

          return remainHolding >= holding;
        }, orElse: () => null);

        level = firstObj?.level ?? 0;
      } else {
        level = 0;
      }
    }
    print('[_getLevelByHolding] inputValue: $_inputValue， level：$level');

    return level;
  }

  @override
  void initState() {
    super.initState();

    var wallet = WalletInheritedModel.of(Keys.rootKey.currentContext);
    _coinVo = wallet.getCoinVoBySymbol('RP');
    _activatedWallet = wallet.activatedWallet;
  }

  @override
  void onCreated() {

    super.onCreated();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _myLevelInfo = RedPocketInheritedModel.of(context).rpMyLevelInfo;
    _promotionRuleEntity = RedPocketInheritedModel.of(context).rpPromotionRule;
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

    var holdingStr = _currentLevelRule?.holdingStr ?? '0';
    var holdingStrTips = S.of(context).rp_withdraw_tips_func(holdingStr);

    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: S.of(context).rp_retrive_holding,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Expanded(
            child: LoadDataContainer(
              bloc: _loadDataBloc,
              enablePullUp: false,
              onRefresh: getNetworkData,
              onLoadData: getNetworkData,
              child: BaseGestureDetector(
                context: context,
                child: SingleChildScrollView(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      padding: const EdgeInsets.only(
                        left: 16,
                      ),
                      color: Colors.white,
                      child: Column(
                        children: <Widget>[
                          rpRowText(
                            title: '${S.of(context).rp_current_level}${levelValueToLevelName(_currentLevel)}${S.of(context).rp_hold_need_amount}',
                            amount: '${_currentLevelRule?.holdingStr ?? '0'} RP',
                            width: 110,
                          ),
                          rpRowText(
                            title: S.of(context).rp_current_holding,
                            amount: '${_myLevelInfo?.currentHoldingStr ?? '0'} RP',
                            width: 110,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  S.of(context).rp_retrive_holding,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: HexColor('#333333'),
                                  ),
                                ),
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
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 16,
                              right: 16,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: Form(
                                    key: _formKey,
                                    child: RoundBorderTextField(
                                      onChanged: (text) {
                                        _formKey.currentState.validate();

                                        _inputController.add(text);
                                      },
                                      controller: _textEditingController,
                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(18),
                                        FilteringTextInputFormatter.allow(RegExp("[0-9.]"))
                                      ],
                                      hintText: S.of(context).please_enter_withdraw_amount,
                                      validator: (textStr) {
                                        var inputValue = Decimal.tryParse(textStr);

                                        if (inputValue == null) {
                                          return S.of(context).please_enter_correct_amount;
                                        }

                                        var holding = _currentHoldValue;

                                        if (textStr.length == 0 || inputValue == Decimal.fromInt(0)) {
                                          return S.of(context).input_valid_withdraw_amount;
                                        }
                                        if (inputValue > holding) {
                                          return S.of(context).rp_over_current_holding;
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                StreamBuilder<Object>(
                                    stream: _inputController.stream,
                                    builder: (context, snapshot) {
                                      bool isShowDown = (_toLevel < _currentLevel &&
                                          _currentHoldValue >= _inputValue &&
                                          _inputValue > Decimal.zero);

                                      return isShowDown
                                          ? Row(
                                              // crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                    left: 16,
                                                    right: 16,
                                                  ),
                                                  child: Image.asset(
                                                    'res/drawable/ic_rp_level_down.png',
                                                    width: 15,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                    right: 4,
                                                  ),
                                                  child: Text(
                                                    S.of(context).rp_level,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.normal,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  '${levelValueToLevelName(_toLevel)} ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Container(
                                              width: 60,
                                            );
                                    }),
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
                              Expanded(
                                child: Text(
                                  holdingStrTips,
                                  style: TextStyle(
                                    color: HexColor('#333333'),
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 60,
                              //left: 16,
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
                                rowTipsItem(S.of(context).rp_re_burn_to_previous_level),
                              ],
                            ),
                          ),
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
        padding: const EdgeInsets.only(top: 60),
        child: Center(
          child: ClickOvalButton(
            S.of(context).rp_retrive_holding,
            _confirmAction,
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

  _confirmAction() {
    FocusScope.of(context).requestFocus(FocusNode());

    if (!_formKey.currentState.validate()) {
      return;
    }

    Future.delayed(Duration(milliseconds: 111)).then((_) {
      _showAlertView();
    });
  }

  _showAlertView() {
    if (_toLevel == _currentLevel) {
      _withdrawAction(false);
      return;
    }

    UiUtil.showAlertView(
      context,
      title: S.of(context).important_hint,
      actions: [
        ClickOvalButton(
          S.of(context).cancel,
          () {
            Navigator.pop(context, true);
          },
          width: 115,
          height: 36,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          fontColor: DefaultColors.color333,
          btnColor: [Colors.transparent],
        ),
        ClickOvalButton(
          S.of(context).rp_confirm_retrive,
          () {
            _withdrawAction(true);
          },
          width: 115,
          height: 36,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          //btnColor: [HexColor('#FF0527'), HexColor('#FF4D4D')],
        ),
      ],
      content:
          S.of(context).rp_retrive_detail(_inputValue, levelValueToLevelName(_currentLevel), levelValueToLevelName(_toLevel)),
      isInputValue: false,
    );
  }

  _withdrawAction(bool isPop) async {
    if (isPop) Navigator.pop(context, true);

    if (!_formKey.currentState.validate()) {
      return;
    }

    var inputText = _textEditingController?.text ?? '';

    if (inputText.isEmpty) {
      return;
    }

    var _activeWallet = WalletInheritedModel.of(Keys.rootKey.currentContext)?.activatedWallet;

    var password = await UiUtil.showWalletPasswordDialogV2(context, _activeWallet.wallet);
    if (password == null) {
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    var withdrawAmount = ConvertTokenUnit.strToBigInt(inputText);
    try {
      await _rpApi.postRpWithdraw(
        withdrawAmount: withdrawAmount,
        activeWallet: _activeWallet,
        password: password,
        from: _currentLevel,
        to: _toLevel,
      );
      Navigator.pop(context, true);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        LogUtil.toastException(e);

        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future getNetworkData() async {

    if (context != null) {
      BlocProvider.of<RedPocketBloc>(context).add(UpdateMyLevelInfoEvent());
    }

    if (context != null) {
      BlocProvider.of<WalletCmpBloc>(context).add(UpdateActivatedWalletBalanceEvent());
    }

    if (context != null) {
      BlocProvider.of<RedPocketBloc>(context).add(UpdatePromotionRuleEvent());
    }

    //if (mounted) {
      _loadDataBloc.add(RefreshSuccessEvent());
    //}
  }
}
