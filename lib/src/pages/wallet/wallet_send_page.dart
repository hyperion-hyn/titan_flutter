import 'dart:math';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/vo/coin_view_vo.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/config/ethereum.dart';
import 'package:titan/src/plugins/wallet/config/tokens.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/config/extends_icon_font.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';

import '../../global.dart';

class WalletSendPage extends StatefulWidget {
  final CoinViewVo coinVo;
  final String toAddress;

  WalletSendPage(String coinVo, [String toAddress])
      : this.coinVo = CoinViewVo.fromJson(FluroConvertUtils.string2map(coinVo)),
        this.toAddress = toAddress;

  @override
  State<StatefulWidget> createState() {
    return _WalletSendState();
  }
}

class _WalletSendState extends BaseState<WalletSendPage> {
  final TextEditingController _receiverAddressController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  final _fromKey = GlobalKey<FormState>();
  double _notionalValue = 0;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      if (_amountController.text.trim() != null && _amountController.text.trim().length > 0) {
        var inputAmount = _amountController.text.trim();
        var activatedQuoteSign = WalletInheritedModel.of(context).tokenLegalPrice(widget.coinVo.symbol);
        var quotePrice = activatedQuoteSign?.price ?? 0;
        setState(() {
          _notionalValue = double.parse(inputAmount) * quotePrice;
        });
      }
    });
    if (widget.toAddress != null) {
      _receiverAddressController.text = widget.toAddress;
    }
  }

  @override
  void onCreated() {
    BlocProvider.of<WalletCmpBloc>(context).add(UpdateActivatedWalletBalanceEvent());
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var activatedQuoteSign = WalletInheritedModel.of(context).tokenLegalPrice(widget.coinVo.symbol);
    var activatedWallet = WalletInheritedModel.of(context).activatedWallet;
    var quotePrice = activatedQuoteSign?.price ?? 0;
    var quoteSign = activatedQuoteSign?.legal?.legal;

    var addressHint = "";
    RegExp _basicAddressReg = RegExp(r'^([13]|bc)[a-zA-Z0-9]{25,42}$', caseSensitive: false);
    String addressErrorHint = "";
    if (widget.coinVo.coinType == CoinType.BITCOIN) {
      _basicAddressReg = RegExp(r'^([13]|bc)[a-zA-Z0-9]{25,42}$', caseSensitive: false);
      addressHint = S.of(context).example + ': bc1q7fhqwluhcrs2ek...';
      addressErrorHint = S.of(context).legal_address_starting_1_or_bc_or_3;
    } else {
      _basicAddressReg = RegExp(r'^(0x)?[0-9a-f]{40}', caseSensitive: false);
      var addressExample = widget.coinVo.coinType == CoinType.HYN_ATLAS ? 'hyn1ntjklkvx9jlkrz9' : '0x81e7A0529AC1726e';
      addressHint = S.of(context).example + ': $addressExample...';
      addressErrorHint = S.of(context).input_valid_address;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(
        baseTitle: S.of(context).send_symbol(widget.coinVo.symbol),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 32),
        child: SingleChildScrollView(
          child: BaseGestureDetector(
            context: context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Form(
                  key: _fromKey,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            S.of(context).receiver_address,
                            style: TextStyle(color: Color(0xFF333333), fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          Spacer(),
                          InkWell(
                            onTap: onPaste,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Image.asset(
                                'res/drawable/ic_copy.png',
                                height: 23,
                                width: 23,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async{
                              UiUtil.showScanImagePickerSheet(context, callback: (String text) {
                                _parseText(quotePrice, text);
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Icon(
                                ExtendsIconFont.qrcode_scan,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                        child: TextFormField(
                            validator: (value) {
                              var address = widget.coinVo.coinType == CoinType.HYN_ATLAS
                                  ? WalletUtil.bech32ToEthAddress(value)
                                  : value;
                              if (address.isEmpty) {
                                return S.of(context).receiver_address_not_empty_hint;
                              } else if (widget.coinVo.coinType == CoinType.HYN_ATLAS && !value.startsWith('hyn1')) {
                                return addressErrorHint;
                              } else if (!_basicAddressReg.hasMatch(address)) {
                                return addressErrorHint;
                              } else if (((activatedWallet?.wallet?.getAtlasAccount()?.address ?? null) != null)
                                  && ((WalletUtil.ethAddressToBech32Address(activatedWallet.wallet.getAtlasAccount().address) == value)
                                      ||(activatedWallet.wallet.getAtlasAccount().address == value))) {
                                return S.of(context).cant_transfer_myself;
                              }
                              return null;
                            },
                            controller: _receiverAddressController,
                            decoration: InputDecoration(
                              hintText: addressHint,
                              hintStyle: TextStyle(
                                color: HexColor('#FF999999'),
                                fontSize: 13,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                  color: HexColor('#FFD0D0D0'),
                                  width: 0.5,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                  color: HexColor('#FFD0D0D0'),
                                  width: 0.5,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                  color: HexColor('#FFD0D0D0'),
                                  width: 0.5,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 0.5,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            keyboardType: TextInputType.text),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            S.of(context).send_count_label(widget.coinVo.symbol),
                            style: TextStyle(color: Color(0xFF333333), fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '(' + S.of(context).can_use + ' ${FormatUtil.coinBalanceHumanReadFormat(widget.coinVo)})',
                            style: TextStyle(fontSize: 12, color: Colors.black38),
                          ),
                          Spacer(),
                          InkWell(
                            onTap: () {
                              _amountController.text = FormatUtil.coinBalanceHumanRead(widget.coinVo);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                              child: Text(
                                S.of(context).all,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    textBaseline: TextBaseline.ideographic),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                        child: TextFormField(
                          validator: (value) {
                            value = value.trim();
                            if (value == "0") {
                              return S.of(context).input_corrent_count_hint;
                            }
                            if (!RegExp(r"\d+(\.\d+)?$").hasMatch(value)) {
                              return S.of(context).input_corrent_count_hint;
                            }
                            if (Decimal.parse(value) > Decimal.parse(FormatUtil.coinBalanceHumanRead(widget.coinVo))) {
                              return S.of(context).input_count_over_balance;
                            }
                            if (value.contains(".") && value.split(".")[1].length > widget.coinVo.decimals) {
                              return "超过${widget.coinVo.decimals}位最大小数位";
                            }
                            return null;
                          },
                          controller: _amountController,
                          decoration: InputDecoration(
                            hintText: S.of(context).input_transfer_num,
                            hintStyle: TextStyle(
                              color: HexColor('#FF999999'),
                              fontSize: 13,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: HexColor('#FFD0D0D0'),
                                width: 0.5,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: HexColor('#FFD0D0D0'),
                                width: 0.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: HexColor('#FFD0D0D0'),
                                width: 0.5,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 0.5,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
//                        onChanged: (value) {
//                          setState(() {
//                            _notionalValue = double.parse(value) * quotePrice;
//                          });
//                        },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(left: 8, top: 8),
                              child: Text(
                                "≈ ${quoteSign ?? ""}${FormatUtil.formatPrice(_notionalValue)}",
                                style: TextStyle(
                                  color: Color(0xFF9B9B9B),
                                ),
                              )),
                        ],
                      ),
                      SizedBox(
                        height: 12,
                      ),
                    ],
                  ),
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
                    onPressed: widget.coinVo == null ? null : submit,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            S.of(context).next,
                            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void submit() {
    if (_fromKey.currentState.validate()) {
      var amountTrim = _amountController.text.trim();
      var count = double.parse(amountTrim);
      if (count <= 0) {
        Fluttertoast.showToast(msg: S.of(context).transfer_num_bigger_zero);
        return;
      }

      var symbol = widget.coinVo.symbol.toUpperCase();

      // todo: HRC30不需要预留币
      if (widget.coinVo.coinType == CoinType.HYN_ATLAS && symbol == SupportedTokens.HYN_Atlas.symbol) {

        var balance = Decimal.parse(
          FormatUtil.coinBalanceDouble(
            widget.coinVo,
          ).toString(),
        );

        var estimateGas = ConvertTokenUnit.weiToEther(
            weiBigInt: BigInt.parse(
          (1 * EthereumUnitValue.G_WEI * 21000).toString(),
        ));

        if (balance - estimateGas < Decimal.parse(amountTrim)) {
          amountTrim = (Decimal.parse(amountTrim) - estimateGas).toString();
        }
      }

      var voStr = FluroConvertUtils.object2string(widget.coinVo.toJson());
      Application.router.navigateTo(
          context,
          Routes.wallet_transfer_token_confirm +
              "?coinVo=$voStr&transferAmount=$amountTrim&receiverAddress=${widget.coinVo.coinType == CoinType.HYN_ATLAS ? WalletUtil.bech32ToEthAddress(_receiverAddressController.text) : _receiverAddressController.text}");
    }
  }

  Future _parseText(double price , String barcode) async {

    try {

      if (barcode.contains("ethereum")) {
        //imtoken style address
        var barcodeArray = barcode.split("?");
        var withAddress = barcodeArray[0];
        var address = withAddress.replaceAll("ethereum:", "");
        _receiverAddressController.text = address;

        //handle params
        if (barcodeArray.length > 1) {
          var withValue = barcodeArray[1];
          var valuesArray = withValue.split("&");
          var valueMap = Map();
          valuesArray.forEach((valueStringTemp) {
            var keyValueArray = valueStringTemp.split("=");
            valueMap[keyValueArray[0]] = keyValueArray[1];
          });
          var value = valueMap["value"];
          var decimal = valueMap["decimal"];
          if (value != null && decimal != null && double.parse(value) > 0) {
            var transferSize = (double.parse(value) / (pow(10, int.parse(decimal))));
            _amountController.text = transferSize.toString();
            setState(() {
              _notionalValue = transferSize * price;
            });
          }
        }
      } else if (barcode.contains("bitcoin")) {
        var barcodeArray = barcode.split("?");
        var withAddress = barcodeArray[0];
        var address = withAddress.replaceAll("bitcoin:", "");
        _receiverAddressController.text = address;
      } else {
        _receiverAddressController.text = barcode;
      }
    } catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        Fluttertoast.showToast(msg: S.of(context).open_camera, toastLength: Toast.LENGTH_SHORT);
      } else {
        logger.e(e);
        _receiverAddressController.text = "";
      }
    }
  }

  Future onPaste() async {
    var text = await Clipboard.getData(Clipboard.kTextPlain);
    if (text == null) {
      return;
    }
    _receiverAddressController.text = text.text;
  }
}
