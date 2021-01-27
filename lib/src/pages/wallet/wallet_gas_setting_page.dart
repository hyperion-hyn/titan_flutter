import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/vo/coin_view_vo.dart';
import 'package:titan/src/components/wallet/vo/token_price_view_vo.dart';
import 'package:titan/src/components/wallet/vo/wallet_view_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/config/bitcoin.dart';
import 'package:titan/src/plugins/wallet/config/ethereum.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class WalletGasSettingPage extends StatefulWidget {
  final CoinViewVo coinVo;

  WalletGasSettingPage(
    String coinVo,
  ) : this.coinVo = CoinViewVo.fromJson(FluroConvertUtils.string2map(coinVo));

  @override
  State<StatefulWidget> createState() {
    return _WalletGasSettingState();
  }
}

class _WalletGasSettingState extends BaseState<WalletGasSettingPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _gasLimitController = TextEditingController();
  final TextEditingController _gasPriceController = TextEditingController();
  final TextEditingController _gasSatController = TextEditingController();

  final _gasPriceKey = GlobalKey<FormState>();
  final _gasLimitKey = GlobalKey<FormState>();
  final _gasSatKey = GlobalKey<FormState>();

  final StreamController<dynamic> _inputController = StreamController.broadcast();

  bool get _isBTC => (widget.coinVo.coinType == CoinType.BITCOIN);
  bool get _isCustom => _selectedIndex == -1;

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

  @override
  void initState() {
    super.initState();
  }

  @override
  void onCreated() {
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

  @override
  void dispose() {
    _inputController.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#F6F6F6'),
      appBar: BaseAppBar(
        baseTitle: '矿工费设置',
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
            child: _contentWidget(),
          ),
        ),
        _confirmButtonWidget(),
      ],
    );
  }

  Widget _lineWidget({double vertical = 12}) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: vertical,
      ),
      height: 0.5,
      color: HexColor('#F2F2F2'),
    );
  }

  Widget _contentWidget() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        right: 24,
        top: 18,
      ),
      child: StreamBuilder<Object>(
          stream: _inputController.stream,
          builder: (context, snapshot) {
            var coinType = widget.coinVo.coinType;

            var gasPriceEstimateStr = '';
            var quotePrice = _activatedQuoteSign?.price ?? 0;
            var quoteSign = _activatedQuoteSign?.legal?.sign;

            var baseUnit = widget.coinVo.symbol;
            var fees;
            var format = '';
            var gasTitle = '矿工费率';

            var selectedGasPrice = _dataList[_isCustom ? 0 : _selectedIndex].gas;
            var gasPrice = selectedGasPrice;
            var gasLimit;
            var gasUnit;

            if (CoinType.BITCOIN == coinType) {
              gasPrice = _isCustom
                  ? Decimal?.tryParse(_gasSatController.text ?? '0') ?? Decimal.zero
                  : selectedGasPrice;
              gasLimit = 78;
              // gasLimit = BitcoinGasPrice.BTC_RAWTX_SIZE;
              gasUnit = 'sat/b';
              gasTitle = '矿工费率';
              format = '$gasPrice $gasUnit * $gasLimit bytes  ';

              fees = ConvertTokenUnit.weiToDecimal(
                  BigInt.parse((gasPrice * Decimal.fromInt(gasLimit)).toString()), 8);
              var gasPriceEstimate = fees * Decimal.parse(quotePrice.toString());
              gasPriceEstimateStr =
                  "$quoteSign ${FormatUtil.formatPrice(gasPriceEstimate.toDouble())}";
            } else if (CoinType.ETHEREUM == coinType){
              gasPrice = _isCustom
                  ? Decimal?.tryParse(_gasPriceController.text ?? '0') ?? Decimal.zero
                  : selectedGasPrice / Decimal.fromInt(EthereumUnitValue.G_WEI);

              gasLimit = _isCustom
                  ? Decimal?.tryParse(_gasLimitController.text ?? '0') ?? Decimal.zero
                  : Decimal.fromInt(_defaultGasLimit);
              gasUnit = 'GWEI';
              gasTitle = 'Gas Price';
              format =
                  'Gas Price（$gasPrice $gasUnit）* Gas（${FormatUtil.formatNumDecimal(double.parse(gasLimit.toString()))}）';

              var ethQuotePrice =
                  WalletInheritedModel.of(context).tokenLegalPrice('ETH')?.price ?? 0;

              var feesDecimalValue = ConvertTokenUnit.weiToEther(
                  weiBigInt: BigInt.parse(
                      (gasPrice * gasLimit * Decimal.fromInt(EthereumUnitValue.G_WEI))
                          .toStringAsFixed(0)));
              fees = FormatUtil.formatNumDecimal(feesDecimalValue.toDouble(), decimal: 6);

              var gasPriceEstimate = feesDecimalValue * Decimal.parse(ethQuotePrice.toString());
              gasPriceEstimateStr =
                  "${quoteSign ?? ""}${FormatUtil.formatPrice(gasPriceEstimate.toDouble())}";
            }
            // todo: 支持其他Symbol？？？？

            var totalFee = '$fees $baseUnit';

            return Column(
              children: <Widget>[
                _clipRectWidget(
                  paddingH: 16,
                  paddingV: 10,
                  marginV: 0,
                  child: Column(
                    children: [
                      Row(
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
                        ],
                      ),
                      _lineWidget(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            format,
                            style: TextStyle(
                              color: Color(0xFF999999),
                              fontSize: 10,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          Image.asset(
                            'res/drawable/wallet_gas_info.png',
                            height: 12,
                            width: 12,
                            color: HexColor('#999999'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  children: <Widget>[
                    Text(
                      gasTitle,
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Spacer(),
                    Text(
                      '预计交易时间',
                      style: TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                _clipRectWidget(
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      var model = _dataList[index];
                      var gasValue;

                      if (CoinType.BITCOIN == coinType) {
                        gasValue = model.gas;
                      } else if (CoinType.ETHEREUM == coinType) {
                        gasValue = model.gas / Decimal.fromInt(EthereumUnitValue.G_WEI);
                      } else {
                        gasValue = model.gas / Decimal.fromInt(EthereumUnitValue.G_WEI);
                      }

                      var gas = '$gasValue $gasUnit';

                      return InkWell(
                        onTap: () {
                          if (mounted && _selectedIndex != index) {
                            setState(() {
                              _selectedIndex = index;
                              _inputController.add(model.gas);
                            });
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: 12,
                            top: 8,
                            bottom: 8,
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 12,
                                ),
                                child: _selectedIndex == index
                                    ? Image.asset(
                                        'res/drawable/wallet_gas_selected.png',
                                        height: 20,
                                        width: 20,
                                      )
                                    : SizedBox(
                                        width: 20,
                                      ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    model.title,
                                    style: TextStyle(
                                      color: HexColor('#333333'),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Text(
                                    gas,
                                    style: TextStyle(
                                      color: HexColor('#999999'),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Text(
                                '< ${model.time}',
                                style: TextStyle(
                                  color: HexColor('#999999'),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 12,
                        ),
                        child: _lineWidget(vertical: 4),
                      );
                    },
                    itemCount: _dataList.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                  ),
                  paddingV: 4,
                ),
                _customWidget(),
              ],
            );
          }),
    );
  }

  Widget _customWidget() {
    return _clipRectWidget(
      paddingH: 16,
      paddingV: 4,
      marginV: 0,
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: () {
              if (mounted && _selectedIndex != -1) {
                setState(() {
                  var coinType = widget.coinVo.coinType;
                  if (CoinType.BITCOIN == coinType) {
                    _gasSatController.text = '';
                  } else if (CoinType.ETHEREUM == coinType) {
                    _gasLimitController.text = '$_defaultGasLimit';
                    _gasPriceController.text = '';
                  } else {
                    _gasLimitController.text = '$_defaultGasLimit';
                    _gasPriceController.text = '';
                  }

                  _selectedIndex = -1;
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(
                right: 12,
                top: 12,
                bottom: 12,
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 12,
                    ),
                    child: _selectedIndex == -1
                        ? Image.asset(
                            'res/drawable/wallet_gas_selected.png',
                            height: 20,
                            width: 20,
                          )
                        : SizedBox(
                            width: 20,
                          ),
                  ),
                  Text(
                    '自定义',
                    style: TextStyle(
                      color: HexColor('#333333'),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_selectedIndex == -1) _customInputWidget(),
        ],
      ),
    );
  }

  Widget _customInputWidget() {
    List<Widget> children = [
      _lineWidget(vertical: 8),
    ];
    if (_isBTC) {
      var sat = _customItem(
        title: '矿工费率',
        child: _gasSatEditWidget(),
      );
      children.add(sat);
    } else {
      var gasPrice = _customItem(
        title: 'Gas Price',
        child: _gasPriceEditWidget(),
      );
      var gas = _customItem(
        title: 'Gas',
        child: _gasLimitEditWidget(),
      );
      children.add(gasPrice);
      children.add(gas);
    }
    return Column(
      children: children,
    );
  }

  Widget _customItem({String title, Widget child}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 8,
          ),
          child: Row(
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  color: Color(0xFF333333),
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
            ],
          ),
        ),
        _clipRectWidget(
          child: child,
          color: Color(0xFFF6F6F6),
          paddingV: 0,
        ),
      ],
    );
  }

  Widget _clipRectWidget({
    Widget child,
    double paddingV = 12,
    double paddingH = 0,
    double marginV = 12,
    Color color = Colors.white,
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
        color: color,
        borderRadius: BorderRadius.all(
          Radius.circular(6),
        ),
      ),
      child: child,
    );
  }

  Widget _gasLimitEditWidget() {
    return Form(
      key: _gasLimitKey,
      child: Container(
        child: TextFormField(
          controller: _gasLimitController,
          textAlign: TextAlign.start,
          // todo: 验证有效性
          validator: (value) {
            value = value.trim();
            if (value == "0") {
              return S.of(context).input_corrent_count_hint;
            }
            return null;
          },
          onChanged: (String inputValue) {
            _inputController.add(inputValue);
          },
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
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
      ),
    );
  }

  Widget _gasPriceEditWidget() {
    return Form(
      key: _gasPriceKey,
      child: Container(
        child: TextFormField(
          controller: _gasPriceController,
          textAlign: TextAlign.start,
          // todo: 验证有效性
          validator: (value) {
            value = value.trim();
            if (value == "0") {
              return S.of(context).input_corrent_count_hint;
            }
            return null;
          },
          onChanged: (String inputValue) {
            _inputController.add(inputValue);
          },
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
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
      ),
    );
  }

  Widget _gasSatEditWidget() {
    return Form(
      key: _gasSatKey,
      child: Container(
        child: TextFormField(
          controller: _gasSatController,
          textAlign: TextAlign.start,
          // todo: 验证有效性
          validator: (value) {
            value = value.trim();
            if (value == "0") {
              return S.of(context).input_corrent_count_hint;
            }
            return null;
          },
          onChanged: (String inputValue) {
            _inputController.add(inputValue);
          },
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
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: InputBorder.none,
            hintText: '0',
            errorStyle: TextStyle(fontSize: 14, color: Colors.blue),
            hintStyle: TextStyle(
              fontSize: 16,
              color: HexColor('#999999'),
              fontWeight: FontWeight.w500,
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'sat/b',
                style: TextStyle(
                  color: HexColor('#999999'),
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
      ),
    );
  }

  Widget _confirmButtonWidget() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 36,
        top: 20,
      ),
      child: ClickOvalButton(
        S.of(context).confirm,
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

    // todo: 保存最近设置
  }
}

class GasPriceRecommendModel {
  final int index;
  final String title;
  final String time;
  final Decimal gas;

  GasPriceRecommendModel({
    this.index,
    this.title,
    this.time,
    this.gas,
  });
}
