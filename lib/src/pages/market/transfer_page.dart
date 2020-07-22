import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/exchange/exchange_component.dart';
import 'package:titan/src/utils/format_util.dart';

import 'model/asset_list.dart';

class TransferPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TransferPageState();
  }
}

class _TransferPageState extends BaseState<TransferPage> {
  String _selectedCoinType = 'HYN';
  TextEditingController _amountController = TextEditingController();
  final _fromKey = GlobalKey<FormState>();
  AssetList _assetList;
  TransferType _transferType = TransferType.AccountToExchange;

  @override
  void onCreated() {
    // TODO: implement onCreated
    super.onCreated();
    _assetList = ExchangeInheritedModel.of(context)
        .exchangeModel
        .activeAccount
        .assetList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          '划转',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _transferTypeSelection(),
                _coinTypeSelection(),
                _amount(),
                _transferHint(),
                _confirm()
              ],
            ),
          ),
        ),
      ),
    );
  }

  _transferTypeSelection() {
    List<DropdownMenuItem> transferItemList = List();
    transferItemList.add(
      DropdownMenuItem(
        value: 'account',
        child: Text('资金账户'),
      ),
    );
    transferItemList.add(
      DropdownMenuItem(
        value: 'exchange',
        child: Text('交易账户'),
      ),
    );

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 3.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 8.0,
        ),
        child: Row(
          children: <Widget>[
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
                      DropdownButtonHideUnderline(
                        child: DropdownButton(
                          onChanged: (value) {
                            setState(() {});
                          },
                          value: 'account',
                          items: transferItemList,
                        ),
                      ),
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
                      DropdownButtonHideUnderline(
                        child: DropdownButton(
                          onChanged: (value) {
                            setState(() {});
                          },
                          value: 'account',
                          items: transferItemList,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Image.asset(
                'res/drawable/market_exchange_btn_icon.png',
                width: 25,
                height: 25,
              ),
              onPressed: () {},
            )
          ],
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
            _fromKey.currentState.validate();
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
                  validator: (value) {
                    value = value.trim();
                    if (value == "0") {
                      return S.of(context).input_corrent_count_hint;
                    }
                    if (!RegExp(r"\d+(\.\d+)?$").hasMatch(value)) {
                      return S.of(context).input_corrent_count_hint;
                    }
                    if (Decimal.parse(value) >
                        Decimal.parse(_assetList
                            .getAsset(_selectedCoinType)
                            .accountAvailable)) {
                      return S.of(context).input_count_over_balance;
                    }
                    return null;
                  },
                  controller: _amountController,
                  decoration: InputDecoration.collapsed(
                    hintText: '请输入划转数量',
                    hintStyle: TextStyle(
                      color: HexColor('#FF999999'),
                      fontSize: 13,
                    ),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ),
            Text(
              _selectedCoinType,
              style: TextStyle(
                color: HexColor('#FF777777'),
                fontSize: 13,
              ),
            ),
            Text('  |  '),
            InkWell(
              child: Text('全部'),
              onTap: () {
                _amountController.text =
                    _assetList.getAsset(_selectedCoinType).accountAvailable;
                setState(() {});
              },
            )
          ],
        ),
        Divider(),
        Text(
          '可用${_assetList.getAsset(_selectedCoinType).accountAvailable} ${_selectedCoinType}',
          style: TextStyle(color: HexColor('#FFAAAAAA'), fontSize: 14),
        )
      ],
    );
  }

  _transferHint() {
    var msg;
    if (_transferType == TransferType.AccountToExchange) {
      msg = '只有将资产划转到交易账户才可以进行交易。资金账户<->交易账户互转不收取手续费。';
    } else if (_transferType == TransferType.ExchangeToAccount) {
      msg = '只有将资产划转到交易账户才可以进行交易。资金账户<->交易账户互转不收取手续费。';
    } else if (_transferType == TransferType.AccountToWallet) {
      msg = '从资金账户划转到钱包账户每笔需要收取50手续费';
    } else if (_transferType == TransferType.WalletToAccount) {
      msg = '从钱包账户划转到资金账户，需要等待整个网络的确认，大约需要15-30分钟。';
    }
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
            msg,
            style: TextStyle(
                color: HexColor('#FF777777'), fontSize: 14, height: 1.8),
          ),
        ),
      ),
    );
  }

  _checkAmount() {}
}

///划转类型
enum TransferType {
  WalletToAccount,
  AccountToWallet,
  AccountToExchange,
  ExchangeToAccount,
}
