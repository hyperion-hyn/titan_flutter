import 'dart:convert';
import 'dart:math';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/wallet/vo/coin_vo.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/config/extends_icon_font.dart';

import '../../global.dart';

class WalletSendPage extends StatefulWidget {
  final CoinVo coinVo;
  final String toAddress;

  WalletSendPage(String coinVo, [String toAddress])
      : this.coinVo = CoinVo.fromJson(FluroConvertUtils.string2map(coinVo)),
        this.toAddress = toAddress;

  @override
  State<StatefulWidget> createState() {
    return _WalletSendState();
  }
}

class _WalletSendState extends State<WalletSendPage> {
  final TextEditingController _receiverAddressController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  final _fromKey = GlobalKey<FormState>();

  double _notionalValue = 0;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      var activatedQuoteSign = QuotesInheritedModel.of(context).activatedQuoteVoAndSign(widget.coinVo.symbol);
      var quotePrice = activatedQuoteSign?.quoteVo?.price ?? 0;
      setState(() {
        _notionalValue = double.parse(_amountController.text) * quotePrice;
      });
    });
    if (widget.toAddress != null) {
      _receiverAddressController.text = widget.toAddress;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var activatedQuoteSign = QuotesInheritedModel.of(context).activatedQuoteVoAndSign(widget.coinVo.symbol);
    var quotePrice = activatedQuoteSign?.quoteVo?.price ?? 0;
    var quoteSign = activatedQuoteSign?.sign?.sign;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          S.of(context).send_symbol(widget.coinVo.symbol),
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Form(
                key: _fromKey,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          S.of(context).receiver_address,
                          style: TextStyle(
                            color: Color(0xFF6D6D6D),
                            fontSize: 16,
                          ),
                        ),
                        Spacer(),
                        InkWell(
                          onTap: onPaste,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(
                              ExtendsIconFont.copy_content,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => onScan(quotePrice),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(
                              ExtendsIconFont.qrcode_scan,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                      child: TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return S.of(context).receiver_address_not_empty_hint;
                            } else {
                              //TODO support more chain address regexp
                              final RegExp _ethBasicAddress = RegExp(r'^(0x)?[0-9a-f]{40}', caseSensitive: false);
                              if (!_ethBasicAddress.hasMatch(value)) {
                                return S.of(context).input_valid_address;
                              }
                            }
                            return null;
                          },
                          controller: _receiverAddressController,
                          decoration: InputDecoration(
                            hintText: '如: 0x81e7A0529AC1726e...',
                            hintStyle: TextStyle(color: Colors.black12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          keyboardType: TextInputType.text),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          S.of(context).send_count_label(widget.coinVo.symbol),
                          style: TextStyle(
                            color: Color(0xFF6D6D6D),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '(可用 ${WalletUtil.formatCoinNum(widget.coinVo.balance)})',
                          style: TextStyle(fontSize: 12, color: Colors.black38),
                        ),
                        Spacer(),
                        InkWell(
                          onTap: () {
                            _amountController.text = WalletUtil.formatCoinNum(widget.coinVo.balance);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                            child: Text(
                              S.of(context).all,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  textBaseline: TextBaseline.ideographic),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                      child: TextFormField(
                        validator: (value) {
                          if (value == "0") {
                            return S.of(context).input_corrent_count_hint;
                          }
                          if (!RegExp(r"\d+(\.\d+)?$").hasMatch(value)) {
                            return S.of(context).input_corrent_count_hint;
                          }
                          if (double.parse(value) > widget.coinVo.balance) {
                            return S.of(context).input_count_over_balance;
                          }
                          return null;
                        },
                        controller: _amountController,
                        decoration: InputDecoration(
                          hintText: '输入转账数量',
                          hintStyle: TextStyle(color: Colors.black12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
//                        onChanged: (value) {
//                          setState(() {
//                            _notionalValue = double.parse(value) * quotePrice;
//                          });
//                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(left: 8, top: 8),
                            child: Text("≈ $quoteSign${WalletUtil.formatPrice(_notionalValue)}")),
                      ],
                    ),
                    SizedBox(
                      height: 12,
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 36, horizontal: 36),
                constraints: BoxConstraints.expand(height: 48),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  disabledColor: Colors.grey[600],
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  disabledTextColor: Colors.white,
                  onPressed: widget.coinVo == null ? null : submit,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          S.of(context).next,
                          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void submit() {
    if (_fromKey.currentState.validate()) {
      var count = double.parse(_amountController.text);
      if (count <= 0) {
        Fluttertoast.showToast(msg: '转账数目必须大于0');
        return;
      }

      var voStr = FluroConvertUtils.object2string(widget.coinVo.toJson());
      Application.router.navigateTo(
          context,
          Routes.wallet_transfer_token_confirm +
              "?coinVo=$voStr&transferAmount=${_amountController.text}&receiverAddress=${_receiverAddressController.text}");
    }
  }

  Future onScan(double price) async {
    try {
      String barcode = await BarcodeScanner.scan();
      if (barcode.contains("ethereum")) {
        //imtoken style address
        var barcodeArray = barcode.split("?");
        var withAddress = barcodeArray[0];
        var address = withAddress.replaceAll("ethereum:", "");
        _receiverAddressController.text = address;

        //handle params
        if (barcodeArray.length > 1) {
          var withValue = barcodeArray[1];
          var valuesArray = withValue.split("&");
          var valueMap = Map();
          valuesArray.forEach((valueStringTemp) {
            var keyValueArray = valueStringTemp.split("=");
            valueMap[keyValueArray[0]] = keyValueArray[1];
          });
          var value = valueMap["value"];
          var decimal = valueMap["decimal"];
          if (value != null && decimal != null && double.parse(value) > 0) {
            var transferSize = (double.parse(value) / (pow(10, int.parse(decimal))));
            _amountController.text = transferSize.toString();
            setState(() {
              _notionalValue = transferSize * price;
            });
          }
        }
      } else {
        _receiverAddressController.text = barcode;
      }
    } catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        Fluttertoast.showToast(msg: S.of(context).open_camera, toastLength: Toast.LENGTH_SHORT);
      } else {
        logger.e(e);
        _receiverAddressController.text = "";
      }
    }
  }

  Future onPaste() async {
    var text = await Clipboard.getData(Clipboard.kTextPlain);
    if (text == null) {
      return;
    }
    _receiverAddressController.text = text.text;
  }
}
