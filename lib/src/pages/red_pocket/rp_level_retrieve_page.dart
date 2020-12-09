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
  List<LevelRule> get _staticDataList => (_promotionRuleEntity?.static ?? []).reversed.toList();
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
                              Text('当前持币', style: _greyTextStyle),
                              SizedBox(
                                width: 16,
                              ),
                              Text('${widget?.rpMyLevelInfo?.currentHoldingStr??'0'} RP', style: _lightTextStyle),
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
                              Text('${_currentLevelRule?.holdingStr} RP', style: _lightTextStyle),
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
                                      if (textStr.length == 0) {
                                        return '请输入提币数量';
                                      }

                                      var inputValue = Decimal.tryParse(textStr);
                                      if (inputValue == null) {
                                        return S.of(context).please_enter_correct_amount;
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
                              '为保证当前量级不下降，请保持持币量大于${_currentLevelRule?.holdingStr}RP',
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
    UiUtil.showAlertView(
      context,
      title: '重要提醒',
      actions: [
        ClickOvalButton(
          '取回',
          _retrieveAction,
          width: 115,
          height: 36,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          fontColor: DefaultColors.color333,
          btnColor: [Colors.transparent],
        ),
        SizedBox(
          width: 20,
        ),
        ClickOvalButton(
          '再想想',
          () {
            Navigator.pop(context, true);
          },
          width: 115,
          height: 36,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          btnColor: [HexColor('#FF0527'), HexColor('#FF4D4D')],
        ),
      ],
      content:
          '您要取回${_textEditingController?.text ?? '0'}RP到钱包，当前持币量级${levelValueToLevelName(_currentLevel)}，您的量级将掉到量级${levelValueToLevelName(_currentLevel - 1)}，请谨慎操作',
      isInputValue: false,
    );
  }

  _retrieveAction() async {
    Navigator.pop(context, true);

    
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

    var withdrawAmount = ConvertTokenUnit.strToBigInt(inputText);
    try {
      await _rpApi.postRpWithdraw(withdrawAmount: withdrawAmount, activeWallet: _activeWallet, password: password);
      Navigator.pop(context, true);
    } catch (e) {
      LogUtil.toastException(e);
    }
  }
}
