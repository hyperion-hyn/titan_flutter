import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/model.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/vo/coin_vo.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/config/extends_icon_font.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';
import 'api/hyn_api.dart';

class WalletSendConfirmPage extends StatefulWidget {
  final CoinVo coinVo;
  final String transferAmount;
  final String receiverAddress;

  WalletSendConfirmPage(String coinVo, this.transferAmount, this.receiverAddress)
      : coinVo = CoinVo.fromJson(FluroConvertUtils.string2map(coinVo));

  @override
  State<StatefulWidget> createState() {
    return _WalletSendConfirmState();
  }
}

class _WalletSendConfirmState extends BaseState<WalletSendConfirmPage> {
  final TextEditingController _gasPriceController = TextEditingController();
  final TextEditingController _nonceController = TextEditingController();

  final _gasPriceFormKey = GlobalKey<FormState>();
  final _nonceFormKey = GlobalKey<FormState>();

  final StreamController<String> _inputController = StreamController.broadcast();

  double ethFee = 0.0;
  double currencyFee = 0.0;

  var isTransferring = false;
  var isLoadingGasFee = false;

  int selectedPriceLevel = 1;

  WalletVo activatedWallet;
  ActiveQuoteVoAndSign activatedQuoteSign;
  var gasPriceRecommend;

  int get _nonce {
    return int.tryParse(_nonceController.text) ?? null;
  }

  Decimal get _gasPrice {
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
      case 3:
        var inputValue = int.tryParse(_gasPriceController?.text ?? '0') ?? 0;
        return Decimal.fromInt(inputValue * TokenUnit.G_WEI);

      default:
        return gasPriceRecommend.average;
    }
  }

  String get _gasPriceEstimateStr {
    var gasPriceEstimateStr = '';
    var quotePrice = activatedQuoteSign?.quoteVo?.price ?? 0;
    var quoteSign = activatedQuoteSign?.sign?.sign;

    // BTC
    if (widget.coinVo.coinType == CoinType.BITCOIN) {
      var fees = ConvertTokenUnit.weiToDecimal(
          BigInt.parse((_gasPrice * Decimal.fromInt(BitcoinConst.BTC_RAWTX_SIZE)).toString()), 8);
      var gasPriceEstimate = fees * Decimal.parse(quotePrice.toString());
      gasPriceEstimateStr = "$fees BTC (≈ $quoteSign${FormatUtil.formatPrice(gasPriceEstimate.toDouble())})";
    }
    // 2.ETH
    else if (widget.coinVo.coinType == CoinType.ETHEREUM) {
      var ethQuotePrice = WalletInheritedModel.of(context).activatedQuoteVoAndSign('ETH')?.quoteVo?.price ?? 0;
      var gasLimit = widget.coinVo.symbol == "ETH"
          ? SettingInheritedModel.ofConfig(context).systemConfigEntity.ethTransferGasLimit
          : SettingInheritedModel.ofConfig(context).systemConfigEntity.erc20TransferGasLimit;
      var gasEstimate = ConvertTokenUnit.weiToEther(
          weiBigInt: BigInt.parse((_gasPrice * Decimal.fromInt(gasLimit)).toStringAsFixed(0)));
      var gasPriceEstimate = gasEstimate * Decimal.parse(ethQuotePrice.toString());
      gasPriceEstimateStr =
          "${(_gasPrice / Decimal.fromInt(TokenUnit.G_WEI)).toStringAsFixed(1)} GWEI (≈ ${quoteSign ?? ""}${FormatUtil.formatPrice(gasPriceEstimate.toDouble())})";
    }
    // 3.ATLAS
    else if (widget.coinVo.coinType == CoinType.HYN_ATLAS) {
      // var gasPrice = Decimal.fromInt(1 * TokenUnit.G_WEI); // 1Gwei, TODO 写死1GWEI
      var hynQuotePrice = WalletInheritedModel.of(context).activatedQuoteVoAndSign('HYN')?.quoteVo?.price ?? 0;
      var gasLimit = SettingInheritedModel.ofConfig(context).systemConfigEntity.ethTransferGasLimit;
      var gasEstimate = ConvertTokenUnit.weiToEther(
          weiBigInt: BigInt.parse((_gasPrice * Decimal.fromInt(gasLimit)).toStringAsFixed(0)));
      var gasPriceEstimate = gasEstimate * Decimal.parse(hynQuotePrice.toString());
      gasPriceEstimateStr =
          '${(_gasPrice / Decimal.fromInt(TokenUnit.G_WEI)).toStringAsFixed(1)} G_DUST (≈ ${quoteSign ?? ""}${FormatUtil.formatCoinNum(gasPriceEstimate.toDouble())})';
    }

    return gasPriceEstimateStr;
  }

  @override
  void initState() {
    super.initState();

    BlocProvider.of<WalletCmpBloc>(context).add(UpdateGasPriceEvent());
  }

  @override
  void dispose() {
    print("[${widget.runtimeType}] dispose");

    _inputController.close();

    super.dispose();
  }

  @override
  void onCreated() {
    activatedQuoteSign = WalletInheritedModel.of(context).activatedQuoteVoAndSign(widget.coinVo.symbol);

    activatedWallet = WalletInheritedModel.of(context).activatedWallet;

    if (widget.coinVo.coinType == CoinType.BITCOIN) {
      gasPriceRecommend = WalletInheritedModel.of(context, aspect: WalletAspect.gasPrice).btcGasPriceRecommend;
    } else {
      gasPriceRecommend = WalletInheritedModel.of(context, aspect: WalletAspect.gasPrice).gasPriceRecommend;
    }

    _speedOnTap(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(
        baseTitle: S.of(context).transfer_confirm,
        backgroundColor: Colors.white,
      ),
      body: BaseGestureDetector(
        context: context,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _totalWidget(),
              _transferWidget(),
              _gasWidget(),
              _sendWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _totalWidget() {
    var quoteSign = activatedQuoteSign?.sign?.sign;
    var quotePrice = activatedQuoteSign?.quoteVo?.price ?? 0;

    return Row(
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
                  "≈ ${quoteSign ?? ""}${FormatUtil.formatPrice(double.parse(widget.transferAmount) * quotePrice)}",
                  style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 14),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _transferWidget() {
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
                            "${activatedWallet.wallet.keystore.name}",
                            style: TextStyle(fontSize: 14, color: Color(0xFF333333), fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          ),
                          Text(
                            "(${shortBlockChainAddress(WalletUtil.formatToHynAddrIfAtlasChain(
                              widget.coinVo,
                              widget.coinVo.address,
                            ))})",
                            style: TextStyle(fontSize: 14, color: Color(0xFF999999), fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          )
                        ],
                      ))
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
                      child: Text(
                        '${shortBlockChainAddress(WalletUtil.formatToHynAddrIfAtlasChain(
                          widget.coinVo,
                          widget.receiverAddress,
                        ))}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF333333),
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
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

  Widget _sendWidget() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 36, horizontal: 36),
      constraints: BoxConstraints.expand(height: 48),
      child: RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        disabledColor: Colors.grey[600],
        color: Theme.of(context).primaryColor,
        textColor: Colors.white,
        disabledTextColor: Colors.white,
        onPressed: isTransferring ? null : _transferAction,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                isTransferring ? S.of(context).please_waiting : S.of(context).send,
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gasWidget() {
    List<Widget> children = [];

    Widget _item({int index, String title, String waite, BorderRadiusGeometry borderRadius}) {
      return Expanded(
        child: InkWell(
          onTap: () {
            _speedOnTap(index);
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 4),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selectedPriceLevel == index ? Colors.grey : Colors.grey[200],
              borderRadius: borderRadius,
            ),
            child: Column(
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(color: selectedPriceLevel == index ? Colors.white : Colors.black, fontSize: 12),
                ),
                Text(
                  waite,
                  style: TextStyle(fontSize: 10, color: Colors.black38),
                )
              ],
            ),
          ),
        ),
      );
    }

    Widget _divider() {
      return VerticalDivider(
        width: 1,
        thickness: 2,
      );
    }

    // 1.BTC
    if (widget.coinVo.coinType == CoinType.BITCOIN) {
      children = [
        _item(
          index: 0,
          title: S.of(context).speed_slow,
          waite: S.of(context).wait_min(gasPriceRecommend.safeLowWait.toString()),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30)),
        ),
        _divider(),
        _item(
          index: 1,
          title: S.of(context).speed_normal,
          waite: S.of(context).wait_min(gasPriceRecommend.avgWait.toString()),
          borderRadius: BorderRadius.all(Radius.circular(0)),
        ),
        _divider(),
        _item(
          index: 2,
          title: S.of(context).speed_fast,
          waite: S.of(context).wait_min(gasPriceRecommend.fastWait.toString()),
          borderRadius: BorderRadius.only(topRight: Radius.circular(30), bottomRight: Radius.circular(30)),
        ),
      ];
    }
    // 2.ETH
    else if (widget.coinVo.coinType == CoinType.ETHEREUM) {
      children = [
        _item(
          index: 0,
          title: S.of(context).speed_slow,
          waite: S.of(context).wait_min(gasPriceRecommend.safeLowWait.toString()),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30)),
        ),
        _divider(),
        _item(
          index: 1,
          title: S.of(context).speed_normal,
          waite: S.of(context).wait_min(gasPriceRecommend.avgWait.toString()),
          borderRadius: BorderRadius.all(Radius.circular(0)),
        ),
        _divider(),
        _item(
          index: 2,
          title: S.of(context).speed_fast,
          waite: S.of(context).wait_min(gasPriceRecommend.fastWait.toString()),
          borderRadius: BorderRadius.all(Radius.circular(0)),
        ),
        _divider(),
        _item(
          index: 3,
          title: '自定义',
          waite: '',
          borderRadius: BorderRadius.only(topRight: Radius.circular(30), bottomRight: Radius.circular(30)),
        ),
      ];
    }

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              '${S.of(context).gas_fee}(${widget.coinVo.coinType == CoinType.HYN_ATLAS ? 'HYN' : widget.coinVo.symbol.toUpperCase()})',
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
                StreamBuilder<Object>(
                    stream: _inputController.stream,
                    builder: (context, snapshot) {
                      return Container(
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
                      );
                    }),
                if (isLoadingGasFee)
                  Container(
                    width: 24,
                    height: 24,
                    child: CupertinoActivityIndicator(),
                  )
              ],
            ),
          ),
          if (widget.coinVo.coinType == CoinType.ETHEREUM || widget.coinVo.coinType == CoinType.BITCOIN)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
              child: Row(
                children: children,
              ),
            ),
          if (widget.coinVo.coinType == CoinType.ETHEREUM && selectedPriceLevel == 3)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _textField(_gasPriceController, "请输入Gas Price", "GWEI", _gasPriceFormKey, 'Gas Price'),
                SizedBox(
                  height: 8,
                ),
                _textField(_nonceController, "请输入 Nonce（可选）", "", _nonceFormKey, 'Nonce 值'),
              ],
            ),
        ],
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String hintText,
    String suffixText,
    Key key,
    String title,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
      child: Row(
        children: <Widget>[
          Text(
            title,
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Form(
              key: key,
              child: TextFormField(
                controller: controller,
                validator: (textStr) {
                  if (controller == _nonceController) {
                    return null;
                  }
                  if (_gasPrice == null || _gasPrice == Decimal.zero) {
                    return '请输入Gas Price';
                  }

                  if (gasPriceRecommend.safeLow > _gasPrice) {
                    return 'Gas Price过低，将会影响交易确认时间';
                  }

                  if (_gasPrice > gasPriceRecommend.fast) {
                    return 'Gas Price过高，将会造成矿工费浪费';
                  }

                  return null;
                },
                onChanged: (String inputText) {
                  //print('[add] --> onChanged, inputText:$inputText');

                  _gasPriceFormKey.currentState.validate();

                  _inputController.add(inputText);
                },
                onEditingComplete: () {
                  //_onEditingComplete();
                },
                onFieldSubmitted: (String inputText) {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                style: TextStyle(fontSize: 16),
                cursorColor: Theme.of(context).primaryColor,
                //光标圆角
                cursorRadius: Radius.circular(5),
                //光标宽度
                cursorWidth: 1.8,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hintText,
                  suffixIcon: SizedBox(
                    child: Center(
                      widthFactor: 0.0,
                      child: Text(
                        suffixText,
                        style: TextStyle(color: Colors.grey[300]),
                      ),
                    ),
                  ),
                  errorStyle: TextStyle(fontSize: 14, color: Colors.blue[300]),
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey[300]),
                  errorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(width: 0.5, color: Colors.blue, style: BorderStyle.solid)),
                  focusedErrorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(width: 0.5, color: Colors.blue, style: BorderStyle.solid)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(width: 0.5, color: Colors.blue, style: BorderStyle.solid)),
                  // //输入框启用时，下划线的样式
                  disabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(width: 0.5, color: Colors.blue, style: BorderStyle.solid)),
                  //输入框启用时，下划线的样式
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(width: 0.5, color: Colors.blue, style: BorderStyle.solid)), //输入框启用时，下划线的样式
                ),
                // keyboardType: TextInputType.number,
                keyboardType: TextInputType.numberWithOptions(decimal: false),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(controller == _nonceController ? 18 : 8),
                  FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _speedOnTap(int index) {
    setState(() {
      selectedPriceLevel = index;
    });
  }

  Future _transferAction() async {
    if (selectedPriceLevel == 3 && !_gasPriceFormKey.currentState.validate()) {
      return;
    }

    var walletPassword = await UiUtil.showWalletPasswordDialogV2(
      context,
      activatedWallet.wallet,
    );

    if (walletPassword == null) {
      return;
    }

    try {
      setState(() {
        isTransferring = true;
      });

      // 1.BTC
      if (widget.coinVo.coinType == CoinType.ETHEREUM) {
        if (widget.coinVo.contractAddress != null) {
          var txHash = await _transferErc20(
              walletPassword,
              ConvertTokenUnit.strToBigInt(widget.transferAmount, widget.coinVo.decimals),
              widget.receiverAddress,
              activatedWallet.wallet);
          if (txHash == null) {
            setState(() {
              isTransferring = false;
            });
            return;
          }
        } else {
          await _transferEth(
              walletPassword,
              ConvertTokenUnit.strToBigInt(widget.transferAmount, widget.coinVo.decimals),
              widget.receiverAddress,
              activatedWallet.wallet);
        }
      }
      // 2.ETH
      else if (widget.coinVo.coinType == CoinType.BITCOIN) {
        var activatedWalletVo = activatedWallet.wallet;
        var transResult = await activatedWalletVo.sendBitcoinTransaction(
            walletPassword,
            activatedWalletVo.getBitcoinZPub(),
            widget.receiverAddress,
            _gasPrice.toInt(),
            ConvertTokenUnit.decimalToWei(Decimal.parse(widget.transferAmount), 8).toInt());
        if (transResult["code"] != 0) {
          LogUtil.uploadException(transResult, "bitcoin upload");
          Fluttertoast.showToast(msg: "${transResult.toString()}", toastLength: Toast.LENGTH_LONG);
          return;
        }
      }
      // 3.ATLAS
      else if (widget.coinVo.coinType == CoinType.HYN_ATLAS) {
        if (widget.coinVo.contractAddress != null) {
          var txHash = await HYNApi.sendTransferHYNHrc30(
              walletPassword,
              ConvertTokenUnit.strToBigInt(widget.transferAmount, widget.coinVo.decimals),
              widget.receiverAddress,
              activatedWallet.wallet,
              widget.coinVo.contractAddress);
          if (txHash == null) {
            setState(() {
              isTransferring = false;
            });
            return;
          }
        } else {
          await HYNApi.sendTransferHYN(
            walletPassword,
            activatedWallet.wallet,
            toAddress: widget.receiverAddress,
            amount: ConvertTokenUnit.strToBigInt(widget.transferAmount, widget.coinVo.decimals),
          );
        }
      }
      // 3.ERC20
      else {
        var txHash = await _transferErc20(
          walletPassword,
          ConvertTokenUnit.strToBigInt(
            widget.transferAmount,
            widget.coinVo.decimals,
          ),
          widget.receiverAddress,
          activatedWallet.wallet,
        );
        if (txHash == null) {
          setState(() {
            isTransferring = false;
          });
          return;
        }
      }

      var msg;
      if (widget.coinVo.coinType == CoinType.HYN_ATLAS) {
        msg = S.of(context).transfer_message_broadcast_wait_six_seconds;
      } else {
        msg = S.of(context).transfer_broadcase_success_description;
      }
      msg = FluroConvertUtils.fluroCnParamsEncode(msg);
      Application.router.navigateTo(context, Routes.confirm_success_papge + '?msg=$msg');
    } catch (_) {
      LogUtil.toastException(_);
      setState(() {
        isTransferring = false;
      });
    }
  }

  Future _transferEth(
    String password,
    BigInt amount,
    String toAddress,
    Wallet wallet,
  ) async {
    print('[HYN] _transferErc20，_gasPrice $_gasPrice,  _nonce:$_nonce');

    final txHash = await wallet.sendEthTransaction(
      password: password,
      gasPrice: BigInt.parse(_gasPrice.toStringAsFixed(0)),
      value: amount,
      toAddress: toAddress,
      nonce: _nonce,
    );

    logger.i('ETH transaction committed，txhash $txHash');
  }

  Future<String> _transferErc20(
    String password,
    BigInt amount,
    String toAddress,
    Wallet wallet,
  ) async {
    var contractAddress = widget.coinVo.contractAddress;
    print('[HYN] _transferErc20，_gasPrice $_gasPrice,  _nonce:$_nonce');

    final txHash = await wallet.sendErc20Transaction(
      contractAddress: contractAddress,
      password: password,
      gasPrice: BigInt.parse(_gasPrice.toStringAsFixed(0)),
      value: amount,
      toAddress: toAddress,
      nonce: _nonce,
    );

    logger.i('HYN transaction committed，txhash $txHash ');
    return txHash;
  }
}
