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
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_promotion_rule_entity.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_util.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/style/titan_sytle.dart';
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

  RpLevelUpgradePage(this.rpMyLevelInfo, this.levelRule);

  @override
  State<StatefulWidget> createState() {
    return _RpLevelUpgradeState();
  }
}

class _RpLevelUpgradeState extends BaseState<RpLevelUpgradePage> {
  TextEditingController _textEditingController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  double minTotal = 0;
  double remainTotal = 0;
  final RPApi _rpApi = RPApi();

  LoadDataBloc _loadDataBloc = LoadDataBloc();

  @override
  void initState() {
    super.initState();
  }

  @override
  void onCreated() {
    // getNetworkData();

    //_textEditingController.text = widget.levelRule.holdingStr;

    setState(() {
      _loadDataBloc.add(RefreshSuccessEvent());
    });

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
      if (mounted) {
        setState(() {
          _loadDataBloc.add(RefreshSuccessEvent());
        });
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

  TextStyle _textStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14,
  );

  @override
  Widget build(BuildContext context) {
    var wallet = WalletInheritedModel.of(
      context,
      aspect: WalletAspect.activatedWallet,
    );
    var activatedWallet = wallet.activatedWallet;

    var walletName = activatedWallet?.wallet?.keystore?.name ?? "";

    var coinVo = wallet.getCoinVoBySymbol('RP');

    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: '升级量级',
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
                              Text('提升到 ${levelValueToLevelName(widget?.levelRule?.level)} 持币量级',
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
                              Text('${widget?.levelRule?.burnStr??'0'} RP', style: _textStyle),
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
                                  '${S.of(context).mortgage_wallet_balance(walletName, FormatUtil.coinBalanceHumanReadFormat(coinVo))}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12,
                                    color: HexColor('#999999'),
                                  )),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text('当前持币 ${widget?.rpMyLevelInfo?.currentHoldingStr ?? '0'} RP ',
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
                                      _formKey.currentState.validate();
                                    },
                                    controller: _textEditingController,
                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    //inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                                    hint: '至少${widget?.levelRule?.holdingStr??'0'} RP',
                                    validator: (textStr) {
                                      if (textStr.length == 0) {
                                        return '请输入数量';
                                      }

                                      var inputValue = Decimal.tryParse(textStr);
                                      if (inputValue == null) {
                                        return S.of(context).please_enter_correct_amount;
                                      }

                                      var holdValue =
                                          Decimal.tryParse(widget?.levelRule?.holdingStr??'0') ?? Decimal.fromInt(0);
                                      if (holdValue > inputValue) {
                                        return '至少${widget?.levelRule?.holdingStr??'0'} RP';
                                      }

                                      var balanceValue = Decimal.tryParse(FormatUtil.coinBalanceHumanRead(coinVo)) ??
                                          Decimal.fromInt(0);
                                      print("inputValue:$inputValue, balanceValue:$balanceValue");

                                      if (inputValue > balanceValue) {
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
                        )
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
                      '提示：因你还没有推荐人，系统将为你随机设定一个量级4以上的账户地址为推荐人',
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
          ),
        ),
      ),
    );
  }

  _upgradeAction() async {
    FocusScope.of(context).requestFocus(FocusNode());

    if (!_formKey.currentState.validate()) {
      return;
    }

    if (widget.levelRule == null) {
      Fluttertoast.showToast(
        msg: '请先选择想要升级的量级！',
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    var inputText = _textEditingController?.text ?? '';
    if (inputText.isEmpty) {
      return;
    }

    // todo: 计算 holding + burning > balance;
    var holdValue = Decimal.tryParse(inputText) ?? Decimal.fromInt(0);
    var burnValue = Decimal.tryParse(widget?.levelRule?.burnStr??'0') ?? Decimal.fromInt(0);
    var totalValue = (holdValue + burnValue);

    var wallet = WalletInheritedModel.of(
      context,
      aspect: WalletAspect.activatedWallet,
    );

    var activeWallet = wallet.activatedWallet;

    var coinVo = wallet.getCoinVoBySymbol('RP');
    var balanceValue = Decimal.tryParse(FormatUtil.coinBalanceHumanRead(coinVo)) ?? Decimal.fromInt(0);

    if (totalValue > balanceValue) {
      Fluttertoast.showToast(
        msg: '钱包余额不足以升级到当前选中量级！',
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    var password = await UiUtil.showWalletPasswordDialogV2(context, activeWallet.wallet);
    if (password == null) {
      return;
    }

    var burningAmount = ConvertTokenUnit.strToBigInt(widget.levelRule.burnStr);
    var depositAmount = ConvertTokenUnit.strToBigInt(inputText);

    Future.delayed(Duration(milliseconds: 111)).then((_) async {
      try {
        await _rpApi.postRpDepositAndBurn(
          level: widget.levelRule.level,
          depositAmount: depositAmount,
          burningAmount: burningAmount,
          activeWallet: activeWallet,
          password: password,
        );

        Fluttertoast.showToast(
          msg: '升级请求已发送成功！',
          gravity: ToastGravity.CENTER,
        );
        Navigator.pop(context, true);
      } catch (e) {
        LogUtil.toastException(e);
      }
    });
  }
}
