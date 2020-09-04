import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/exchange/exchange_component.dart';
import 'package:titan/src/components/quotes/bloc/bloc.dart';
import 'package:titan/src/components/quotes/model.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/wallet/vo/coin_vo.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/config/extends_icon_font.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';

class ExchangeWithdrawConfirmPage extends StatefulWidget {
  final CoinVo coinVo;
  final String transferAmount;

  ExchangeWithdrawConfirmPage(
    String coinVo,
    this.transferAmount,
  ) : coinVo = CoinVo.fromJson(FluroConvertUtils.string2map(coinVo));

  @override
  State<StatefulWidget> createState() {
    return _ExchangeWithdrawConfirmPageState();
  }
}

class _ExchangeWithdrawConfirmPageState
    extends BaseState<ExchangeWithdrawConfirmPage> {
  double ethFee = 0.0;
  double currencyFee = 0.0;
  var isTransferring = false;

  int selectedPriceLevel = 1;

  WalletVo activatedWallet;
  ActiveQuoteVoAndSign activatedQuoteSign;
  ExchangeApi _exchangeApi = ExchangeApi();

  @override
  void onCreated() {
    activatedQuoteSign = QuotesInheritedModel.of(context)
        .activatedQuoteVoAndSign(widget.coinVo.symbol);
    activatedWallet = WalletInheritedModel.of(context).activatedWallet;
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<QuotesCmpBloc>(context).add(UpdateGasPriceEvent());
  }

  @override
  Widget build(BuildContext context) {
    var _quotePrice = activatedQuoteSign?.quoteVo?.price ?? 0;
    var _quoteSign = activatedQuoteSign?.sign?.sign;
    var _withdrawFee = ExchangeInheritedModel.of(context)
            .exchangeModel
            .activeAccount
            .assetList
            .getWithdrawFee(widget.coinVo.symbol) ??
        '0';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        title: Text(
          '划转确认',
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
                            "-${widget.transferAmount} ${widget.coinVo.symbol}",
                            style: TextStyle(
                                color: Color(0xFF252525),
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        ),
                        Text(
                          "≈ $_quoteSign${FormatUtil.formatPrice(double.parse(widget.transferAmount) * _quotePrice)}",
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
                          "From",
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
                                '交易账户',
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
                          "To",
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
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          "手续费",
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
                                '$_withdrawFee ${widget.coinVo.symbol}',
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
                          "实际到账",
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
                                '${Decimal.parse(widget.transferAmount) - Decimal.parse(_withdrawFee)} ${widget.coinVo.symbol}',
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
                onPressed: isTransferring ? null : _transfer,
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

  Future _transfer() async {
    var walletPassword = await UiUtil.showWalletPasswordDialogV2(
      context,
      activatedWallet.wallet,
    );

    _transferWithPwd(walletPassword);
  }

  _transferWithPwd(String walletPassword) async {
    try {
      var ret = await _exchangeApi.withdraw(
        activatedWallet.wallet,
        walletPassword,
        activatedWallet.wallet.getEthAccount().address,
        widget.coinVo.symbol,
        widget.coinVo.address,
        widget.transferAmount,
      );
      print('$ret');
    } catch (e) {}
  }
}
