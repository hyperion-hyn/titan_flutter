import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/keystore.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/consts/extends_icon_font.dart';
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
  var isLoadingGasFee = false;

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
            S.of(context).confirm,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      S.of(context).gas_fee,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: Color(0xFF9B9B9B)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerLeft,
                          height: 24,
                          child: Text(
                            "$ethFee ETH(≈${widget.walletAccountVo.currencyUnitSymbol} ${currency_format.format(currencyFee)})",
                            style: TextStyle(fontSize: 16, color: Color(0xFF252525)),
                          ),
                        ),
                        if (isLoadingGasFee)
                          Container(
                            width: 24,
                            height: 24,
                            child: CupertinoActivityIndicator(),
                          )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              _speedOnTap(EthereumConst.LOW_SPEED);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: speed == EthereumConst.LOW_SPEED ? Colors.blue : Colors.grey[200],
                                  border: Border(),
                                  borderRadius:
                                      BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30))),
                              child: Text(
                                S.of(context).speed_slow,
                                style: TextStyle(color: speed == EthereumConst.LOW_SPEED ? Colors.white : Colors.black),
                              ),
                            ),
                          ),
                        ),
                        VerticalDivider(
                          width: 2,
                          thickness: 2,
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              _speedOnTap(EthereumConst.FAST_SPEED);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: speed == EthereumConst.FAST_SPEED ? Colors.blue : Colors.grey[200],
                                  border: Border(),
                                  borderRadius: BorderRadius.all(Radius.circular(0))),
                              child: Text(
                                S.of(context).speed_normal,
                                style:
                                    TextStyle(color: speed == EthereumConst.FAST_SPEED ? Colors.white : Colors.black),
                              ),
                            ),
                          ),
                        ),
                        VerticalDivider(
                          width: 2,
                          thickness: 2,
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              _speedOnTap(EthereumConst.SUPER_FAST_SPEED);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: speed == EthereumConst.SUPER_FAST_SPEED ? Colors.blue : Colors.grey[200],
                                  border: Border(),
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(30), bottomRight: Radius.circular(30))),
                              child: Text(
                                S.of(context).speed_fast,
                                style: TextStyle(
                                    color: speed == EthereumConst.SUPER_FAST_SPEED ? Colors.white : Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
                        isLoading ? S.of(context).please_waiting : S.of(context).send,
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

  void _speedOnTap(int newSpeed) {
    speed = newSpeed;
    setState(() {});
    _getGasFee();
  }

  Future _getGasFee() async {
    setState(() {
      isLoadingGasFee = true;
    });
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

    setState(() {
      isLoadingGasFee = false;
    });
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
        Fluttertoast.showToast(msg: S.of(context).transfer_submitted);
        if (widget.backRouteName == null) {
          Navigator.of(context).popUntil(ModalRoute.withName("/show_account_page"));
        } else {
          isRechargeByTianWalletFinish = true;
          Navigator.of(context).popUntil(ModalRoute.withName(widget.backRouteName));
        }
      } catch (_) {
        logger.e(_);
        setState(() {
          isLoading = false;
        });
        if (_ is PlatformException) {
          if (_.code == WalletError.PASSWORD_WRONG) {
            Fluttertoast.showToast(msg: S.of(context).password_incorrect);
          } else {
            Fluttertoast.showToast(msg: S.of(context).transfer_fail);
          }
        } else if (_ is RPCError) {
          if (_.errorCode == -32000) {
            Fluttertoast.showToast(msg: S.of(context).eth_balance_not_enough_for_gas_fee);
          } else {
            Fluttertoast.showToast(msg: S.of(context).transfer_fail);
          }
        } else {
          Fluttertoast.showToast(msg: S.of(context).transfer_fail);
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
