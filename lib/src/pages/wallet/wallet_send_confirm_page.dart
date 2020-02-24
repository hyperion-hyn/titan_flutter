import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/wallet/vo/coin_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/config/extends_icon_font.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/enter_wallet_password.dart';
import 'package:web3dart/json_rpc.dart';

import '../../extension/navigator_ext.dart';

class WalletSendConfirmPage extends StatefulWidget {
  final CoinVo coinVo;
  final double transferAmount;
  final String receiverAddress;
  final String backRouteName;

  WalletSendConfirmPage(String coinVo, this.transferAmount, this.receiverAddress, {this.backRouteName})
      : coinVo = CoinVo.fromJson(FluroConvertUtils.string2map(coinVo));

  @override
  State<StatefulWidget> createState() {
    return _WalletSendConfirmState();
  }
}

class _WalletSendConfirmState extends BaseState<WalletSendConfirmPage> {
  double ethFee = 0.0;
  double currencyFee = 0.0;

  NumberFormat currency_format = new NumberFormat("#,###.##");
  NumberFormat token_fee_format = new NumberFormat("#,###.########");

  var isLoading = false;
  var isLoadingGasFee = false;

  int speed = EthereumConst.FAST_SPEED;

  @override
  void onCreated() {
    var defaultSpeed = EthereumConst.FAST_SPEED;
    var activatedQuoteSign = QuotesInheritedModel.of(context).activatedQuoteVoAndSign(widget.coinVo.symbol);
    var quotePrice = activatedQuoteSign?.quoteVo?.price ?? 0;
    _updateSpeed(defaultSpeed, quotePrice);
  }

  @override
  Widget build(BuildContext context) {
    var activatedQuoteSign = QuotesInheritedModel.of(context).activatedQuoteVoAndSign(widget.coinVo.symbol);
    var quotePrice = activatedQuoteSign?.quoteVo?.price ?? 0;
    var quoteSign = activatedQuoteSign?.sign?.sign;
    var activatedWallet = WalletInheritedModel.of(context).activatedWallet;

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
          title: Text(
            S.of(context).transfer_confirm,
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
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
                            "-${widget.transferAmount} ${widget.coinVo.symbol}",
                            style: TextStyle(color: Color(0xFF252525), fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                        Text(
                          "≈ $quoteSign${currency_format.format(widget.transferAmount * quotePrice)}",
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
                          "${activatedWallet.wallet.keystore.name}(${shortBlockChainAddress(widget.coinVo.address)})",
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
                          shortBlockChainAddress(widget.receiverAddress),
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
                            "$ethFee ETH(≈ $quoteSign${currency_format.format(currencyFee)})",
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
                              _updateSpeed(EthereumConst.LOW_SPEED, quotePrice);
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
                              _updateSpeed(EthereumConst.FAST_SPEED, quotePrice);
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
                              _updateSpeed(EthereumConst.SUPER_FAST_SPEED, quotePrice);
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
        ),),);
  }

  void _updateSpeed(int newSpeed, double price) {
    setState(() {
      speed = newSpeed;
      ethFee = speed.toDouble() *
          (widget.coinVo.contractAddress == null ? EthereumConst.ETH_GAS_LIMIT : EthereumConst.ERC20_GAS_LIMIT);
      currencyFee = ethFee * price;
    });
//    _getGasFee();
  }

//  Future _getGasFee() async {
//    setState(() {
//      isLoadingGasFee = true;
//    });
//    var wallet = widget.coinVo.wallet;
//    var toAddress = widget.receiverAddress;
//    var contract = widget.coinVo.assetToken.contractAddress;
//    var decimals = widget.coinVo.assetToken.decimals;
//    var amount = widget.transferAmount;
//
//    var ethCurrencyRate = widget.coinVo.ethCurrencyRate;
//
//    var erc20FunAbi;
//
//    if (widget.coinVo.assetToken.contractAddress != null) {
//      erc20FunAbi = WalletUtil.getErc20FuncAbiHex(
//          erc20Address: contract,
//          funName: 'transfer',
//          params: [web3.EthereumAddress.fromHex(toAddress), ConvertTokenUnit.etherToWei(etherDouble: amount)]);
//    }
//
//    var ret = await wallet.estimateGasPrice(
//      toAddress: toAddress,
//      value: ConvertTokenUnit.etherToWei(etherDouble: amount),
//      gasPrice: BigInt.from(speed),
//      data: erc20FunAbi,
//    );
//
//    ethFee = ConvertTokenUnit.weiToDecimal(ret, decimals).toDouble();
//    currencyFee = (ConvertTokenUnit.weiToDecimal(ret, decimals) * Decimal.parse(ethCurrencyRate.toString())).toDouble();
//
//    logger.i('费率是 $ethFee eth');
//    logger.i('费率是 $currencyFee usd');
//
//    setState(() {
//      isLoadingGasFee = false;
//    });
//  }

  Future _transfer() async {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return EnterWalletPasswordWidget();
        }).then((walletPassword) async {
      if (walletPassword == null) {
        return;
      }

      try {
        setState(() {
          isLoading = true;
        });
        var activatedWallet = WalletInheritedModel.of(context).activatedWallet;
        if (widget.coinVo.symbol == "ETH") {
          await _transferEth(walletPassword, widget.transferAmount, widget.receiverAddress, activatedWallet.wallet);
        } else {
          await _transferErc20(walletPassword, widget.transferAmount, widget.receiverAddress, activatedWallet.wallet);
        }
        Fluttertoast.showToast(msg: S.of(context).transfer_submitted);
        if (widget.backRouteName == null) {
          Navigator.of(context).popUntilRouteName(Routes.wallet_account_detail);
        } else {
          Navigator.of(context).popUntilRouteName(Uri.decodeComponent(widget.backRouteName));
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

    logger.i('ETH transaction committed，txhash $txHash');
  }

  Future _transferErc20(String password, double etherDouble, String toAddress, Wallet wallet) async {
    var amount = ConvertTokenUnit.etherToWei(etherDouble: etherDouble);
    var contractAddress = widget.coinVo.contractAddress;

    final txHash = await wallet.sendErc20Transaction(
      contractAddress: contractAddress,
      password: password,
      gasPrice: BigInt.from(speed),
      value: amount,
      toAddress: toAddress,
    );

    logger.i('HYN transaction committed，txhash $txHash ');
  }
}
