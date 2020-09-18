import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/http/http_exception.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/exchange/exchange_component.dart';
import 'package:titan/src/components/quotes/model.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/pages/market/transfer/exchange_transfer_history_list_page.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/DottedLine.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/plugins/wallet/convert.dart';

class ExchangeTransferPage extends StatefulWidget {
  final String coinType;

  ExchangeTransferPage(this.coinType);

  @override
  State<StatefulWidget> createState() {
    return _ExchangeTransferPageState();
  }
}

class _ExchangeTransferPageState extends BaseState<ExchangeTransferPage> {
  String _selectedCoinType = 'HYN';
  TextEditingController _amountController = TextEditingController();

  final _fromKey = GlobalKey<FormState>();
  bool _fromExchangeToWallet = false;
  ExchangeApi _exchangeApi = ExchangeApi();
  WalletVo activatedWallet;

  String _gasFeeStr = "0";

  Future<double> gasFeeFunc(String symbol) async {
    var gasPriceRecommend =
        QuotesInheritedModel.of(context, aspect: QuotesAspect.gasPrice)
            .gasPriceRecommend;
    var gasPrice = gasPriceRecommend.fast;

    var totalGasLimit = SettingInheritedModel.ofConfig(context)
        .systemConfigEntity
        .erc20TransferGasLimit;
    totalGasLimit = 40000;
    var gasEstimate = ConvertTokenUnit.weiToEther(
        weiBigInt: BigInt.parse(
            (gasPrice * Decimal.fromInt(totalGasLimit)).toStringAsFixed(0)));

    var quotesSign = SupportedQuoteSigns.defaultQuotesSign;
    var ethQuotePrice = QuotesInheritedModel.of(context)
            .selectedQuoteVoAndSign(symbol: 'ETH', quotesSign: quotesSign)
            ?.quoteVo
            ?.price ??
        0; //

    var gasPriceEstimate =
        gasEstimate * Decimal.parse(ethQuotePrice.toString());
    var fee = gasPriceEstimate.toDouble();
    print("[object] baseSymbol:$symbol, u_fee:$fee");

    // 使用的hyn ---fee
    if (symbol == "HYN") {
      double calculateBase = 0.000038;
      calculateBase = 1.0;
      var hynQuotePrice = QuotesInheritedModel.of(context)
              .selectedQuoteVoAndSign(symbol: symbol, quotesSign: quotesSign)
              ?.quoteVo
              ?.price ??
          0;
      var uAmount = calculateBase * fee;
      fee = uAmount / hynQuotePrice;
      fee = double.parse(fee.toStringAsFixed(2));
      print("[object] baseSymbol:$symbol, hyn_fee:$fee");
    }

    //fee = 0;
    if (fee == 0) {
      fee = await _getDefaultGasFee(symbol);
    } else {
      _setDefaultGasFee(fee, symbol);
    }
    print("[object] baseSymbol:$symbol, fee:$fee");

    return fee;
  }

  Future<double> _getDefaultGasFee(String symbol) async {
    double fee = 0;
    var saveFee =
        await AppCache.getValue(PrefsKey.SHARED_PREF_GAS_FEE_KEY + symbol);
    if (saveFee == null || !(saveFee is double)) {
      fee = symbol == "HYN" ? 5.0 : 4.0;
    } else {
      fee = saveFee as double;
    }

    return fee;
  }

  _setDefaultGasFee(double fee, String symbol) async {
    await AppCache.saveValue(PrefsKey.SHARED_PREF_GAS_FEE_KEY + symbol, fee);
  }

//  @override
//  void onCreated() {
//    // TODO: implement onCreated
//    super.onCreated();
//  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    activatedWallet = WalletInheritedModel.of(context).activatedWallet;
    await _gasFeeFullStrFunc();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedCoinType = widget.coinType ?? 'HYN';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                _appBar(),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      // hide keyboard when touch other widgets
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              child: ListView(
                                children: <Widget>[
                                  _transferTypeSelection(),
                                  _coinTypeSelection(),
                                  _amount(),
                                  _transferHint(),
                                ],
                              ),
                            ),
                            _confirm()
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        Expanded(
          child: Text(
            S.of(context).exchange_transfer,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ExchangeTransferHistoryListPage(
                          _selectedCoinType,
                        )));
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Image.asset(
              'res/drawable/ic_transfer_history.png',
              width: 20,
              height: 20,
            ),
          ),
        )
      ],
    );
  }

  _transferTypeItem(bool _isExchange) {
    if (_isExchange) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
        child: Text(
          S.of(context).exchange_account,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
        child: Row(
          children: <Widget>[
            Text(
              S.of(context).wallet,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              ' (${activatedWallet?.wallet?.keystore?.name ?? ''})',
              style: TextStyle(
                fontSize: 14,
                color: HexColor('#FF999999'),
              ),
            )
          ],
        ),
      );
    }
  }

  _transferTypeSelectDecoration() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Center(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: HexColor('#FF0F95B0'),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            Container(
              height: 40,
              child: DottedLine(color: Colors.grey),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: HexColor('#FFCB5454'),
                borderRadius: BorderRadius.circular(10.0),
              ),
            )
          ],
        ),
      ),
    );
  }

  _transferTypeSelection() {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        elevation: 3.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              _transferTypeSelectDecoration(),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 50,
                            child: Text(
                              S.of(context).exchange_from,
                              style: TextStyle(
                                color: HexColor('#FF777777'),
                              ),
                            ),
                          ),
                          _transferTypeItem(_fromExchangeToWallet),
                        ],
                      ),
                    ),
                    Divider(),
                    Row(
                      children: <Widget>[
                        Container(
                          width: 50,
                          child: Text(
                            S.of(context).exchange_to,
                            style: TextStyle(
                              color: HexColor('#FF777777'),
                            ),
                          ),
                        ),
                        _transferTypeItem(!_fromExchangeToWallet),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 8,
              ),
              InkWell(
                child: Image.asset(
                  'res/drawable/ic_btn_transfer.png',
                  width: 50,
                  height: 50,
                  color: Theme.of(context).primaryColor,
                ),
                onTap: () {
                  setState(() {
                    _fromExchangeToWallet = !_fromExchangeToWallet;
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  _coinTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            S.of(context).coin_type,
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        InkWell(
          child: Row(
            children: <Widget>[
              Text(
                _selectedCoinType,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                  color: HexColor('#FF999999'),
                ),
              )
            ],
          ),
          onTap: () {
            _showCoinSelectDialog();
          },
        ),
        Divider()
      ],
    );
  }

  _showCoinSelectDialog() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.0),
            topRight: Radius.circular(15.0),
          ),
        ),
        builder: (BuildContext context) {
          return Container(
            height: 170,
            child: Column(
              children: <Widget>[
                _coinItem('HYN'),
                _divider(1.0),
//                _coinItem('ETH'),
//                _divider(1.0),
                _coinItem('USDT'),
                _divider(5.0),
                InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        S.of(context).cancel,
                        style: TextStyle(
                          color: HexColor('#FF777777'),
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          );
        });
  }

  _confirm() {
    return Container(
      width: double.infinity,
      height: 50,
      child: RaisedButton(
          textColor: Colors.white,
          color: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Theme.of(context).primaryColor,
              ),
              borderRadius: BorderRadius.circular(4.0)),
          child: Text(
            _fromExchangeToWallet
                ? S.of(context).exchange_withdraw
                : S.of(context).exchange_deposit,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          onPressed: () async {
            debounce(() {
              FocusScope.of(context).requestFocus(FocusNode());

              // todo: test_jison_0918
              if (_fromKey.currentState.validate()) {
                _transfer();
              }
            }, 200)();
          }),
    );
  }

  _divider(double height) {
    return Container(
      width: double.infinity,
      height: height,
      color: HexColor('#FFEEEEEE'),
    );
  }

  _coinItem(String type) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            type,
            style: TextStyle(
                color: _selectedCoinType == type
                    ? Theme.of(context).primaryColor
                    : HexColor('#FF777777')),
          ),
        ),
      ),
      onTap: () {
        setState(() {
          _selectedCoinType = type;
          _gasFeeFullStrFunc();
        });
        Navigator.of(context).pop();
      },
    );
  }

  _gasFeeFullStrFunc() async {
    var gasFee = await gasFeeFunc(_selectedCoinType);
    _gasFeeStr = gasFee.toStringAsFixed(2);
    setState(() {});
  }

  _amount() {
    var _minTransferText = _fromExchangeToWallet
        ? S.of(context).exchange_withdraw_min
        : S.of(context).exchange_deposit_min;
    var _amountInputHint = _fromExchangeToWallet
        ? S.of(context).exchange_deposit_input_hint
        : S.of(context).exchange_withdraw_input_hint;
    var _minTransferAmount = _fromExchangeToWallet
        ? ExchangeInheritedModel.of(context)
            .exchangeModel
            .activeAccount
            .assetList
            ?.getAsset(_selectedCoinType)
            ?.withdrawMin
        : ExchangeInheritedModel.of(context)
            .exchangeModel
            .activeAccount
            .assetList
            ?.getAsset(_selectedCoinType)
            ?.rechargeMin;
    var _withdrawFee = ExchangeInheritedModel.of(context)
        .exchangeModel
        .activeAccount
        .assetList
        ?.getAsset(_selectedCoinType)
        ?.withdrawFee;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              Text(S.of(context).exchange_transfer_amount),
              SizedBox(
                width: 4.0,
              ),
              Text(
                '($_minTransferText $_minTransferAmount $_selectedCoinType)',
                style: TextStyle(
                  color: HexColor('#FFAAAAAA'),
                  fontSize: 11,
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Form(
                key: _fromKey,
                child: TextFormField(
                  controller: _amountController,
                  validator: (value) {
                    value = value.trim();
                    if (value == '0') {
                      return S.of(context).input_corrent_count_hint;
                    }
                    if (!RegExp(r"\d+(\.\d+)?$").hasMatch(value)) {
                      return S.of(context).input_corrent_count_hint;
                    }

                    if (Decimal.parse(value) >
                        Decimal.parse(_availableAmount())) {
                      return S.of(context).input_count_over_balance;
                    }

                    if (Decimal.parse(value) <
                        Decimal.parse(_minTransferAmount)) {
                      return _fromExchangeToWallet
                          ? S.of(context).exchange_withdraw_less_than_min
                          : S.of(context).exchange_deposit_less_than_min;
                    }

                    return null;
                  },
                  onChanged: (data) {
                    _fromKey.currentState.validate();
                  },
                  decoration: InputDecoration(
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(
                        color: HexColor('#FFD7D7D7'),
                      )),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                        color: HexColor('#FFD7D7D7'),
                      )),
                      hintText: _amountInputHint,
                      hintStyle: TextStyle(
                        color: HexColor('#FF999999'),
                        fontSize: 12,
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Container(
                          width: 100,
                          child: Row(
                            children: <Widget>[
                              Spacer(),
                              Text(
                                _selectedCoinType,
                                style: TextStyle(
                                  color: HexColor('#FF777777'),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '  |  ',
                                style: TextStyle(color: HexColor('#FFD8D8D8')),
                              ),
                              InkWell(
                                child: Text(
                                  S.of(context).all,
                                  style: TextStyle(
                                      color: HexColor('#FF333333'),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                                onTap: () {
                                  if (!_fromExchangeToWallet) {
                                    _amountController.text = _availableAmount();
                                  } else {
                                    var _availableAmountValue =
                                        Decimal.parse(_availableAmount());
                                    var _withdrawFeeValue =
                                        Decimal.parse(_gasFeeStr);
                                    var sub = _availableAmountValue -
                                        _withdrawFeeValue;
                                    _amountController.text =
                                        '${(sub.toDouble() < 0) ? "" : sub}';
                                  }

                                  _amountController.selection =
                                      TextSelection.fromPosition(TextPosition(
                                    affinity: TextAffinity.downstream,
                                    offset: _amountController.text.length,
                                  ));
                                  _fromKey.currentState.validate();
                                  setState(() {});
                                },
                              )
                            ],
                          ),
                        ),
                      )),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 16,
        ),
        Row(
          children: <Widget>[
            if (_fromExchangeToWallet)
              Text(
                '${S.of(context).exchange_fee} $_gasFeeStr $_selectedCoinType',
                style: TextStyle(
                  color: HexColor('#FFAAAAAA'),
                  fontSize: 12,
                ),
              ),
            Spacer(),
            Text.rich(TextSpan(children: [
              TextSpan(
                text:
                    '${_fromExchangeToWallet ? S.of(context).exchange_account_balance : S.of(context).exchange_wallet_balance} ',
                style: TextStyle(
                  color: HexColor('#FFAAAAAA'),
                  fontSize: 12,
                ),
              ),
              TextSpan(
                text: _availableAmount(),
                style: TextStyle(
                  color: HexColor('#FF333333'),
                  fontSize: 12,
                ),
              ),
              TextSpan(
                text: ' $_selectedCoinType',
                style: TextStyle(
                  color: HexColor('#FFAAAAAA'),
                  fontSize: 12,
                ),
              ),
            ])),
          ],
        ),
        SizedBox(
          height: 16,
        ),
      ],
    );
  }

  _transferHint() {
    var _withdrawFee = ExchangeInheritedModel.of(context)
        .exchangeModel
        .activeAccount
        .assetList
        ?.getAsset(_selectedCoinType)
        ?.withdrawFee;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: HexColor('#FFF2F2F2'),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _fromExchangeToWallet
                ? S.of(context).exchange_transfer_hint_account_to_wallet(
                      _gasFeeStr,
                      _selectedCoinType,
                    )
                : S.of(context).exchange_transfer_hint_wallet_to_exchange,
            style: TextStyle(
              color: HexColor('#FF777777'),
              fontSize: 14,
              height: 1.8,
            ),
          ),
        ),
      ),
    );
  }

  _availableAmount() {
    if (_fromExchangeToWallet) {
      var _exchangeAvailable = ExchangeInheritedModel.of(context)
          .exchangeModel
          .activeAccount
          .assetList
          ?.getAsset(_selectedCoinType)
          ?.exchangeAvailable;
      if (_exchangeAvailable != null) {
        return FormatUtil.truncateDecimalNum(
            Decimal.parse(_exchangeAvailable), 6);
      } else {
        return '0';
      }
    } else {
      return FormatUtil.coinBalanceByDecimal(
        WalletInheritedModel.of(
          context,
          aspect: WalletAspect.activatedWallet,
        ).getCoinVoBySymbol(_selectedCoinType),
        6,
      );
    }
  }

  _transfer() async {
    try {
      if (_fromExchangeToWallet) {
        _withdraw();
      } else {
        var ret = await _exchangeApi.getAddress(_selectedCoinType);
        var exchangeAddress = ret['address'];
        _deposit(exchangeAddress);
      }
    } catch (e) {
      if (e is HttpResponseCodeNotSuccess) {
        Fluttertoast.showToast(msg: e.message);
      }
    }
  }

  _deposit(String exchangeAddress) async {
    if (context == null) return;

    var coinVo = WalletInheritedModel.of(
      context,
      aspect: WalletAspect.activatedWallet,
    ).getCoinVoBySymbol(_selectedCoinType);

    var voStr = FluroConvertUtils.object2string(coinVo.toJson());
    Application.router.navigateTo(
      context,
      '${Routes.exchange_deposit_confirm_page}?coinVo=$voStr&transferAmount=${_amountController.text}&exchangeAddress=$exchangeAddress',
    );
  }

  _withdraw() async {
    var withdrawFeeStr = ExchangeInheritedModel.of(context)
        .exchangeModel
        .activeAccount
        .assetList
        .getAsset(_selectedCoinType)
        .withdrawFee;

    var coinVo = WalletInheritedModel.of(
      context,
      aspect: WalletAspect.activatedWallet,
    ).getCoinVoBySymbol(_selectedCoinType);
    var coinVoStr = FluroConvertUtils.object2string(coinVo.toJson());

    var inputValue = Decimal.parse(_amountController?.text ?? "0");
    print(
        "[object] _gasFeeStf:$_gasFeeStr, is string :${_gasFeeStr is String}");
    var gasFeeValue = Decimal.parse(_gasFeeStr);
    var availableValue = Decimal.parse(_availableAmount());
    var totalValue = inputValue + gasFeeValue;
    var balanceValue = availableValue - gasFeeValue;
    var transferAmountStr =
        totalValue <= availableValue ? _amountController.text : '$balanceValue';

    var total = Decimal.parse(transferAmountStr) + gasFeeValue;
    var totalStr = total.toString();

    print(
        "[object] transferAmountStr:$transferAmountStr, gasFeeStr:$_gasFeeStr, withdrawFeeStr:$withdrawFeeStr, totalStr:$totalStr");

    Application.router.navigateTo(
      context,
      '${Routes.exchange_withdraw_confirm_page}?coinVo=$coinVoStr&transferAmount=$transferAmountStr&gasFee=$_gasFeeStr&total=$totalStr',
    );
  }
}
