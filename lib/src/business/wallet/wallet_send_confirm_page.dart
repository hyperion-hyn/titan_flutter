import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/wallet/model_vo.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/keystore.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';

import '../../global.dart';

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
        appBar: AppBar(),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_upward,
                      color: Colors.grey,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      "-${widget.count} ${widget.walletAccountVo.symbol}",
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                  ),
                  Text(
                    "(${widget.walletAccountVo.currencyUnit}${currency_format.format(widget.count * widget.walletAccountVo.currencyRate)})",
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  )
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "From",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          "${(widget.walletAccountVo.wallet.keystore as TrustWalletKeyStore).name}(${widget.walletAccountVo.account.address})",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "To",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          widget.receiverAddress,
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: <Widget>[
                  Text(
                    "网络费用",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                  ),
                  Spacer(),
                  Text(
                    "${ethFee * widget.count} ETH(USD ${currency_format.format(usdFee * widget.count)})",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  )
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(color: HexColor("#fbf8f9")),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      "最大总计",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    Text(
                      "0.000058985 ETH(USD\$0.10)",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    )
                  ],
                ),
              ),
            ),
            Spacer(),
            Row(children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  child: RaisedButton(
                    color: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 128, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    onPressed: () {
                      _transfer();
                    },
                    child: Text(
                      "发送",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ])
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
        amount: Convert.numToWei(amount, decimals).toRadixString(16));

    ethFee = Convert.weiToNum(gasFee).toDouble();
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
    var amount = Convert.numToWei(widget.count).toRadixString(16);
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
