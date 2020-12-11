import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/red_pocket/api/rp_api.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_util.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/round_border_textfield.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';

import 'entity/rp_my_level_info.dart';
import 'entity/rp_promotion_rule_entity.dart';

class RpLevelRetrievePage extends StatefulWidget {
  final RpMyLevelInfo rpMyLevelInfo;

  RpLevelRetrievePage(this.rpMyLevelInfo);

  @override
  State<StatefulWidget> createState() {
    return _RpLevelRetrieveState();
  }
}

class _RpLevelRetrieveState extends BaseState<RpLevelRetrievePage> {
  TextEditingController _textEditingController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  double minTotal = 0;
  double remainTotal = 0;
  RpPromotionRuleEntity _promotionRuleEntity;

  int get _currentLevel => widget?.rpMyLevelInfo?.currentLevel ?? 0;

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

  LoadDataBloc _loadDataBloc = LoadDataBloc();
  final RPApi _rpApi = RPApi();
  var _address = "";

  @override
  void initState() {
    super.initState();

    var activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext)?.activatedWallet;
    _address = activatedWallet?.wallet?.getEthAccount()?.address ?? "";
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
    super.dispose();
  }

  Future getNetworkData() async {
    try {
      var netData = await _rpApi.getRPPromotionRule(_address);

      if (netData?.static?.isNotEmpty ?? false) {
        _promotionRuleEntity = netData;
        print("[$runtimeType] getNetworkData, count:${_staticDataList.length}");

        if (mounted) {
          setState(() {
            _loadDataBloc.add(RefreshSuccessEvent());
          });
        }
      } else {
        _loadDataBloc.add(LoadEmptyEvent());
      }
    } catch (e) {
      LogUtil.toastException(e);

      if (mounted) {
        setState(() {
          _loadDataBloc.add(RefreshFailEvent());
        });
      }
    }
  }

  TextStyle _lightTextStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14,
    color: HexColor('#333333'),
  );

  TextStyle _greyTextStyle = TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 12,
    color: HexColor('#999999'),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: '取回持币',
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
                              Text('当前持币', style: _greyTextStyle),
                              SizedBox(
                                width: 16,
                              ),
                              Text('${widget?.rpMyLevelInfo?.currentHoldingStr ?? '0'} RP', style: _lightTextStyle),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Row(
                            children: <Widget>[
                              Text('当前量级${levelValueToLevelName(_currentLevel)}需持币', style: _greyTextStyle),
                              SizedBox(
                                width: 16,
                              ),
                              Text('${_currentLevelRule?.holdingStr ?? '0'} RP', style: _lightTextStyle),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Row(
                            children: <Widget>[
                              Text('取回持币', style: _lightTextStyle),
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
                                      _formKey.currentState.validate();
                                    },
                                    controller: _textEditingController,
                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    //inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                                    hint: S.of(context).please_enter_withdraw_amount,
                                    validator: (textStr) {
                                      var inputValue = Decimal.tryParse(textStr);

                                      if (inputValue == null) {
                                        return S.of(context).please_enter_correct_amount;
                                      }

                                      var holding =
                                          Decimal.tryParse(widget?.rpMyLevelInfo?.currentHoldingStr ?? '0') ?? 0;

                                      if (textStr.length == 0 || inputValue == Decimal.fromInt(0)) {
                                        return '请输入有效提币数量';
                                      }
                                      if (inputValue > holding) {
                                        return '大于当前持币';
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
                              '为保证当前量级不下降，请保持持币量大于${_currentLevelRule?.holdingStr ?? '0'}RP',
                              style: TextStyle(
                                color: HexColor('#333333'),
                                fontSize: 12,
                              ),
                            )
                          ],
                        )
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
        padding: const EdgeInsets.only(top: 60),
        child: Center(
          child: ClickOvalButton(
            '取回持币',
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

  bool _isLoading = false;
  int _toLevel;
  _showAlertView() {
    var inputValue = Decimal.tryParse(
          _textEditingController?.text,
        ) ??
        Decimal.fromInt(0);
    var holding = Decimal.tryParse(
          widget?.rpMyLevelInfo?.currentHoldingStr ?? '0',
        ) ??
        Decimal.fromInt(0);

    var remainHolding = holding - inputValue;

    var toLevelAfterWithdraw = _getLevelByHolding(remainHolding);
    _toLevel = toLevelAfterWithdraw;

    if (toLevelAfterWithdraw == _currentLevel) {
      _retrieveAction(false);
      return;
    }

    UiUtil.showAlertView(
      context,
      title: '重要提醒',
      actions: [
        ClickOvalButton(
          '取消',
          () {
            Navigator.pop(context, true);
            //_retrieveAction(true);
          },
          width: 115,
          height: 36,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          fontColor: DefaultColors.color333,
          btnColor: [Colors.transparent],
        ),
        // SizedBox(
        //   width: 10,
        // ),
        ClickOvalButton(
          '确认取回',
          () {
            _retrieveAction(true);
          },
          width: 115,
          height: 36,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          //btnColor: [HexColor('#FF0527'), HexColor('#FF4D4D')],
        ),
      ],
      content:
          '您要取回${inputValue}RP到钱包，当前持币量级${levelValueToLevelName(_currentLevel)}，您的量级将掉到量级${levelValueToLevelName(toLevelAfterWithdraw)}，请谨慎操作',
      isInputValue: false,
    );
  }

  _retrieveAction(bool isPop) async {
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
        toLevel: _toLevel,
      );
      Navigator.pop(context, true);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      LogUtil.toastException(e);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  _getLevelByHolding(Decimal value) {
    var level = 0;
    if (_staticDataList.isNotEmpty) {
      for (int i = 0; i < _staticDataList.length - 1; i++) {
        var levelRule = _staticDataList[i];
        var holding = Decimal.tryParse(
              levelRule.holdingStr ?? '0',
            ) ??
            Decimal.fromInt(0);
        if (value >= holding) {
          level = levelRule.level;
        }
        print('[_getLevelByHolding] value: $value holding $holding level $level holding ${levelRule.holding}');
      }
    }
    return level;
  }
}
