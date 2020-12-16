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
import 'package:titan/src/components/wallet/vo/coin_vo.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/red_pocket/api/rp_api.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_util.dart';
import 'package:titan/src/pages/red_pocket/rp_level_upgrade_page.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/round_border_textfield.dart';
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

  RpPromotionRuleEntity _promotionRuleEntity;
  RpMyLevelInfo _myLevelInfo;

  int get _currentLevel => _myLevelInfo?.currentLevel ?? 0;

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

  CoinVo _coinVo;
  WalletVo _activatedWallet;
  String get _walletName => _activatedWallet?.wallet?.keystore?.name ?? "";
  String get _address => _activatedWallet?.wallet?.getAtlasAccount()?.address;

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
    var holding = Decimal.tryParse(
          _myLevelInfo?.currentHoldingStr ?? '0',
        ) ??
        Decimal.zero;

    var remainHolding = holding - _inputValue;
    var needHolding = Decimal.tryParse(
          _currentLevelRule?.holdingStr ?? '0',
        ) ??
        Decimal.zero;
    var level = 0;

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

        //print("firstObj:${firstObj?.level??0}");

        level = firstObj?.level ?? 0;
      } else {
        level = 0;
      }
    }
    //print('[_getLevelByHolding] inputValue: $_inputValue， level：$level');

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
                    padding: const EdgeInsets.only(
                      left: 16,
                    ),
                    color: Colors.white,
                    child: Column(
                      children: <Widget>[
                        rpRowText(
                          title: '当前量级${levelValueToLevelName(_currentLevel)}需持币',
                          amount: '${_currentLevelRule?.holdingStr ?? '0'} RP',
                          width: 110,
                        ),
                        rpRowText(
                          title: '当前持币',
                          amount: '${_myLevelInfo?.currentHoldingStr ?? '0'} RP',
                          width: 110,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Row(
                            children: <Widget>[
                              Text(
                                '取回持币',
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
                                    hint: S.of(context).please_enter_withdraw_amount,
                                    validator: (textStr) {
                                      var inputValue = Decimal.tryParse(textStr);

                                      if (inputValue == null) {
                                        return S.of(context).please_enter_correct_amount;
                                      }

                                      var holding = Decimal.tryParse(_myLevelInfo?.currentHoldingStr ?? '0') ?? 0;

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
                              StreamBuilder<Object>(
                                  stream: _inputController.stream,
                                  builder: (context, snapshot) {
                                    bool isShowDown = (_toLevel < _currentLevel &&
                                        _currentHoldValue > _inputValue &&
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
                                                  '量级',
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

  _showAlertView() {
    if (_toLevel == _currentLevel) {
      _withdrawAction(false);
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
          },
          width: 115,
          height: 36,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          fontColor: DefaultColors.color333,
          btnColor: [Colors.transparent],
        ),
        ClickOvalButton(
          '确认取回',
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
          '您要取回${_inputValue}RP到钱包，当前持币量级${levelValueToLevelName(_currentLevel)}，您的量级将掉到量级${levelValueToLevelName(_toLevel)}，请谨慎操作',
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
    try {
      if (context != null) {
        BlocProvider.of<RedPocketBloc>(context).add(UpdateMyLevelInfoEntityEvent());
      }

      if (context != null) {
        BlocProvider.of<WalletCmpBloc>(context).add(UpdateActivatedWalletBalanceEvent());
      }

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
      if (mounted) {
        LogUtil.toastException(e);

        setState(() {
          _loadDataBloc.add(RefreshFailEvent());
        });
      }
    }
  }
}
