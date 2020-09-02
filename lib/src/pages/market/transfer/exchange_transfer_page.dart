import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/http/http_exception.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/exchange/bloc/bloc.dart';
import 'package:titan/src/components/exchange/exchange_component.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/pages/market/model/asset_history.dart';
import 'package:titan/src/pages/market/transfer/exchange_transfer_history_detail_page.dart';
import 'package:titan/src/pages/market/transfer/exchange_transfer_history_list_page.dart';
import 'package:titan/src/pages/market/transfer/exchange_transfer_success_page.dart';
import 'package:titan/src/pages/market/transfer/exchange_withdraw_confirm_page.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/DottedLine.dart';

import '../../../global.dart';
import '../model/asset_list.dart';

class ExchangeTransferPage extends StatefulWidget {
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

  @override
  void onCreated() {
    // TODO: implement onCreated
    super.onCreated();
    activatedWallet = WalletInheritedModel.of(context).activatedWallet;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
            '划转',
            style: TextStyle(
              color: Colors.black,
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
          '交易账户',
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
              '钱包',
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
                    Row(
                      children: <Widget>[
                        Text(
                          '从',
                          style: TextStyle(
                            color: HexColor('#FF777777'),
                          ),
                        ),
                        SizedBox(
                          width: 32,
                        ),
                        _transferTypeItem(_fromExchangeToWallet),
                      ],
                    ),
                    Divider(),
                    Row(
                      children: <Widget>[
                        Text(
                          '到',
                          style: TextStyle(
                            color: HexColor('#FF777777'),
                          ),
                        ),
                        SizedBox(
                          width: 32,
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
            '币种',
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
            height: 220,
            child: Column(
              children: <Widget>[
                _coinItem('HYN'),
                _divider(1.0),
                _coinItem('ETH'),
                _divider(1.0),
                _coinItem('USDT'),
                _divider(5.0),
                InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        '取消',
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
          color: HexColor('#FF228BA1'),
          shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Theme.of(context).primaryColor,
              ),
              borderRadius: BorderRadius.circular(4.0)),
          child: Text(
            '划转',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          onPressed: () async {
            FocusScope.of(context).requestFocus(FocusNode());
            if (_fromKey.currentState.validate()) {
              _transfer();
            }
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
                    ? HexColor('#FF0F95B0')
                    : HexColor('#FF777777')),
          ),
        ),
      ),
      onTap: () {
        setState(() {
          _selectedCoinType = type;
        });
        Navigator.of(context).pop();
      },
    );
  }

  _amount() {
    var _minTransferAmount = _fromExchangeToWallet
        ? ExchangeInheritedModel.of(context)
            .exchangeModel
            .activeAccount
            .assetList
            .getAsset(_selectedCoinType)
            .withdrawMin
        : ExchangeInheritedModel.of(context)
            .exchangeModel
            .activeAccount
            .assetList
            .getAsset(_selectedCoinType)
            .rechargeMin;
    var _withdrawFee = ExchangeInheritedModel.of(context)
        .exchangeModel
        .activeAccount
        .assetList
        .getAsset(_selectedCoinType)
        .withdrawFee;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.9),
          child: Text('数量'),
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
                    if (Decimal.parse(value) +
                            Decimal.parse(
                                _fromExchangeToWallet ? _withdrawFee : '0') >
                        Decimal.parse(_availableAmount())) {
                      return S.of(context).input_count_over_balance;
                    }

                    if (Decimal.parse(value) <
                        Decimal.parse(_minTransferAmount)) {
                      return '少于最小划转数';
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
                      hintText: '请输入划转数量',
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
                                  '全部',
                                  style: TextStyle(
                                      color: HexColor('#FF333333'),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                                onTap: () {
                                  _amountController.text = _availableAmount();
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
            Text(
              '最小划转数 $_minTransferAmount $_selectedCoinType',
              style: TextStyle(
                color: HexColor('#FFAAAAAA'),
                fontSize: 12,
              ),
            ),
            Spacer(),
            Text.rich(TextSpan(children: [
              TextSpan(
                text: _fromExchangeToWallet ? '账户余额 ' : '钱包余额 ',
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
        if (_fromExchangeToWallet)
          Text(
            '手续费 $_withdrawFee HYN',
            style: TextStyle(
              color: HexColor('#FFAAAAAA'),
              fontSize: 12,
            ),
          ),
      ],
    );
  }

  _transferHint() {
    var _withdrawFee = ExchangeInheritedModel.of(context)
        .exchangeModel
        .activeAccount
        .assetList
        .getAsset(_selectedCoinType)
        .withdrawFee;
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
                ? '从交易账户划转到钱包账户每笔需要收取 $_withdrawFee HYN手续费'
                : '从钱包账户划转到交易账户，需要等待整个网络的确认，大约需要15-30分钟。',
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
          .getAsset(_selectedCoinType)
          ?.exchangeAvailable;
      if (_exchangeAvailable != null) {
        return FormatUtil.truncateDecimalNum(
            Decimal.parse(_exchangeAvailable), 6);
      } else {
        return '0';
      }
    } else {
      return FormatUtil.coinBalanceHumanRead(WalletInheritedModel.of(
        context,
        aspect: WalletAspect.activatedWallet,
      ).getCoinVoBySymbol(_selectedCoinType));
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
    var coinVo = WalletInheritedModel.of(
      context,
      aspect: WalletAspect.activatedWallet,
    ).getCoinVoBySymbol(_selectedCoinType);

    var voStr = FluroConvertUtils.object2string(coinVo.toJson());

    Application.router.navigateTo(
      context,
      '${Routes.exchange_withdraw_confirm_page}?coinVo=$voStr&transferAmount=${_amountController.text}',
    );
  }
}
