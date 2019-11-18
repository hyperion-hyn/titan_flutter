import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/keystore.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/presentation/extends_icon_font.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/enter_wallet_password.dart';
import 'package:web3dart/credentials.dart' as web3;
import 'package:web3dart/json_rpc.dart';

import 'model/wallet_account_vo.dart';

class WalletSendConfirmPage extends StatefulWidget {
  WalletAccountVo walletAccountVo;
  final double count;
  final String receiverAddress;
  final String backRouteName;

  WalletSendConfirmPage(this.walletAccountVo, this.count, this.receiverAddress, {this.backRouteName});

  @override
  State<StatefulWidget> createState() {
    return _WalletSendConfirmState();
  }
}

class _WalletSendConfirmState extends State<WalletSendConfirmPage> {
  double ethFee = 0.0;
  double currencyFee = 0.0;

  NumberFormat currency_format = new NumberFormat("#,###.##");
  NumberFormat token_fee_format = new NumberFormat("#,###.########");

  var isLoading = false;

  int speed = EthereumConst.FAST_SPEED;

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
                          "≈ ${widget.walletAccountVo.currencyUnitSymbol}${currency_format.format(widget.count * widget.walletAccountVo.currencyRate)}",
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
                          "$ethFee ETH(≈${widget.walletAccountVo.currencyUnitSymbol} ${currency_format.format(currencyFee)})",
                          style: TextStyle(fontSize: 16, color: Color(0xFF252525)),
                        ),
                      ),

//                      Padding(
//                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
//                        child: IntrinsicHeight(
//                          child: Row(
//                            children: <Widget>[
//                              Expanded(
//                                child: InkWell(
//                                  onTap: () {
//                                    speed = EthereumConst.LOW_SPEED;
//                                    setState(() {});
//                                  },
//                                  child: Container(
//                                    padding: EdgeInsets.symmetric(vertical: 12),
//                                    alignment: Alignment.center,
//                                    decoration: BoxDecoration(
//                                        color: speed == EthereumConst.LOW_SPEED
//                                            ? Colors.blue
//                                            : Colors.grey[200],
//                                        border: Border(),
//                                        borderRadius: BorderRadius.only(
//                                            topLeft: Radius.circular(30), bottomLeft: Radius.circular(30))),
//                                    child: Text(
//                                      "慢",
//                                      style: TextStyle(
//                                          color: speed == EthereumConst.LOW_SPEED
//                                              ? Colors.white
//                                              : Colors.black),
//                                    ),
//                                  ),
//                                ),
//                              ),
//                              VerticalDivider(
//                                width: 2,
//                                thickness: 2,
//                              ),
//                              Expanded(
//                                child: InkWell(
//                                  onTap: () {
//                                    speed = EthereumConst.FAST_SPEED;
//                                    setState(() {});
//                                  },
//                                  child: Container(
//                                    padding: EdgeInsets.symmetric(vertical: 12),
//                                    alignment: Alignment.center,
//                                    decoration: BoxDecoration(
//                                        color: speed == EthereumConst.FAST_SPEED
//                                            ? Colors.blue
//                                            : Colors.grey[200],
//                                        border: Border(),
//                                        borderRadius: BorderRadius.all(Radius.circular(0))),
//                                    child: Text(
//                                      "平均值",
//                                      style: TextStyle(
//                                          color: speed == EthereumConst.FAST_SPEED
//                                              ? Colors.white
//                                              : Colors.black),
//                                    ),
//                                  ),
//                                ),
//                              ),
//                              VerticalDivider(
//                                width: 2,
//                                thickness: 2,
//                              ),
//                              Expanded(
//                                child: InkWell(
//                                  onTap: () {
//                                    speed = EthereumConst.SUPER_FAST_SPEED;
//                                    setState(() {});
//                                  },
//                                  child: Container(
//                                    padding: EdgeInsets.symmetric(vertical: 12),
//                                    alignment: Alignment.center,
//                                    decoration: BoxDecoration(
//                                        color: speed == EthereumConst.SUPER_FAST_SPEED
//                                            ? Colors.blue
//                                            : Colors.grey[200],
//                                        border: Border(),
//                                        borderRadius: BorderRadius.only(
//                                            topRight: Radius.circular(30), bottomRight: Radius.circular(30))),
//                                    child: Text(
//                                      "快",
//                                      style: TextStyle(
//                                          color: speed == EthereumConst.SUPER_FAST_SPEED
//                                              ? Colors.white
//                                              : Colors.black),
//                                    ),
//                                  ),
//                                ),
//                              ),
//                            ],
//                          ),
//                        ),
//                      )
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              height: 36,
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
                onPressed: isLoading ? null : _transfer,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        isLoading ? "请稍后" : "发送",
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
    var wallet = widget.walletAccountVo.wallet;
    var toAddress = widget.receiverAddress;
    var contract = widget.walletAccountVo.assetToken.erc20ContractAddress;
    var decimals = widget.walletAccountVo.assetToken.decimals;
    var amount = widget.count;

    var ethCurrencyRate = widget.walletAccountVo.ethCurrencyRate;

    var erc20FunAbi;

    if (widget.walletAccountVo.assetToken.erc20ContractAddress != null) {
      erc20FunAbi = WalletUtil.getErc20FuncAbiHex(
          erc20Address: contract,
          funName: 'transfer',
          params: [web3.EthereumAddress.fromHex(toAddress), ConvertTokenUnit.etherToWei(etherDouble: amount)]);
    }

    var ret = await wallet.estimateGasPrice(
      toAddress: toAddress,
      value: ConvertTokenUnit.etherToWei(etherDouble: amount),
      gasPrice: BigInt.from(speed),
      data: erc20FunAbi,
    );

    ethFee = ConvertTokenUnit.weiToDecimal(ret, decimals).toDouble();
    currencyFee = (ConvertTokenUnit.weiToDecimal(ret, decimals) * Decimal.parse(ethCurrencyRate.toString())).toDouble();

    logger.i('费率是 $ethFee eth');
    logger.i('费率是 $currencyFee usd');

    setState(() {});
  }

  Future _transfer() async {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return EnterWalletPasswordWidget();
        }).then((walletPassword) async {
      print("walletPassword:$walletPassword");
      if (walletPassword == null) {
        return;
      }

      try {
        setState(() {
          isLoading = true;
        });
        if (widget.walletAccountVo.symbol == "ETH") {
          await _transferEth(walletPassword, widget.count, widget.receiverAddress, widget.walletAccountVo.wallet);
        } else {
          await _transferErc20(walletPassword, widget.count, widget.receiverAddress, widget.walletAccountVo.wallet);
        }
        Fluttertoast.showToast(msg: "转账已提交");
        if (widget.backRouteName == null) {
          Navigator.of(context).popUntil(ModalRoute.withName("/show_account_page"));
        } else {
          Navigator.of(context).popUntil(ModalRoute.withName(widget.backRouteName));
        }
      } catch (_) {
        logger.e(_);
        setState(() {
          isLoading = false;
        });
        if (_ is PlatformException) {
          if (_.code == WalletError.PASSWORD_WRONG) {
            Fluttertoast.showToast(msg: "密码错误");
          } else {
            Fluttertoast.showToast(msg: "转账失败");
          }
        } else if (_ is RPCError) {
          if (_.errorCode == -32000) {
            Fluttertoast.showToast(msg: "ETH余额不足支付网络费用");
          } else {
            Fluttertoast.showToast(msg: "转账失败");
          }
        } else {
          Fluttertoast.showToast(msg: "转账失败");
        }
      }
    });
  }

  Future _transferEth(String password, double etherDouble, String toAddress, Wallet wallet) async {
    var amount = ConvertTokenUnit.etherToWei(etherDouble: etherDouble);

    final txHash = await wallet.sendEthTransaction(
      password: password,
      toAddress: toAddress,
      gasPrice: BigInt.from(speed),
      value: amount,
    );

    logger.i('ETH交易已提交，交易hash $txHash');
  }

  Future _transferErc20(String password, double etherDouble, String toAddress, Wallet wallet) async {
    var amount = ConvertTokenUnit.etherToWei(etherDouble: etherDouble);
    var contractAddress = widget.walletAccountVo.assetToken.erc20ContractAddress;

    final txHash = await wallet.sendErc20Transaction(
      contractAddress: contractAddress,
      password: password,
      gasPrice: BigInt.from(speed),
      value: amount,
      toAddress: toAddress,
    );

    logger.i('HYN交易已提交，交易hash $txHash ');
  }
}
