
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/utils/utile_ui.dart';

typedef GasInputChangedCallback = void Function(double gasPrice, double gasPriceLimit);

class GasInputWidget extends StatefulWidget {

  final double currentEthPrice;
  final GasInputChangedCallback callback;
  GasInputWidget({this.currentEthPrice, this.callback});

  @override
  _GasInputWidgetState createState() => _GasInputWidgetState();
}

class _GasInputWidgetState extends State<GasInputWidget> {

  double _minGasPriceLimit = 21000;
  double _defaultGasPriceLimit = 50000;
  double _minGasPrice = 34.10;
  double _maxGasPrice = 100.00;
  double _ethDefaultPrice = 1489.73607;
  double _ethPrice;
  double _gasPrice;
  double _gasPriceLimit;
  bool _isOpen = false;
  TextEditingController _gasPriceController = TextEditingController();
  TextEditingController _gasPriceLimitController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.currentEthPrice != null) {
      _ethPrice = widget.currentEthPrice;
    } else {
      _ethPrice = _ethDefaultPrice;
    }

    _gasPrice = _minGasPrice;
    _gasPriceLimit = _defaultGasPriceLimit;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));

    var _gasPriceValue = (_gasPrice * _gasPriceLimit) / (10000*10000*10);
    var _gasPriceString = _gasPriceValue.toStringAsPrecision(4);

    var _rmbPrice = _gasPriceValue * _ethPrice;
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
                  Text("矿工费用"),
                  Spacer(),
                  Text(
                    "$_gasPriceString ether ≈ ￥$_rmbPriceString",
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
            ),
            _isOpen ? _highWidget() : _normalWidget(),
            SizedBox(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Spacer(),
                  Text(
                    "高级模式",
                    style: TextStyle(color: Colors.grey[400]),
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
                          _gasPriceLimitController.text = "${_gasPriceLimit}";
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
                'res/drawable/slow_speed.jpg',
                fit: BoxFit.cover,
                width: 20,
                height: 20,
              ),
              Flexible(
                flex: 3,
                child: Slider(
                  value: _gasPrice,
                  activeColor: Theme.of(context).primaryColor,
                  inactiveColor: Colors.grey[300],
                  min: _minGasPrice,
                  max: _maxGasPrice,
                  label: '$_gasPrice gwei',
                  onChanged: (double newValue) {
                    setState(() {
                      _gasPrice = newValue;

                      if (widget.callback != null) {
                        widget.callback(_gasPrice, _gasPriceLimit);
                      }

                    });
                  },
                  semanticFormatterCallback: (double newValue) {
                    return '${newValue} gwei';
                  },
                ),
              ),
              Image.asset(
                'res/drawable/quickly_speed.jpg',
                fit: BoxFit.cover,
                width: 22,
                height: 20,
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
                style: TextStyle(color: Colors.grey[300]),
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
        _textField(_gasPriceController, "自定义 Gas Price", "gwei"),
        _textField(_gasPriceLimitController, "自定义 Gas", "gas"),
      ],
    );
  }
  //width: MediaQuery.of(context).size.width - 16.0 * 5.0,

  void _onEditingComplete() {

    FocusScope.of(context).requestFocus(FocusNode());

    if (!_isOpen) {
      return;
    }
    String toast;


    // _gasPrice
    if (_gasPriceController.text.isEmpty) {
      print("nullllllllllll--2222");
      _gasPrice = 0;
    } else {
      _gasPrice = double.parse(_gasPriceController.text);
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
      _gasPriceLimit = double.parse(_gasPriceLimitController.text);
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

    setState(() {

    });
  }

  Widget _textField(TextEditingController controller, String hintText, String suffixText) {
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
              onEditingComplete: (){
                print('[add] --> onEditingComplete, text:${controller.text}');

                _onEditingComplete();
              },
              /*onFieldSubmitted: (String inputText) {
                print('[add] --> onFieldSubmitted, inputText:${inputText}');

                FocusScope.of(context).requestFocus(FocusNode());
              },*/
              style: TextStyle(fontSize: 16),
              cursorColor: Theme.of(context).primaryColor,
              //光标圆角
              cursorRadius: Radius.circular(5),
              //光标宽度
              cursorWidth: 1.8,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                suffixIcon:  SizedBox(
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
                    borderSide:
                    BorderSide(width: 0.5, color: Colors.blue, style: BorderStyle.solid)), //输入框启用时，下划线的样式
                disabledBorder: UnderlineInputBorder(
                    borderSide:
                    BorderSide(width: 0.5, color: Colors.grey[300], style: BorderStyle.solid)), //输入框启用时，下划线的样式
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

}
