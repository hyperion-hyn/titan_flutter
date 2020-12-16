import 'dart:async';
import 'dart:math' as math;

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
import 'package:titan/src/pages/red_pocket/api/rp_api.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_util.dart';
import 'package:titan/src/pages/red_pocket/rp_level_upgrade_page.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/round_border_textfield.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';

import 'entity/rp_my_level_info.dart';

class RpLevelAddStakingPage extends StatefulWidget {
  RpLevelAddStakingPage();

  @override
  State<StatefulWidget> createState() {
    return _RpLevelAddStakingState();
  }
}

class _RpLevelAddStakingState extends BaseState<RpLevelAddStakingPage> {
  TextEditingController _textEditingController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final RPApi _rpApi = RPApi();
  final StreamController<String> _inputController = StreamController.broadcast();

  double minTotal = 0;
  double remainTotal = 0;

  LoadDataBloc _loadDataBloc = LoadDataBloc();

  RpMyLevelInfo _myLevelInfo;
  CoinVo _coinVo;
  WalletVo _activatedWallet;
  String get _walletName => _activatedWallet?.wallet?.keystore?.name ?? "";

  TextStyle _lightTextStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14,
  );


  Decimal get _balanceValue => Decimal.tryParse(FormatUtil.coinBalanceHumanRead(_coinVo)) ?? Decimal.zero;

  Decimal get _inputValue {
    var zeroValue = Decimal.zero;
    var inputValue = Decimal.tryParse(_textEditingController?.text ?? '0') ?? zeroValue;
    return inputValue;
  }

  Decimal get _preTotaHoldValue {
    var zeroValue = Decimal.zero;

    var currentHoldValue = Decimal.tryParse(_myLevelInfo?.currentHoldingStr ?? '0') ?? zeroValue;
    var totalHoldValue = (_inputValue + currentHoldValue);

     return totalHoldValue > zeroValue ? totalHoldValue : currentHoldValue;
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

  Future getNetworkData() async {
    if (context != null) {
      BlocProvider.of<RedPocketBloc>(context).add(UpdateMyLevelInfoEntityEvent());
    }

    if (context != null) {
      BlocProvider.of<WalletCmpBloc>(context)
          .add(UpdateActivatedWalletBalanceEvent());
    }

    if (mounted) {
      _loadDataBloc.add(RefreshSuccessEvent());
    }
  }

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
                        rpRowText(title: '当前量级', amount:levelValueToLevelName(_myLevelInfo?.currentLevel ?? 0),),
                        rpRowText(title: '当前持币', amount:'${_myLevelInfo?.currentHoldingStr ?? '0'} RP',),

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
                                    hint: '请输入增加数量',
                                    validator: (textStr) {
                                      if (textStr.length == 0) {
                                        return '请输入增加数量';
                                      }

                                      var inputValue = Decimal.tryParse(textStr ?? '0');
                                      if (inputValue == null || inputValue <= Decimal.zero) {
                                        return S.of(context).please_enter_correct_amount;
                                      }

                                      var balanceValue = Decimal.tryParse(FormatUtil.coinBalanceHumanRead(_coinVo)) ??
                                          Decimal.fromInt(0);
                                      print("inputValue:$inputValue, balanceValue:$balanceValue");

                                      if (inputValue > balanceValue) {
                                        return '输入数量超过了钱包余额';
                                      }
                                    },
                                  ),
                                ),
                              ),
                              StreamBuilder<Object>(
                                  stream: _inputController.stream,
                                  builder: (context, snapshot) {
                                    bool isShowUp = (_balanceValue > _inputValue && _inputValue > Decimal.zero);
                                    return
                                      isShowUp? Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 16,
                                            right: 16,
                                          ),
                                          child: Transform.rotate(
                                            angle:math.pi ,
                                            child: Image.asset(
                                              'res/drawable/ic_rp_level_down.png',
                                              width: 15,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            right: 4,
                                          ),
                                          child: Text(
                                            '预计总持币',
                                            style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 10,
                                              color: HexColor('#999999'),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '$_preTotaHoldValue RP',
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
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 6,),
                                child: Image.asset(
                                  "res/drawable/add_position_image_detail.png",
                                  width: 12,
                                  height: 12,
                                  color: HexColor('#999999'),
                                ),
                              ),
                              Text(
                                '适当增加持币可以防止因',
                                style: TextStyle(
                                  color: HexColor('#999999'),
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                ' Y',
                                style: TextStyle(color: HexColor('#333333'), fontSize: 12, fontWeight: FontWeight.w600),
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
            isLoading: _isLoading,
          ),
        ),
      ),
    );
  }

  bool _isLoading = false;

  _addAction() async {
    FocusScope.of(context).requestFocus(FocusNode());

    if (!_formKey.currentState.validate()) {
      return;
    }

    if ((_myLevelInfo?.currentLevel ?? 0) == 0) {
      Fluttertoast.showToast(
        msg: '请先提升量级！',
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    var inputText = _textEditingController?.text ?? '';

    if (inputText.isEmpty) {
      return;
    }

    var password = await UiUtil.showWalletPasswordDialogV2(context, _activatedWallet.wallet);
    if (password == null) {
      return;
    }

    var burningAmount = ConvertTokenUnit.strToBigInt('0');
    var depositAmount = ConvertTokenUnit.strToBigInt(inputText);

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    Future.delayed(Duration(milliseconds: 111)).then((_) async {
      try {
        await _rpApi.postRpDepositAndBurn(
          from: _myLevelInfo?.currentLevel ?? 0,
          to: _myLevelInfo?.currentLevel ?? 0,
          depositAmount: depositAmount,
          burningAmount: burningAmount,
          activeWallet: _activatedWallet,
          password: password,
        );

        Fluttertoast.showToast(
          msg: '增加持币请求已广播！',
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
          LogUtil.toastException(e);

          setState(() {
            _isLoading = false;
          });
        }
      }
    });
  }
}
