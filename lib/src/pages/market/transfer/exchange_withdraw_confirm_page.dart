import 'dart:async';

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
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/model.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/vo/coin_vo.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/config/extends_icon_font.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';

class ExchangeWithdrawConfirmPage extends StatefulWidget {
  final CoinVo coinVo;
  final String amount;
  final String withdrawFeeByGas;

  ExchangeWithdrawConfirmPage(
    String coinVo,
    this.amount,
    this.withdrawFeeByGas,
  ) : coinVo = CoinVo.fromJson(FluroConvertUtils.string2map(coinVo));

  @override
  State<StatefulWidget> createState() {
    return _ExchangeWithdrawConfirmPageState();
  }
}

class _ExchangeWithdrawConfirmPageState
    extends BaseState<ExchangeWithdrawConfirmPage> {
  var isGasFeeLoadingSuccess = false;
  int selectedPriceLevel = 1;
  Decimal _gasFeeByToken = Decimal.zero;
  String _gasPriceEstimateStr = '';
  StreamController<Status> _gasFeeController = StreamController.broadcast();

  Decimal _actualAmount = Decimal.zero;

  ExchangeApi _exchangeApi = ExchangeApi();
  var isTransferring = false;

  WalletVo get activatedWallet {
    return WalletInheritedModel.of(context).activatedWallet;
  }

  double get quotePrice {
    return WalletInheritedModel.of(context)
            .activatedQuoteVoAndSign(widget.coinVo.symbol)
            ?.quoteVo
            ?.price ??
        0;
  }

  String get quoteSign {
    return WalletInheritedModel.of(context)
            .activatedQuoteVoAndSign(widget.coinVo.symbol)
            ?.sign
            ?.sign ??
        '';
  }

  dynamic get gasPriceRecommend {
    if (widget.coinVo.coinType == CoinType.BITCOIN) {
      return WalletInheritedModel.of(
        context,
        aspect: WalletAspect.gasPrice,
      ).btcGasPriceRecommend;
    } else {
      return WalletInheritedModel.of(
        context,
        aspect: WalletAspect.gasPrice,
      ).gasPriceRecommend;
    }
  }

  Decimal get gasPrice {
    if (widget.coinVo.coinType == CoinType.HYN_ATLAS) {
      return Decimal.fromInt(1 * TokenUnit.G_WEI);
    }
    switch (selectedPriceLevel) {
      case 0:
        return gasPriceRecommend.safeLow;
      case 1:
        return gasPriceRecommend.average;
      case 2:
        return gasPriceRecommend.fast;
      default:
        return gasPriceRecommend.average;
    }
  }

  @override
  void onCreated() async {}

  @override
  void dispose() {
    _gasFeeController?.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<WalletCmpBloc>(context).add(UpdateGasPriceEvent());
  }

  initData() {
    try {
      if (widget.coinVo.coinType == CoinType.HYN_ATLAS) {
        var hynQuotePrice = WalletInheritedModel.of(context)
                .activatedQuoteVoAndSign('HYN')
                ?.quoteVo
                ?.price ??
            0;

        ///Contract tokens
        var gasLimit = widget.coinVo.contractAddress != null
            ? SettingInheritedModel.ofConfig(context)
                .systemConfigEntity
                .erc20TransferGasLimit
            : SettingInheritedModel.ofConfig(context)
                .systemConfigEntity
                .ethTransferGasLimit;

        var gasPriceEstimate = ConvertTokenUnit.weiToEther(
            weiBigInt: BigInt.parse(
                (gasPrice * Decimal.fromInt(gasLimit)).toStringAsFixed(0)));

        var gasFeeQuotePrice = gasPriceEstimate *
            Decimal.parse(hynQuotePrice.toString()) *
            Decimal.parse(widget.withdrawFeeByGas);

        _gasFeeByToken =
            (Decimal.parse('$gasFeeQuotePrice') / Decimal.parse('$quotePrice'));

        _gasPriceEstimateStr =
            " ${(gasPrice / Decimal.fromInt(TokenUnit.G_WEI)).toStringAsFixed(1)} GDUST ($gasPriceEstimate HYN)";
      } else {
        var ethQuotePrice = WalletInheritedModel.of(context)
                .activatedQuoteVoAndSign('ETH')
                ?.quoteVo
                ?.price ??
            0;
        var gasLimit = widget.coinVo.symbol == "ETH"
            ? SettingInheritedModel.ofConfig(context)
                .systemConfigEntity
                .ethTransferGasLimit
            : SettingInheritedModel.ofConfig(context)
                .systemConfigEntity
                .erc20TransferGasLimit;
        var gasEstimate = ConvertTokenUnit.weiToEther(
            weiBigInt: BigInt.parse(
                (gasPrice * Decimal.fromInt(gasLimit)).toStringAsFixed(0)));

        var gasFeeQuotePrice = gasEstimate *
            Decimal.parse(ethQuotePrice.toString()) *
            Decimal.parse(widget.withdrawFeeByGas);

        _gasFeeByToken = Decimal.parse(FormatUtil.truncateDecimalNum(
          Decimal.parse('$gasFeeQuotePrice') / Decimal.parse('$quotePrice'),
          8,
        ));

        _gasPriceEstimateStr =
            "${(gasPrice / Decimal.fromInt(TokenUnit.G_WEI)).toStringAsFixed(1)} GWEI ($gasEstimate ETH) ";
      }
    } catch (e) {}

    _actualAmount =
        Decimal.parse(widget.amount) - Decimal.parse(_gasFeeByToken.toString());
  }

  @override
  Widget build(BuildContext context) {
    initData();

    return BlocListener<WalletCmpBloc, WalletCmpState>(
      listener: (context, state) {
        if (state is GasPriceState) {
          if (state.status == Status.loading) {
            _gasFeeController.add(Status.loading);
            isGasFeeLoadingSuccess = false;
          } else if (state.status == Status.success) {
            _gasFeeController.add(Status.success);
            isGasFeeLoadingSuccess = true;
          } else if (state.status == Status.failed) {
            _gasFeeController.add(Status.failed);
            isGasFeeLoadingSuccess = false;
          }
        }
        if (mounted) setState(() {});
      },
      child: BlocBuilder<WalletCmpBloc, WalletCmpState>(
        builder: (BuildContext context, WalletCmpState state) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(color: Colors.black),
              centerTitle: true,
              title: Text(
                S.of(context).exchange_withdraw_confirm,
                style: TextStyle(color: Colors.black),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  info(),
                  detail(),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 36, horizontal: 36),
                    constraints: BoxConstraints.expand(height: 48),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      disabledColor: Colors.grey[600],
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      disabledTextColor: Colors.white,
                      onPressed: isTransferring || !isGasFeeLoadingSuccess
                          ? null
                          : () async {
                              await _transfer(
                                _actualAmount.toString(),
                                '$_gasFeeByToken',
                              );
                            },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              isTransferring
                                  ? S.of(context).please_waiting
                                  : S.of(context).send,
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
          );
        },
      ),
    );
  }

  info() {
    var _amountString = '- ${widget.amount} ${widget.coinVo.symbol}';
    var _amountQuotePriceString =
        "≈ $quoteSign ${FormatUtil.formatPrice(double.parse(widget.amount) * quotePrice)}";

    return Column(
      children: [
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 8),
                      child: Text(
                        _amountString,
                        style: TextStyle(
                            color: Color(0xFF252525),
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ),
                    Text(
                      _amountQuotePriceString,
                      style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 14),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      S.of(context).exchange_from,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: HexColor('#FF999999'),
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            S.of(context).exchange_account,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: HexColor('#FF333333'),
                            ),
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          )
                        ],
                      )),
                ],
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(
            height: 2,
          ),
        ),
      ],
    );
  }

  detail() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      S.of(context).exchange_to,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: HexColor('#FF999999'),
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            "${activatedWallet.wallet.keystore.name}",
                            style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF333333),
                                fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          ),
                          Text(
                            "(${shortBlockChainAddress(WalletUtil.formatToHynAddrIfAtlasChain(
                              widget.coinVo,
                              widget.coinVo.address,
                            ))})",
                            style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF999999),
                                fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          )
                        ],
                      )),
                ],
              )
            ],
          ),
        ),
        divider(),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  S.of(context).exchange_network_fee,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: HexColor('#FF999999'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerLeft,
                          child: _gasPriceEstimateStr != null
                              ? Text(
                                  _gasPriceEstimateStr,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF333333),
                                      fontWeight: FontWeight.bold,
                                      height: 1.6),
                                )
                              : SizedBox(),
                        ),
                        StreamBuilder<Status>(
                            stream: _gasFeeController.stream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data == Status.loading) {
                                  return SizedBox(
                                    width: 30,
                                    height: 10,
                                    child: CupertinoActivityIndicator(),
                                  );
                                } else if (snapshot.data == Status.failed) {
                                  return InkWell(
                                    onTap: () {
                                      BlocProvider.of<WalletCmpBloc>(context)
                                          .add(UpdateGasPriceEvent());
                                    },
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 0.0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.autorenew,
                                            size: 20,
                                            color: Colors.blue,
                                          ),
                                          Text(
                                            '点击刷新',
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              }
                              return SizedBox();
                            })
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: widget.coinVo.symbol != 'HYN'
                          ? Text(
                              '≈ $_gasFeeByToken ${widget.coinVo.symbol}',
                              style: TextStyle(
                                color: DefaultColors.color999,
                                fontSize: 13,
                              ),
                            )
                          : SizedBox(),
                    ),
                    Text(
                      S
                          .of(context)
                          .fee_deducted_offset_by_symbol(widget.coinVo.symbol),
                      style: TextStyle(
                        color: DefaultColors.color999,
                        fontSize: 12,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        divider(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      S.of(context).exchange_withdraw_actual_amount,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: HexColor('#FF999999'),
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            '$_actualAmount ${widget.coinVo.symbol}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: HexColor('#FF333333'),
                            ),
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          )
                        ],
                      )),
                ],
              )
            ],
          ),
        ),
        divider(),
      ],
    );
  }

  divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(
        height: 2,
      ),
    );
  }

  Future _transfer(String actualAmount, String gasFee) async {
    if (Decimal.parse(actualAmount) < Decimal.zero) {
      Fluttertoast.showToast(msg: S.of(context).input_count_over_balance);
      return;
    }
    var walletPassword = await UiUtil.showWalletPasswordDialogV2(
      context,
      activatedWallet.wallet,
    );

    _transferWithPwd(
      walletPassword,
      actualAmount,
      gasFee,
    );
  }

  _transferWithPwd(
    String walletPassword,
    String actualAmount,
    String gasFee,
  ) async {
    setState(() {
      isTransferring = true;
    });
    try {
      var ret = await _exchangeApi.withdraw(
        activatedWallet.wallet,
        walletPassword,
        activatedWallet.wallet.getEthAccount().address,
        widget.coinVo.symbol,
        widget.coinVo.address,
        actualAmount,
        gasFee,
      );
      print('$ret');

      var msg;
      if (widget.coinVo.coinType == CoinType.HYN_ATLAS) {
        msg = S.of(context).atlas_transfer_broadcast_success_description;
      } else {
        msg = S.of(context).transfer_broadcase_success_description;
      }
      msg = FluroConvertUtils.fluroCnParamsEncode(msg);
      Application.router
          .navigateTo(context, Routes.confirm_success_papge + '?msg=$msg');

      setState(() {
        isTransferring = true;
      });

      ///update assets
      BlocProvider.of<ExchangeCmpBloc>(context).add(UpdateAssetsEvent());
    } catch (e) {
      setState(() {
        isTransferring = false;
      });
      if (e is HttpResponseCodeNotSuccess) {
        Fluttertoast.showToast(msg: e.message);
      }
    }
  }
}
