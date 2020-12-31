import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/vo/coin_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/utils/utile_ui.dart';

typedef GasInputChangedCallback = void Function(Decimal gasPrice, int gasPriceLimit);

class GasInputWidget extends StatefulWidget {
  final CoinVo coinVo;
  final double currentEthPrice;
  final GasInputChangedCallback callback;

  GasInputWidget({this.coinVo, this.currentEthPrice, this.callback});

  @override
  _GasInputWidgetState createState() => _GasInputWidgetState();
}

class _GasInputWidgetState extends BaseState<GasInputWidget> {
  double _ethDefaultPrice = 1489.73607;
  double _ethPrice = 0.0;

  Decimal _minGasPrice = Decimal.parse('34.10');
  Decimal _maxGasPrice = Decimal.parse('100.00');
  Decimal _gasPrice = Decimal.zero;

  int _minGasPriceLimit = 21000;
  int _defaultGasPriceLimit = 50000;
  int _gasPriceLimit = 0;

  bool _isOpen = false;

  final TextEditingController _gasPriceController = TextEditingController();
  final TextEditingController _gasPriceLimitController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void onCreated() {

    super.onCreated();

    var ethQuotePrice = WalletInheritedModel.of(context).activatedQuoteVoAndSign('ETH')?.quoteVo?.price ?? 0;

    var gasLimit = widget.coinVo.symbol == "ETH"
        ? SettingInheritedModel.ofConfig(context).systemConfigEntity.ethTransferGasLimit
        : SettingInheritedModel.ofConfig(context).systemConfigEntity.erc20TransferGasLimit;
    var gasEstimate = ConvertTokenUnit.weiToEther(
        weiBigInt: BigInt.parse((_gasPrice * Decimal.fromInt(gasLimit)).toStringAsFixed(0)));
    var gasPriceEstimate = gasEstimate * Decimal.parse(ethQuotePrice.toString());

    _ethPrice = gasPriceEstimate.toDouble() ?? widget.currentEthPrice ?? _ethDefaultPrice;

    var gasPriceRecommend = WalletInheritedModel.of(context, aspect: WalletAspect.gasPrice).gasPriceRecommend;
    _gasPrice = (gasPriceRecommend.average / Decimal.fromInt(TokenUnit.G_WEI))??_minGasPrice;
    _maxGasPrice = (gasPriceRecommend.fast / Decimal.fromInt(TokenUnit.G_WEI));

    _gasPriceLimit = gasLimit ?? _defaultGasPriceLimit;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    var _gasPriceValue = (_gasPrice * Decimal.fromInt(_gasPriceLimit)) / Decimal.fromInt(TokenUnit.G_WEI);
    var _gasPriceString = _gasPriceValue.toStringAsPrecision(4);

    var _rmbPrice = _gasPriceValue * Decimal.parse(_ethPrice.toString());
    var _rmbPriceString = _rmbPrice.toStringAsPrecision(3);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _onEditingComplete,
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8),
              child: Row(
                children: <Widget>[
                  Text(
                    '${S.of(context).gas_fee}(${widget.coinVo.coinType == CoinType.HYN_ATLAS ? 'HYN' : 'ETH'})',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: HexColor('#FF999999'),
                    ),
                  ),
                  // Text(
                  //   "矿工费",
                  //   style: TextStyle(color: HexColor("#333333"), fontSize: 16),
                  // ),
                  Spacer(),
                  Text(
                    // 'aaaa ether ≈ ￥ bbb',
                    "$_gasPriceString ether ≈ ￥$_rmbPriceString",
                    style: TextStyle(color: HexColor("#1F81FF")),
                  ),
                ],
              ),
            ),
            _isOpen ? _highWidget() : _normalWidget(),
            SizedBox(
              height: 12,
            ),
            Text("PS: 为避免转账失败，系统默认GAS值偏大，最终以实际链上GAS扣除量为准。", style: TextStyle(fontSize: 10, color: HexColor("#999999"))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Spacer(),
                  Text(
                    "高级模式",
                    style: TextStyle(color: HexColor("#999999")),
                  ),
                  Switch(
                    value: _isOpen,
                    activeColor: Theme.of(context).primaryColor,
                    activeTrackColor: Theme.of(context).primaryColor,
                    onChanged: (bool newValue) {
                      setState(() {
                        _isOpen = newValue;

//                        if (_gasPriceController.text.isEmpty) {
                        _gasPriceController.text = "${_gasPrice.toStringAsPrecision(4)}";
//                        }

//                        if (_gasPriceLimitController.text.isEmpty) {
                        _gasPriceLimitController.text = "$_gasPriceLimit";
//                        }
                      });
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _normalWidget() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8),
          child: Row(
            children: <Widget>[
              Image.asset(
                'res/drawable/slow_speed.png',
                fit: BoxFit.cover,
                width: 19,
                height: 16,
              ),
              Flexible(
                flex: 3,
                child: Slider(
                  value: _gasPrice.toDouble(),
                  activeColor: Theme.of(context).primaryColor,
                  inactiveColor: Colors.grey[300],
                  min: _minGasPrice.toDouble(),
                  max: _maxGasPrice.toDouble(),
                  label: '$_gasPrice gwei',
                  onChanged: (double newValue) {
                    setState(() {
                      _gasPrice = Decimal.parse(newValue.toString());

                      if (widget.callback != null) {
                        widget.callback(_gasPrice, _gasPriceLimit);
                      }
                    });
                  },
                  semanticFormatterCallback: (double newValue) {
                    return '$newValue gwei';
                  },
                ),
              ),
              Image.asset(
                'res/drawable/quickly_speed.png',
                fit: BoxFit.cover,
                width: 19,
                height: 19,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
          child: Row(
            children: <Widget>[
              Spacer(),
              Text(
                "${_gasPrice.toStringAsPrecision(4)} gwei",
                style: TextStyle(color: HexColor("#999999")),
              ),
              Spacer(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _highWidget() {
    return Column(
      children: <Widget>[
        textField(_gasPriceController, "自定义 Gas Price", "gwei"),
        textField(_gasPriceLimitController, "自定义 Gas", "gas"),
      ],
    );
  }

  void _onEditingComplete() {
    FocusScope.of(context).requestFocus(FocusNode());

    if (!_isOpen) {
      return;
    }
    String toast;

    // _gasPrice
    if (_gasPriceController.text.isEmpty) {
      print("nullllllllllll--2222");
      _gasPrice = Decimal.zero;
    } else {
      _gasPrice = Decimal.tryParse(_gasPriceController.text) ?? Decimal.zero;
    }
    if (_gasPrice < _minGasPrice) {
      toast = "Gas price 太低，建议应该大于 $_minGasPrice GWei";
      _gasPrice = _minGasPrice;
    }
    if (_gasPrice > _maxGasPrice) {
      toast = "Gas price 太高，建议应该小于 $_maxGasPrice GWei";
      _gasPrice = _maxGasPrice;
    }
    print(toast);

    var isShow = false;
    if (toast != null) {
      isShow = true;
      UiUtil.toast(toast);
    }
    // _gasPriceLimit
    if (_gasPriceLimitController.text.isEmpty) {
      print("nullllllllllll--1");
      _gasPriceLimit = 0;
    } else {
      _gasPriceLimit = int.tryParse(_gasPriceLimitController.text) ?? _minGasPriceLimit;
    }
    if (_gasPriceLimit < _minGasPriceLimit) {
      toast = "Gas 不能小于 $_minGasPriceLimit";
      _gasPriceLimit = _minGasPriceLimit;
    }
    print(toast);
    if (toast != null && !isShow) {
      UiUtil.toast(toast);
    }

    if (widget.callback != null) {
      widget.callback(_gasPrice, _gasPriceLimit);
    }

    setState(() {});
  }

}

Widget textField(TextEditingController controller, String hintText, String suffixText) {
  //print("[textfield] $initialValue, controller:$controller");

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
    child: Row(
      children: <Widget>[
        Expanded(
          child: TextFormField(
            controller: controller,
            validator: (value) {
              if (value == null || value.trim().length == 0) {
                return hintText;
              } else {
                return null;
              }
            },
            /*onChanged: (String inputText) {
                print('[add] --> onChanged, inputText:${inputText}');
              },*/
            onEditingComplete: () {
              print('[add] --> onEditingComplete, text:${controller.text}');

              //_onEditingComplete();
            },
            /*onFieldSubmitted: (String inputText) {
                print('[add] --> onFieldSubmitted, inputText:${inputText}');

                FocusScope.of(context).requestFocus(FocusNode());
              },*/
            style: TextStyle(fontSize: 16),
            cursorColor: Theme.of(Keys.rootKey.currentContext).primaryColor,
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
              hintStyle: TextStyle(fontSize: 14, color: Colors.grey[300]),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(width: 0.5, color: Colors.blue, style: BorderStyle.solid)),
              //输入框启用时，下划线的样式
              disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(width: 0.5, color: Colors.grey[300], style: BorderStyle.solid)),
              //输入框启用时，下划线的样式
              enabledBorder: UnderlineInputBorder(
                  borderSide:
                  BorderSide(width: 0.5, color: Colors.grey[300], style: BorderStyle.solid)), //输入框启用时，下划线的样式
            ),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    ),
  );
}
