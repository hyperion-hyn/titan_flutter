import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/vo/coin_view_vo.dart';
import 'package:titan/src/components/wallet/vo/token_price_view_vo.dart';
import 'package:titan/src/components/wallet/vo/wallet_view_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/config/bitcoin.dart';
import 'package:titan/src/plugins/wallet/config/ethereum.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
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

  bool _isInvalidGasSat = false;
  bool _isInvalidGasPrice = false;
  bool _isInvalidGasLimit = false;
  bool _isFinishEdit = true;

  final StreamController<dynamic> _inputController = StreamController.broadcast();

  bool get _isBTC => (widget.coinVo.coinType == CoinType.BITCOIN);
  bool get _isCustom => _selectedIndex == -1;

  int _selectedIndex = -1;
  int _selectedIndexInit = -1;

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
    // 1._gasPriceRecommend
    _setupDataList();

    // 2.最近保存的值
    _initLastData();
  }

  @override
  void dispose() {
    _inputController.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _showCloseDialog();
        return false;
      },
      child: Scaffold(
        backgroundColor: HexColor('#F6F6F6'),
        appBar: BaseAppBar(
          baseTitle: '矿工费设置',
          backgroundColor: HexColor('#F6F6F6'),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Image.asset(
                  'res/drawable/add_position_image_pre.png',
                  width: 18,
                  height: 18,
                  color: HexColor("#333333"),
                ),
                onPressed: _showCloseDialog,
              );
            },
          ),
        ),
        body: _body(context),
      ),
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
            var quoteSign = _activatedQuoteSign?.legal?.sign ?? '';

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
            } else if (CoinType.ETHEREUM == coinType) {
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  child: Row(
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

                              _isFinishEdit = _selectedIndexInit == index;
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

                  _isFinishEdit = false;
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
        key: _gasSatKey,
        controller: _gasSatController,
        validator: (String inputText) {
          if (inputText.isEmpty || inputText == null) {
            return '';
          }

          var validStr = '';
          if (inputText != null) {
            validStr = '请输入有效的矿工费率';

            var inputValue = int.tryParse(inputText ?? '0') ?? 0;
            var inputDecimalValue = Decimal.fromInt(inputValue);

            if (_gasPriceRecommend.safeLow > inputDecimalValue &&
                inputDecimalValue > Decimal.zero) {
              validStr = '矿工费率过低，将会影响交易确认时间';
            }

            if (inputDecimalValue > _gasPriceRecommend.fast) {
              validStr = '矿工费率过高，将会造成矿工费浪费';
            }
          }

          _isInvalidGasSat = validStr.isNotEmpty;

          return validStr;
        },
      );
      children.add(sat);
    } else {
      var gasPrice = _customItem(
        title: 'Gas Price',
        key: _gasPriceKey,
        controller: _gasPriceController,
        validator: (String textStr) {
          var validStr = '';
          if (textStr != null) {
            validStr = S.of(context).please_input_gas_price;

            var inputValue = int.tryParse(textStr ?? '0') ?? 0;
            var inputDecimalValue = Decimal.fromInt(inputValue * EthereumUnitValue.G_WEI);

            if (_gasPriceRecommend.safeLow > inputDecimalValue &&
                inputDecimalValue > Decimal.zero) {
              validStr = S.of(context).gas_low_affect_confirmation;
            }

            if (inputDecimalValue > _gasPriceRecommend.fast) {
              validStr = S.of(context).gas_high_cause_waste_fees;
            }
          }

          _isInvalidGasPrice = validStr.isNotEmpty;

          return validStr;
        },
      );
      var gas = _customItem(
        key: _gasLimitKey,
        controller: _gasLimitController,
        title: 'Gas',
        validator: (String textStr) {
          var validStr = '';
          if (textStr != null) {
            validStr = '请输入有效的 Gas';

            var inputValue = int.tryParse(textStr ?? '0') ?? 0;
            var inputDecimalValue = Decimal.fromInt(inputValue);

            var ethTransferGasLimit =
                SettingInheritedModel.ofConfig(context).systemConfigEntity.ethTransferGasLimit;
            var safeLow = Decimal.fromInt(ethTransferGasLimit);

            var erc20TransferGasLimit =
                SettingInheritedModel.ofConfig(context).systemConfigEntity.erc20TransferGasLimit;
            var fast = Decimal.fromInt(erc20TransferGasLimit);

            if (safeLow > inputDecimalValue && inputDecimalValue > Decimal.zero) {
              validStr = 'Gas 过低，$validStr';
            }

            if (inputDecimalValue > fast) {
              validStr = 'Gas 过高，$validStr';
            }
          }

          _isInvalidGasLimit = validStr.isNotEmpty;

          return validStr;
        },
      );
      children.add(gasPrice);
      children.add(gas);
    }
    return Column(
      children: children,
    );
  }

  Widget _customItem({
    String title,
    FormFieldValidator<String> validator,
    Key key,
    TextEditingController controller,
  }) {
    return StreamBuilder<Object>(
      stream: _inputController.stream,
      builder: (context, snapshot) {
        String textStr = snapshot?.data;

        var validStr = '';
        if (textStr != null) {
          validStr = validator(controller.text);
        }

        return Container(
          child: Column(
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
                child: _gasTextFieldWidget(
                  key: key,
                  controller: controller,
                ),
                color: Color(0xFFF6F6F6),
                paddingV: 0,
              ),
              validStr.isEmpty
                  ? Container()
                  : Padding(
                      padding: EdgeInsets.only(
                        bottom: 20,
                      ),
                      child: Row(
                        children: <Widget>[
                          Text(
                            validStr,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        );
      },
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

  Widget _gasTextFieldWidget({
    Key key,
    TextEditingController controller,
  }) {
    return Form(
      key: key,
      child: Container(
        child: TextFormField(
          controller: controller,
          textAlign: TextAlign.start,
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
          // cursorColor: Theme.of(context).primaryColor,
          cursorColor: Colors.blue,
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
            suffixIcon: _isBTC
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'sat/b',
                      style: TextStyle(
                        color: HexColor('#999999'),
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  )
                : null,
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

  void _confirmAction() async {
    if (_isBTC) {
      String gasSat;
      if (_isCustom) {
        gasSat = _gasSatController.text;
        var value = Decimal?.tryParse(gasSat) ?? Decimal.zero;
        if (gasSat.isEmpty || value <= Decimal.zero) {
          var validStr = '请输入有效的矿工费率';
          Fluttertoast.showToast(msg: validStr);
          return;
        }
      } else {
        gasSat = _dataList[_selectedIndex].gas.toString();
      }

      await AppCache.saveValue(PrefsKey.WALLET_GAS_SAT_CUSTOM_KEY, _selectedIndex.toString());
      await AppCache.saveValue(PrefsKey.WALLET_GAS_SAT_KEY, gasSat);
    } else {
      String gasPrice;
      String gasLimit;

      if (_isCustom) {
        gasPrice = _gasPriceController.text;
        var gasPriceValue = Decimal?.tryParse(gasPrice) ?? Decimal.zero;
        if (gasPrice.isEmpty || gasPriceValue <= Decimal.zero) {
          var validStr = S.of(context).please_input_gas_price;
          Fluttertoast.showToast(msg: validStr);
          return;
        }

        gasLimit = _gasLimitController.text;
        var gasLimitValue = Decimal?.tryParse(gasPrice) ?? Decimal.zero;
        if (gasLimit.isEmpty || gasLimitValue <= Decimal.zero) {
          var validStr = '请输入有效的 Gas';
          Fluttertoast.showToast(msg: validStr);
          return;
        }
      } else {
        gasPrice = _dataList[_selectedIndex].gas.toString();
        gasLimit = _defaultGasLimit.toString();
      }

      await AppCache.saveValue(PrefsKey.WALLET_GAS_PRICE_CUSTOM_KEY, _selectedIndex.toString());
      await AppCache.saveValue(PrefsKey.WALLET_GAS_PRICE_KEY, gasPrice);
      await AppCache.saveValue(PrefsKey.WALLET_GAS_LIMIT_KEY, gasLimit);
    }

    Navigator.of(context).pop();
  }

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
      _selectedIndexInit = _selectedIndex;

      if (_isCustom) {
        String gasSat = await AppCache.getValue(
          PrefsKey.WALLET_GAS_SAT_KEY,
        );
        _gasSatController.text = gasSat;
        _inputController.add(gasSat);

        _scrollController.animateTo(
          200,
          duration: Duration(milliseconds: 300, microseconds: 33),
          curve: Curves.linear,
        );

        print("[$runtimeType] _selectedIndex:$_selectedIndex, gasSat:$gasSat");
      } else {
        if (mounted) {
          setState(() {});
        }
      }
    } else {
      String custom = await AppCache.getValue(
        PrefsKey.WALLET_GAS_PRICE_CUSTOM_KEY,
      );
      _selectedIndex = int?.tryParse(custom) ?? 0;
      _selectedIndexInit = _selectedIndex;

      if (_isCustom) {
        String gasPrice = await AppCache.getValue(
          PrefsKey.WALLET_GAS_PRICE_KEY,
        );
        Decimal gasPriceDecimalValue = Decimal?.tryParse(gasPrice ?? '0') ?? Decimal.zero;
        _gasPriceController.text = gasPriceDecimalValue.toString();

        String gasLimit = await AppCache.getValue(
          PrefsKey.WALLET_GAS_PRICE_KEY,
        );
        Decimal gasLimitDecimalValue = Decimal?.tryParse(gasLimit ?? '0') ?? Decimal.zero;
        _gasLimitController.text = gasLimitDecimalValue.toString();

        _inputController.add(gasPrice);

        _scrollController.animateTo(
          200,
          duration: Duration(milliseconds: 300, microseconds: 33),
          curve: Curves.linear,
        );
      } else {
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  _showCloseDialog() {
    if (_isFinishEdit) {
      Navigator.of(context).pop();
      return;
    }

    UiUtil.showAlertView(
      context,
      title: S.of(context).tips,
      actions: [
        ClickOvalButton(
          S.of(context).cancel,
          () {
            Navigator.pop(context, false);
          },
          width: 115,
          height: 36,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          fontColor: DefaultColors.color999,
          btnColor: [Colors.transparent],
        ),
        SizedBox(
          width: 20,
        ),
        ClickOvalButton(
          S.of(context).confirm,
          () {
            Navigator.pop(context);
            Navigator.of(context).pop();
          },
          width: 115,
          height: 36,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ],
      content: '矿工费设置未确认，确认要离开此页？',
    );
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
