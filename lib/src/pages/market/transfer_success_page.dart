import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/pages/market/transfer_page.dart';
import 'package:titan/src/routes/routes.dart';

class TransferSuccessPage extends StatefulWidget {
  final TransferType _transferType;

  TransferSuccessPage(this._transferType);

  @override
  State<StatefulWidget> createState() {
    return _TransferSuccessPageState();
  }
}

class _TransferSuccessPageState extends State<TransferSuccessPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
          ),
          body: Center(
            child: Container(
              padding: EdgeInsets.all(16),
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 48),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Image.asset(
                      "res/drawable/check_outline.png",
                      height: 76,
                      width: 124,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _getTitleByTransferType(widget._transferType),
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _getDescriptionByTransferType(widget._transferType),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF9B9B9B),
                        height: 1.8,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 36,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 16, horizontal: 36),
                    constraints: BoxConstraints.expand(height: 48),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      disabledColor: Colors.grey[600],
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      disabledTextColor: Colors.white,
                      onPressed: () async {
                        Navigator.of(context).pop();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              S.of(context).finish,
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  _getTitleByTransferType(TransferType _transferType) {
    if (_transferType == TransferType.AccountToExchange) {
      return '划转成功';
    } else if (_transferType == TransferType.ExchangeToAccount) {
      return '划转成功';
    } else if (_transferType == TransferType.AccountToWallet) {
      return '申请划转成功';
    } else if (_transferType == TransferType.WalletToAccount) {
      return '广播成功';
    }
  }

  _getDescriptionByTransferType(TransferType _transferType) {
    if (_transferType == TransferType.AccountToExchange) {
      return '已经成功将资金从资金账户划转到交易账户，你现在可以挂单交易了。';
    } else if (_transferType == TransferType.ExchangeToAccount) {
      return '已经成功将资金从交易账户划转到资金账户。';
    } else if (_transferType == TransferType.AccountToWallet) {
      return '你已经成功申请将资金划转到关联钱包，请等待系统确认验证。';
    } else if (_transferType == TransferType.WalletToAccount) {
      return '已在区块链上网络广播 【资金划转】的消息，区块链网络需要5-30分钟开采验证。';
    }
  }
}
