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
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/vo/token_price_view_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/vo/coin_view_vo.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/pages/wallet/wallet_gas_setting_page.dart';
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
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

import '../../global.dart';

class WalletSendPageV2 extends StatefulWidget {
  final CoinViewVo coinVo;
  final String toAddress;

  WalletSendPageV2(String coinVo, [String toAddress])
      : this.coinVo = CoinViewVo.fromJson(FluroConvertUtils.string2map(coinVo)),
        this.toAddress = toAddress;

  @override
  State<StatefulWidget> createState() {
    return _WalletSendStateV2();
  }
}

class _WalletSendStateV2 extends BaseState<WalletSendPageV2> with RouteAware {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _nonceController = TextEditingController();
  // final TextEditingController _dateController = TextEditingController();

  final _toKey = GlobalKey<FormState>();
  final _amountKey = GlobalKey<FormState>();
  final _nonceKey = GlobalKey<FormState>();
  // final _dateKey = GlobalKey<FormState>();

  int get _nonce {
    return int.tryParse(_nonceController.text) ?? null;
  }

  double _notionalValue = 0;
  bool _isHighLevel = false;

  bool get _isCustom => _selectedIndex == -1;
  bool get _isBTC => (widget.coinVo.coinType == CoinType.BITCOIN);

  int _selectedIndex = 0;
  List<GasPriceRecommendModel> _dataList = [];

  TokenPriceViewVo _activatedQuoteSign;
  var _gasPriceRecommend;

  int get _defaultGasLimit {
    var defaultValue = widget.coinVo.symbol == "ETH"
        ? SettingInheritedModel.ofConfig(context).systemConfigEntity.ethTransferGasLimit
        : SettingInheritedModel.ofConfig(context).systemConfigEntity.erc20TransferGasLimit;

    defaultValue = SettingInheritedModel.ofConfig(context).systemConfigEntity.erc20ApproveGasLimit;

    return defaultValue;
  }

  String _lastGasSat;
  String _lastGasPrice;
  String _lastGasLimit;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      if (_amountController.text.trim() != null && _amountController.text.trim().length > 0) {
        var inputAmount = _amountController.text.trim();
        var activatedQuoteSign =
            WalletInheritedModel.of(context).tokenLegalPrice(widget.coinVo.symbol);
        var quotePrice = activatedQuoteSign?.price ?? 0;
        setState(() {
          _notionalValue = double.parse(inputAmount) * quotePrice;
        });
      }
    });
    if (widget.toAddress != null) {
      _toController.text = widget.toAddress;
    }
  }

  @override
  void onCreated() {
    _setupDataList();

    _initLastData();

    Application.routeObserver.subscribe(this, ModalRoute.of(context));

    BlocProvider.of<WalletCmpBloc>(context).add(UpdateActivatedWalletBalanceEvent());
  }

  @override
  void didPopNext() {
    _initLastData();

    super.didPopNext();
  }

  @override
  void dispose() {
    Application.routeObserver.unsubscribe(this);
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#F6F6F6'),
      appBar: BaseAppBar(
        baseTitle: '${widget.coinVo.symbol}转账',
        backgroundColor: HexColor('#F6F6F6'),
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 24,
                top: 18,
              ),
              child: Column(
                children: <Widget>[
                  _toWidget(),
                  _amountWidget(),
                  _gasWidget(),
                  _highWidget(),
                ],
              ),
            ),
          ),
        ),
        _confirmButtonWidget(),
      ],
    );
  }

  Widget _toWidget() {
    return Container(
      child: Column(
        children: [
          Row(
            children: <Widget>[
              Text(
                '收款地址',
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          _clipRectWidget(
            child: _toEditWidget(),
            paddingV: 4,
          ),
        ],
      ),
    );
  }

  Widget _amountWidget() {
    return Container(
      child: Column(
        children: [
          SizedBox(
            height: 12,
          ),
          Row(
            children: <Widget>[
              Text(
                '金额',
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Spacer(),
              Text(
                '可用 ' +
                    FormatUtil.coinBalanceHumanReadFormat(widget.coinVo) +
                    ' ${widget.coinVo.symbol.toUpperCase()}',
                style: TextStyle(
                  color: Color(0xFFaaaaaa),
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          _clipRectWidget(
            child: _amountEditWidget(),
            paddingV: 12,
          ),
        ],
      ),
    );
  }

  Widget _gasWidget() {
    var quoteSign = _activatedQuoteSign?.legal?.sign;

    var coinType = widget.coinVo.coinType;

    var gasPriceEstimateStr = '';

    var baseUnit = widget.coinVo.symbol;
    var fees;

    var selectedGasPrice = _dataList[_isCustom ? 0 : _selectedIndex].gas;
    var gasPrice = selectedGasPrice;
    var gasLimit;

    // 1.BTC
    if (CoinType.BITCOIN == coinType) {
      gasPrice =
          _isCustom ? Decimal?.tryParse(_lastGasSat ?? '0') ?? Decimal.zero : selectedGasPrice;
      gasLimit = 78;
      // gasLimit = BitcoinGasPrice.BTC_RAWTX_SIZE;

      fees = ConvertTokenUnit.weiToDecimal(
          BigInt.parse((gasPrice * Decimal.fromInt(gasLimit)).toString()), 8);

      var btcQuotePrice = WalletInheritedModel.of(context).tokenLegalPrice('BTC')?.price ?? 0;
      var gasPriceEstimate = fees * Decimal.parse(btcQuotePrice.toString());
      gasPriceEstimateStr = "$quoteSign ${FormatUtil.formatPrice(gasPriceEstimate.toDouble())}";
    }
    // 2.ETH
    else if (CoinType.ETHEREUM == coinType) {
      var initGasPrice = selectedGasPrice / Decimal.fromInt(EthereumUnitValue.G_WEI);
      gasPrice = _isCustom ? Decimal?.tryParse(_lastGasPrice ?? '0') ?? initGasPrice : initGasPrice;

      var initGasLimit = Decimal.fromInt(_defaultGasLimit);
      gasLimit = _isCustom ? Decimal?.tryParse(_lastGasLimit ?? '0') ?? initGasLimit : initGasLimit;

      var feesDecimalValue = ConvertTokenUnit.weiToEther(
          weiBigInt: BigInt.parse(
              (gasPrice * gasLimit * Decimal.fromInt(EthereumUnitValue.G_WEI)).toStringAsFixed(0)));
      fees = FormatUtil.formatNumDecimal(feesDecimalValue.toDouble(), decimal: 6);

      var ethQuotePrice = WalletInheritedModel.of(context).tokenLegalPrice('ETH')?.price ?? 0;
      var gasPriceEstimate = feesDecimalValue * Decimal.parse(ethQuotePrice.toString());
      gasPriceEstimateStr =
          "${quoteSign ?? ""}${FormatUtil.formatPrice(gasPriceEstimate.toDouble())}";
    }
    // 3.ATLAS
    else if (widget.coinVo.coinType == CoinType.HYN_ATLAS) {
      gasPrice = Decimal.fromInt(1 * EthereumUnitValue.G_WEI);

      var gasLimit = SettingInheritedModel.ofConfig(context).systemConfigEntity.ethTransferGasLimit;

      var feesDecimalValue = ConvertTokenUnit.weiToEther(
          weiBigInt: BigInt.parse((gasPrice * Decimal.fromInt(gasLimit)).toStringAsFixed(0)));

      fees = FormatUtil.formatNumDecimal(feesDecimalValue.toDouble(), decimal: 6);

      var hynQuotePrice = WalletInheritedModel.of(context).tokenLegalPrice('HYN')?.price ?? 0;
      var gasPriceEstimate = feesDecimalValue * Decimal.parse(hynQuotePrice.toString());
      gasPriceEstimateStr =
          '${quoteSign ?? ""} ${FormatUtil.formatCoinNum(gasPriceEstimate.toDouble())}';

      baseUnit = 'HYN';
    }
    // 3.HB
    else if (widget.coinVo.coinType == CoinType.HB_HT) {
      gasPrice = Decimal.fromInt(1 * EthereumUnitValue.G_WEI);

      var gasLimit = SettingInheritedModel.ofConfig(context).systemConfigEntity.ethTransferGasLimit;

      var feesDecimalValue = ConvertTokenUnit.weiToEther(
          weiBigInt: BigInt.parse((gasPrice * Decimal.fromInt(gasLimit)).toStringAsFixed(0)));

      fees = FormatUtil.formatNumDecimal(feesDecimalValue.toDouble(), decimal: 6);

      var htQuotePrice = WalletInheritedModel.of(context).tokenLegalPrice('HT')?.price ?? 0;
      var gasPriceEstimate = feesDecimalValue * Decimal.parse(htQuotePrice.toString());
      gasPriceEstimateStr =
          '${quoteSign ?? ""} ${FormatUtil.formatCoinNum(gasPriceEstimate.toDouble())}';

      baseUnit = 'HT';
    }

    var totalFee = '$fees $baseUnit';

    var isBbcOrEth = (CoinType.BITCOIN == coinType || CoinType.ETHEREUM == coinType);

    return _clipRectWidget(
      paddingH: 16,
      paddingV: 10,
      marginV: 0,
      child: InkWell(
        onTap: () {
          if (isBbcOrEth) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WalletGasSettingPage(
                  FluroConvertUtils.object2string(widget.coinVo.toJson()),
                ),
              ),
            );
          }
        },
        child: Row(
          children: [
            Text(
              S.of(context).transfer_gas_fee,
              style: TextStyle(
                color: HexColor('#333333'),
                fontSize: 14,
              ),
            ),
            Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  totalFee,
                  style: TextStyle(
                    color: HexColor('#333333'),
                    fontSize: 12,
                  ),
                ),
                SizedBox(
                  height: 2,
                ),
                Text(
                  gasPriceEstimateStr,
                  style: TextStyle(
                    color: HexColor('#999999'),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            if (isBbcOrEth)
              SizedBox(
                width: 12,
              ),
            if (isBbcOrEth)
              Image.asset(
                'res/drawable/wallet_gas_right.png',
                width: 8,
                height: 8,
              ),
          ],
        ),
      ),
    );
  }

  Widget _highWidget() {
    if (_isBTC) return Container();

    return Container(
      child: Column(
        children: [
          SizedBox(
            height: 30,
          ),
          InkWell(
            onTap: () {
              if (mounted) {
                setState(() {
                  _isHighLevel = !_isHighLevel;
                });
              }
            },
            child: Row(
              children: <Widget>[
                Text(
                  '高级模式',
                  style: TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Image.asset(
                    'res/drawable/wallet_gas_${!_isHighLevel ? 'down' : 'up'}.png',
                    height: 8,
                    width: 12,
                    color: HexColor('#999999'),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 12,
          ),
          _isHighLevel ? _highLevelWidget() : Container(),
        ],
      ),
    );
  }

  Widget _highLevelWidget() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            // todo: 随机数
            Text(
              '随机数（Nonce）',
              style: TextStyle(
                color: Color(0xFF999999),
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Image.asset(
                'res/drawable/wallet_gas_info.png',
                height: 12,
                width: 12,
                color: HexColor('#999999'),
              ),
            ),
            /*Spacer(),
            Text(
              '当前确认数 1',
              style: TextStyle(
                color: Color(0xFF999999),
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),*/
          ],
        ),
        _clipRectWidget(
          child: _nonceEditWidget(),
          paddingV: 2,
        ),
        SizedBox(
          height: 8,
        ),
        /*
        Row(
          children: <Widget>[
            Text(
              'Date',
              style: TextStyle(
                color: Color(0xFF999999),
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Image.asset(
                'res/drawable/wallet_gas_info.png',
                height: 12,
                width: 12,
                color: HexColor('#999999'),
              ),
            ),
          ],
        ),
        _clipRectWidget(
          child: _dateEditWidget(),
          paddingV: 4,
        ),
        */
      ],
    );
  }

  Widget _clipRectWidget({
    Widget child,
    double paddingV = 12,
    double paddingH = 0,
    double marginV = 12,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: paddingH,
        vertical: paddingV,
      ),
      margin: EdgeInsets.symmetric(
        vertical: marginV,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(6),
        ),
      ),
      child: child,
    );
  }

  Widget _toEditWidget() {
    var activatedWallet = WalletInheritedModel.of(context).activatedWallet;
    var quotePrice = _activatedQuoteSign?.price ?? 0;

    RegExp _basicAddressReg = RegExp(r'^([13]|bc)[a-zA-Z0-9]{25,42}$', caseSensitive: false);
    String addressErrorHint = "";
    if (widget.coinVo.coinType == CoinType.BITCOIN) {
      _basicAddressReg = RegExp(r'^([13]|bc)[a-zA-Z0-9]{25,42}$', caseSensitive: false);

      addressErrorHint = S.of(context).legal_address_starting_1_or_bc_or_3;
    } else {
      _basicAddressReg = RegExp(r'^(0x)?[0-9a-f]{40}', caseSensitive: false);

      addressErrorHint = S.of(context).input_valid_address;
    }

    return Form(
      key: _toKey,
      child: Container(
        // color: Colors.redAccent,
        child: TextFormField(
          controller: _toController,
          textAlign: TextAlign.start,

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
            } else if (((activatedWallet?.wallet?.getAtlasAccount()?.address ?? null) != null) &&
                ((WalletUtil.ethAddressToBech32Address(
                            activatedWallet.wallet.getAtlasAccount().address) ==
                        value) ||
                    (activatedWallet.wallet.getAtlasAccount().address == value))) {
              return S.of(context).cant_transfer_myself;
            }
            return null;
          },
          onChanged: (String inputValue) {},
          onFieldSubmitted: (String inputText) {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: HexColor('#333333'),
          ),
          cursorColor: Theme.of(context).primaryColor,
          //光标圆角
          cursorRadius: Radius.circular(5),
          //光标宽度
          cursorWidth: 1.8,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: InputBorder.none,
            hintText: 'HYN地址',
            errorStyle: TextStyle(fontSize: 14, color: Colors.blue),
            hintStyle: TextStyle(
              fontSize: 16,
              color: HexColor('#C1C1C1'),
              fontWeight: FontWeight.normal,
            ),
            suffixIcon: InkWell(
              onTap: () async {
                UiUtil.showScanImagePickerSheet(context, callback: (String text) {
                  _parseText(quotePrice, text);
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Icon(
                  ExtendsIconFont.qrcode_scan,
                  size: 18,
                  color: HexColor('#999999'),
                ),
              ),
            ),
          ),
          keyboardType: TextInputType.text,
        ),
      ),
    );
  }

  double _amountFontSize = 30;

  Widget _amountEditWidget() {
    var quoteSign = _activatedQuoteSign?.legal?.sign ?? '';

    return Form(
      key: _amountKey,
      child: Column(
        children: [
          Container(
            child: TextFormField(
              controller: _amountController,
              textAlign: TextAlign.start,
              validator: (value) {
                value = value.trim();
                if (value == "0") {
                  return S.of(context).input_corrent_count_hint;
                }
                if (!RegExp(r"\d+(\.\d+)?$").hasMatch(value)) {
                  return S.of(context).input_corrent_count_hint;
                }
                if (Decimal.parse(value) >
                    Decimal.parse(FormatUtil.coinBalanceHumanRead(widget.coinVo))) {
                  return S.of(context).input_count_over_balance;
                }
                if (value.contains(".") && value.split(".")[1].length > widget.coinVo.decimals) {
                  return "超过${widget.coinVo.decimals}位最大小数位";
                }
                return null;
              },
              onChanged: (String inputValue) {
                //print("[$runtimeType] inputValue:$inputValue");

                double fontSize = 30;
                if ((inputValue?.length ?? 0) > 8) {
                  fontSize = 24;
                } else {
                  fontSize = 30;
                }

                if (fontSize != _amountFontSize) {
                  setState(() {
                    _amountFontSize = fontSize;
                  });
                }
              },
              onFieldSubmitted: (String inputText) {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              style: TextStyle(
                fontSize: _amountFontSize,
                fontWeight: FontWeight.w500,
                color: HexColor('#333333'),
              ),
              cursorColor: Theme.of(context).primaryColor,
              //光标圆角
              cursorRadius: Radius.circular(5),
              //光标宽度
              cursorWidth: 1.8,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                border: InputBorder.none,
                hintText: '0',
                errorStyle: TextStyle(fontSize: 14, color: Colors.blue),
                hintStyle: TextStyle(
                  fontSize: 30,
                  color: HexColor('#C1C1C1'),
                  fontWeight: FontWeight.w500,
                ),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    bottom: 8,
                  ),
                  child: Text(
                    "${quoteSign ?? ""} ${FormatUtil.formatPrice(_notionalValue)}",
                    style: TextStyle(
                      color: Color(0xFFc1c1c1),
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _nonceEditWidget() {
    return Form(
      key: _nonceKey,
      child: Container(
        child: TextFormField(
          controller: _nonceController,
          textAlign: TextAlign.start,
          validator: (value) {
            value = value.trim();
            if (value == "0") {
              return S.of(context).input_corrent_count_hint;
            }
            return null;
          },
          onChanged: (String inputValue) {},
          onFieldSubmitted: (String inputText) {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: HexColor('#333333'),
          ),
          cursorColor: Theme.of(context).primaryColor,
          //光标圆角
          cursorRadius: Radius.circular(5),
          //光标宽度
          cursorWidth: 1.8,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            border: InputBorder.none,
            hintText: '0',
            errorStyle: TextStyle(fontSize: 14, color: Colors.blue),
            hintStyle: TextStyle(
              fontSize: 16,
              color: HexColor('#999999'),
              fontWeight: FontWeight.w500,
            ),
          ),
          inputFormatters: [
            LengthLimitingTextInputFormatter(18),
            FilteringTextInputFormatter.allow(RegExp("[0-9]"))
          ],
          keyboardType: TextInputType.numberWithOptions(decimal: false),
        ),
      ),
    );
  }

  /*
  Widget _dateEditWidget() {
    return Form(
      key: _dateKey,
      child: Container(
        child: TextFormField(
          controller: _dateController,
          textAlign: TextAlign.start,
          maxLines: 3,
          validator: (value) {
            value = value.trim();
            if (value == "0") {
              return S.of(context).input_corrent_count_hint;
            }
            return null;
          },
          onChanged: (String inputValue) {},
          onFieldSubmitted: (String inputText) {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.normal,
            color: HexColor('#333333'),
          ),
          cursorColor: Theme.of(context).primaryColor,
          //光标圆角
          cursorRadius: Radius.circular(5),
          //光标宽度
          cursorWidth: 1.8,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            border: InputBorder.none,
            hintText: '十六进制字符',
            errorStyle: TextStyle(fontSize: 14, color: Colors.blue),
            hintStyle: TextStyle(
              fontSize: 16,
              color: HexColor('#C1C1C1'),
              fontWeight: FontWeight.normal,
            ),
          ),
          keyboardType: TextInputType.text,
        ),
      ),
    );
  }
  */

  Widget _confirmButtonWidget() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 36,
        top: 20,
      ),
      child: ClickOvalButton(
        S.of(context).next_step,
        _confirmAction,
        btnColor: [
          HexColor("#F7D33D"),
          HexColor("#E7C01A"),
        ],
        fontColor: HexColor("#333333"),
        fontSize: 16,
        width: 260,
        height: 42,
      ),
    );
  }

  void _confirmAction() {
    var toValidate = _toKey.currentState.validate();
    var amountValidate = _amountKey.currentState.validate();
    var highLevel = true;

    // todo: 随机数检查
    if (_isHighLevel) {
      var nonceValidate = _nonceKey.currentState.validate();
      highLevel = nonceValidate;
    }
    if (toValidate && amountValidate && highLevel) {
      var amountTrim = _amountController.text.trim();
      var count = double.parse(amountTrim);
      if (count <= 0) {
        Fluttertoast.showToast(msg: S.of(context).transfer_num_bigger_zero);
        return;
      }

      var symbol = widget.coinVo.symbol.toUpperCase();

      // todo: HRC30不需要预留币
      if (widget.coinVo.coinType == CoinType.HYN_ATLAS &&
          symbol == SupportedTokens.HYN_Atlas.symbol) {
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
              "?coinVo=$voStr&transferAmount=$amountTrim&receiverAddress=${widget.coinVo.coinType == CoinType.HYN_ATLAS ? WalletUtil.bech32ToEthAddress(_toController.text) : _toController.text}");
    }
  }

  Future _parseText(double price, String barcode) async {
    try {
      if (barcode.contains("ethereum")) {
        //imtoken style address
        var barcodeArray = barcode.split("?");
        var withAddress = barcodeArray[0];
        var address = withAddress.replaceAll("ethereum:", "");
        _toController.text = address;

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
        _toController.text = address;
      } else {
        _toController.text = barcode;
      }
    } catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        Fluttertoast.showToast(msg: S.of(context).open_camera, toastLength: Toast.LENGTH_SHORT);
      } else {
        logger.e(e);
        _toController.text = "";
      }
    }
  }

  /*
  Future _onPasteAction() async {
    var text = await Clipboard.getData(Clipboard.kTextPlain);
    if (text == null) {
      return;
    }
    _toController.text = text.text;
  }
  */

  void _setupDataList() {
    _activatedQuoteSign = WalletInheritedModel.of(context).tokenLegalPrice(widget.coinVo.symbol);

    if (_isBTC) {
      _gasPriceRecommend =
          WalletInheritedModel.of(context, aspect: WalletAspect.gasPrice).btcGasPriceRecommend;
    } else {
      _gasPriceRecommend =
          WalletInheritedModel.of(context, aspect: WalletAspect.gasPrice).ethGasPriceRecommend;
    }

    if (_gasPriceRecommend != null) {
      for (int index = 0; index < 3; index++) {
        String title;
        String time;
        Decimal gas;

        switch (index) {
          case 0:
            title = '快速';
            time = S.of(context).wait_min(_gasPriceRecommend.fastWait.toString());
            gas = _gasPriceRecommend.fast;
            break;

          case 1:
            title = '一般';
            time = S.of(context).wait_min(_gasPriceRecommend.avgWait.toString());
            gas = _gasPriceRecommend.average;
            break;

          case 2:
            title = '缓慢';
            time = S.of(context).wait_min(_gasPriceRecommend.safeLowWait.toString());
            gas = _gasPriceRecommend.safeLow;
            break;
        }
        GasPriceRecommendModel model = GasPriceRecommendModel(
          title: title,
          time: time,
          gas: gas,
          index: index,
        );
        _dataList.add(model);
      }
    }
  }

  void _initLastData() async {
    if (_isBTC) {
      String custom = await AppCache.getValue(
        PrefsKey.WALLET_GAS_SAT_CUSTOM_KEY,
      );
      _selectedIndex = int?.tryParse(custom) ?? 0;

      if (_isCustom) {
        _lastGasSat = await AppCache.getValue(
          PrefsKey.WALLET_GAS_SAT_KEY,
        );

        //print("[$runtimeType] _selectedIndex:$_selectedIndex, _lastGasSat:$_lastGasSat");
      }
    } else {
      String custom = await AppCache.getValue(
        PrefsKey.WALLET_GAS_PRICE_CUSTOM_KEY,
      );
      _selectedIndex = int?.tryParse(custom??'0') ?? 0;

      if (_isCustom) {
        _lastGasPrice = await AppCache.getValue(
          PrefsKey.WALLET_GAS_PRICE_KEY,
        );

        _lastGasLimit = await AppCache.getValue(
          PrefsKey.WALLET_GAS_LIMIT_KEY,
        );
        // print(
        //     "[$runtimeType] _selectedIndex:$_selectedIndex, _lastGasLimit:$_lastGasLimit, _lastGasPrice:$_lastGasPrice");
      }
    }

    if (mounted) {
      setState(() {});
    }
  }
}
