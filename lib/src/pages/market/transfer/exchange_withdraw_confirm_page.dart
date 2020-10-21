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
import 'package:titan/src/components/quotes/bloc/bloc.dart';
import 'package:titan/src/components/quotes/model.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/vo/coin_vo.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/config/extends_icon_font.dart';
import 'package:titan/src/routes/routes.dart';
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
  var isTransferring = false;
  var isLoadingGasFee = false;

  int selectedPriceLevel = 2;

  WalletVo activatedWallet;
  ActiveQuoteVoAndSign activatedQuoteSign;
  ExchangeApi _exchangeApi = ExchangeApi();

  var gasPriceRecommend;

  @override
  void onCreated() async {
    activatedQuoteSign = QuotesInheritedModel.of(context)
        .activatedQuoteVoAndSign(widget.coinVo.symbol);
    activatedWallet = WalletInheritedModel.of(context).activatedWallet;

    if (widget.coinVo.coinType == CoinType.BITCOIN) {
      gasPriceRecommend =
          QuotesInheritedModel.of(context, aspect: QuotesAspect.gasPrice)
              .btcGasPriceRecommend;
    } else {
      gasPriceRecommend =
          QuotesInheritedModel.of(context, aspect: QuotesAspect.gasPrice)
              .gasPriceRecommend;
    }
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<QuotesCmpBloc>(context).add(UpdateGasPriceEvent());
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
  Widget build(BuildContext context) {
    var _quotePrice = activatedQuoteSign?.quoteVo?.price ?? 0;
    var _quoteSign = activatedQuoteSign?.sign?.sign;

    var _amountString = '- ${widget.amount} ${widget.coinVo.symbol}';
    var _amountQuotePriceString =
        "≈ $_quoteSign ${FormatUtil.formatPrice(double.parse(widget.amount) * _quotePrice)}";

    var _gasPriceEstimateStr = "";
    var _gasPriceEstimate;
    if (widget.coinVo.coinType == CoinType.BITCOIN) {
      gasPriceRecommend = QuotesInheritedModel.of(
        context,
        aspect: QuotesAspect.gasPrice,
      ).btcGasPriceRecommend;
      var fees = ConvertTokenUnit.weiToDecimal(
        BigInt.parse((gasPrice * Decimal.fromInt(BitcoinConst.BTC_RAWTX_SIZE))
            .toString()),
        8,
      );
      _gasPriceEstimate = fees * Decimal.parse(_quotePrice.toString());
      _gasPriceEstimateStr =
          "$fees BTC (≈ $_quoteSign${FormatUtil.formatPrice(_gasPriceEstimate.toDouble())})";
    } else if (widget.coinVo.coinType == CoinType.HYN_ATLAS) {
      // var gasPrice = Decimal.fromInt(1 * TokenUnit.G_WEI); // 1Gwei, TODO 写死1GWEI
      var hynQuotePrice = QuotesInheritedModel.of(context)
              .activatedQuoteVoAndSign('HYN')
              ?.quoteVo
              ?.price ??
          0;
      var gasLimit = SettingInheritedModel.ofConfig(context)
          .systemConfigEntity
          .ethTransferGasLimit;
      var gasPriceEstimate = ConvertTokenUnit.weiToEther(
          weiBigInt: BigInt.parse(
              (gasPrice * Decimal.fromInt(gasLimit)).toStringAsFixed(0)));
      _gasPriceEstimate =
          gasPriceEstimate * Decimal.parse(hynQuotePrice.toString());
      _gasPriceEstimateStr =
          '${(gasPrice / Decimal.fromInt(TokenUnit.G_WEI)).toStringAsFixed(1)} G_DUST (≈ $_quoteSign${FormatUtil.formatCoinNum(_gasPriceEstimate.toDouble())})';
    } else {
      var ethQuotePrice = QuotesInheritedModel.of(context)
              .activatedQuoteVoAndSign('ETH')
              ?.quoteVo
              ?.price ??
          0;
      gasPriceRecommend =
          QuotesInheritedModel.of(context, aspect: QuotesAspect.gasPrice)
              .gasPriceRecommend;
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

      _gasPriceEstimate = gasEstimate * Decimal.parse(ethQuotePrice.toString());

      _gasPriceEstimateStr =
          "${(gasPrice / Decimal.fromInt(TokenUnit.G_WEI)).toStringAsFixed(1)} GWEI (≈ $_quoteSign${FormatUtil.formatPrice(_gasPriceEstimate.toDouble())})";
    }

    ///Actual withdrawFee:
    ///[withdrawFeeByGas] * _gasPriceEstimate
    _gasPriceEstimate =
        Decimal.parse(widget.withdrawFeeByGas) * _gasPriceEstimate;

    var _gasPriceByToken = FormatUtil.truncateDoubleNum(
        _gasPriceEstimate.toDouble() / _quotePrice, 8);

    _gasPriceEstimateStr =
        " $_gasPriceByToken ${widget.coinVo.symbol} (≈ $_quoteSign${_gasPriceEstimate.toDouble()})";

    var _actualAmount = Decimal.parse(widget.amount) -
        Decimal.parse(_gasPriceByToken.toString());

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
                          style:
                              TextStyle(color: Color(0xFF9B9B9B), fontSize: 14),
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
                                "(${shortBlockChainAddress(widget.coinVo.address)})",
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(
                height: 2,
              ),
            ),
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerLeft,
                          height: 24,
                          child: Text(
                            _gasPriceEstimateStr,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF333333),
                              fontWeight: FontWeight.bold,
                            ),
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
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(
                height: 2,
              ),
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
            Divider(
              height: 2,
            ),
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
                onPressed: isTransferring
                    ? null
                    : () async {
                        await _transfer(
                          _actualAmount.toString(),
                          _gasPriceByToken,
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
  }

  Future _transfer(String actualAmount, String gasFee) async {
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
      Application.router.navigateTo(
        context,
        Routes.exchange_transfer_success_page,
      );
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
