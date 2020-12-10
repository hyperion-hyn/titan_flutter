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
import 'package:titan/src/pages/red_pocket/entity/rp_promotion_rule_entity.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_util.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/round_border_textfield.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';

import 'entity/rp_my_level_info.dart';

class RpLevelAddStakingPage extends StatefulWidget {
  final RpMyLevelInfo rpMyLevelInfo;

  RpLevelAddStakingPage(this.rpMyLevelInfo);

  @override
  State<StatefulWidget> createState() {
    return _RpLevelAddStakingState();
  }
}

class _RpLevelAddStakingState extends BaseState<RpLevelAddStakingPage> {
  TextEditingController _textEditingController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final RPApi _rpApi = RPApi();

  double minTotal = 0;
  double remainTotal = 0;

  LoadDataBloc _loadDataBloc = LoadDataBloc();

  @override
  void initState() {
    super.initState();
  }

  @override
  void onCreated() {
    // getNetworkData();

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

  TextStyle _lightTextStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: '增加持币',
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
                          padding: const EdgeInsets.only(top: 60),
                          child: Row(
                            children: <Widget>[
                              Text('当前量级', style: _lightTextStyle),
                              SizedBox(
                                width: 16,
                              ),
                              Text('${levelValueToLevelName(widget?.rpMyLevelInfo?.currentLevel??0)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: HexColor('#999999'),
                                  )),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text('转入持币', style: _lightTextStyle),
                              SizedBox(
                                width: 5,
                              ),
                              Text('当前持币 ${widget?.rpMyLevelInfo?.currentHoldingStr??'0'} RP',
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
                                    hint: '请输入增加数量',
                                    validator: (textStr) {
                                      if (textStr.length == 0) {
                                        return '请输入增加数量';
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
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            children: [
                              Text(
                                '适当增加持币可以防止因',
                                style: TextStyle(
                                  color: HexColor('#999999'),
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                ' Y',
                                style: TextStyle(
                                  color: HexColor('#333333'),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600
                                ),
                              ),
                              Text(
                                '（发行量）',
                                style: TextStyle(
                                  color: HexColor('#999999'),
                                  fontSize: 8,
                                ),
                              ),
                              Text(
                                '增加而掉级',
                                style: TextStyle(
                                  color: HexColor('#999999'),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
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
        padding: const EdgeInsets.only(top: 100),
        child: Center(
          child: ClickOvalButton(
            S.of(context).confirm,
            _addAction,
            height: 42,
            width: MediaQuery.of(context).size.width - 37 * 2,
            fontSize: 18,
            btnColor: [HexColor('#FF0527'), HexColor('#FF4D4D')],
          ),
        ),
      ),
    );
  }

  _addAction() async {
    FocusScope.of(context).requestFocus(FocusNode());

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

    var burningAmount = ConvertTokenUnit.strToBigInt('0');
    var depositAmount = ConvertTokenUnit.strToBigInt(inputText);

    Future.delayed(Duration(milliseconds: 111)).then((_) async {
      try {
        await _rpApi.postRpDepositAndBurn(
          level: widget.rpMyLevelInfo.currentLevel,
          depositAmount: depositAmount,
          burningAmount: burningAmount,
          activeWallet: _activeWallet,
          password: password,
        );
        Navigator.pop(context, true);
      } catch (e) {
        LogUtil.toastException(e);
      }
    });
  }
}
