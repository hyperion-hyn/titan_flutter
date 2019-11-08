import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/keystore.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/presentation/extends_icon_font.dart';
import 'package:titan/src/utils/utils.dart';

import '../../global.dart';
import 'model/wallet_account_vo.dart';

class WalletSendConfirmPage extends StatefulWidget {
  final WalletAccountVo walletAccountVo;
  final double count;
  final String receiverAddress;

  WalletSendConfirmPage(this.walletAccountVo, this.count, this.receiverAddress);

  @override
  State<StatefulWidget> createState() {
    return _WalletSendConfirmState();
  }
}

class _WalletSendConfirmState extends State<WalletSendConfirmPage> {
  double ethFee = 0.0;
  double usdFee = 0.0;

  NumberFormat currency_format = new NumberFormat("#,###.##");

  @override
  void initState() {
    _getGasFee();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
          title: Text(
            "确认",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    color: Color(0xFFF5F5F5),
                    padding: const EdgeInsets.only(top: 24, bottom: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          ExtendsIconFont.send,
                          color: Theme.of(context).primaryColor,
                          size: 48,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                          child: Text(
                            "-${widget.count} ${widget.walletAccountVo.symbol}",
                            style: TextStyle(color: Color(0xFF252525), fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                        Text(
                          "(${widget.walletAccountVo.currencyUnit}${currency_format.format(widget.count * widget.walletAccountVo.currencyRate)})",
                          style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 14),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          "From",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: Color(0xFF9B9B9B)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          "${(widget.walletAccountVo.wallet.keystore as KeyStore).name}(${shortEthAddress(widget.walletAccountVo.account.address)})",
                          style: TextStyle(fontSize: 16, color: Color(0xFF252525)),
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            Divider(
              height: 2,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          "To",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: Color(0xFF9B9B9B)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          shortEthAddress(widget.receiverAddress),
                          style: TextStyle(fontSize: 16, color: Color(0xFF252525)),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            Divider(
              height: 2,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          "网络费用",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: Color(0xFF9B9B9B)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          "${ethFee * widget.count} ETH(USD ${currency_format.format(usdFee * widget.count)})",
                          style: TextStyle(fontSize: 16, color: Color(0xFF252525)),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "最大总计 USD\$0.10",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF252525)),
                  ),
                ),
              ],
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
                onPressed: () {
                  _transfer();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "发送",
                        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Future _getGasFee() async {
    var fromAddress = widget.walletAccountVo.account.address;
    var toAddress = widget.receiverAddress;
    var contract = widget.walletAccountVo.assetToken.erc20ContractAddress;
    var decimals = 18;
    var amount = 13.45;
    var gasFee = await WalletUtil.estimateGas(
        fromAddress: fromAddress,
        toAddress: toAddress,
        coinType: CoinType.ETHEREUM,
        erc20ContractAddress: contract,
        amount: ConvertTokenUnit.numToWei(amount, decimals).toRadixString(16));

    ethFee = ConvertTokenUnit.weiToDecimal(gasFee).toDouble();
    usdFee = ethFee * widget.walletAccountVo.ethCurrencyRate;

    logger.i('费率是 $ethFee eth');
    logger.i('费率是 $usdFee usd');

    setState(() {});
  }

  Future _transfer() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(child: Container(width: 48, height: 48, child: CircularProgressIndicator()));
        });
    var password = 'my password';
    var amount = ConvertTokenUnit.numToWei(widget.count).toRadixString(16);
    try {
      var txHash = await WalletUtil.transferErc20Token(
        password: password,
        fileName: widget.walletAccountVo.wallet.keystore.fileName,
        erc20ContractAddress: widget.walletAccountVo.assetToken.erc20ContractAddress,
        fromAddress: widget.walletAccountVo.account.address,
        toAddress: widget.receiverAddress,
        amount: amount,
      );

      logger.i('HYN交易已提交，交易hash $txHash');

      Navigator.of(context).popUntil(ModalRoute.withName("/show_account_page"));
    } catch (e) {
      Navigator.of(context).pop();
      logger.e(e);
    }
  }
}
