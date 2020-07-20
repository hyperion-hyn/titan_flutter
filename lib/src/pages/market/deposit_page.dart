import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:titan/src/app.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/widget/CustomRadioButton.dart';
import 'package:titan/src/widget/click_oval_button.dart';
import 'package:titan/src/widget/click_oval_icon_button.dart';

class DepositPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DepositPageState();
  }
}

class _DepositPageState extends State<DepositPage> {
  var _selectedChain = 'erc20';
  String _erc20Address = '0X8353306cf05639238abc66a65844d81dfa830bdb';
  String _omniAddress =
      '0X8353306cf05639238abc66a65844d81dfa830bdb0X8353306cf05639238abc66a65844d81dfa830bdb';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _appBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _coinView(),
                      _chainSelectionView(),
                      _barcodeView(),
                      _warningView()
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

  _appBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        Spacer(),
        Icon(Icons.format_align_center),
        SizedBox(
          width: 16.0,
        ),
      ],
    );
  }

  _coinView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            '充币',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
          ),
        ),
        InkWell(
          onTap: () {
            _showCoinSelectDialog();
          },
          child: Container(
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                )),
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                Text(
                  'USDT',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Text(
                  '选择币种 ',
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.grey[500]),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  _showCoinSelectDialog() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            children: <Widget>[
              Center(
                child: Text('USDT'),
              ),
              Center(
                child: Text('BTC'),
              ),
              Center(
                child: Text('ETH'),
              ),
              FlatButton(
                onPressed: () {},
                child: Text(
                  'USDT',
                ),
              ),
              Container(
                padding: EdgeInsets.all(8.0),
                width: double.infinity,
                height: 50,
                child: RaisedButton(
                  color: Colors.white,
                  textColor: Theme.of(context).primaryColor,
                  onPressed: () {},
                  child: Text(
                    'USDT',
                  ),
                ),
              )
            ],
          );
        });
  }

  _chainSelectionView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            '链名称',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
        CustomRadioButton(
          buttonColor: Colors.white,
          selectedTextColor: Theme.of(context).primaryColor,
          unselectedTextColor: Colors.grey,
          buttonLabels: ['ERC20', 'OMNI'],
          buttonValues: ['erc20', 'omni'],
          radioButtonValue: (value) {
            _selectedChain = value;
            setState(() {});
          },
          selectedColor: Colors.white,
          fontSize: 13,
          width: 80,
          height: 30,
        ),
      ],
    );
  }

  _barcodeView() {
    return Container(
      padding: EdgeInsets.all(16.0),
      color: Colors.grey[200],
      child: Column(
        children: <Widget>[
          Center(
              child: RepaintBoundary(
            child: QrImage(
              data: _selectedChain == 'erc20' ? _erc20Address : _omniAddress,
              backgroundColor: Colors.white,
              foregroundColor: Colors.grey[800],
              version: 6,
              size: 200,
            ),
          )),
          SizedBox(
            height: 8.0,
          ),
          Container(
            width: 100,
            height: 30,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
              textColor: HexColor('#FF1F81FF'),
              child: Text(
                '保存二维码',
                style: TextStyle(
                  fontSize: 13,
                ),
              ),
              onPressed: () {
                _saveBarcode();
              },
            ),
          ),
          SizedBox(
            height: 8.0,
          ),
          Text(
            '充币地址',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          SizedBox(
            height: 8.0,
          ),
          Text(
            _selectedChain == 'erc20' ? _erc20Address : _omniAddress,
            style: TextStyle(
              fontSize: 13,
            ),
          ),
          SizedBox(
            height: 8.0,
          ),
          Container(
            width: 100,
            height: 30,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
              child: Text(
                '复制地址',
                style: TextStyle(
                  fontSize: 13,
                ),
              ),
              onPressed: () {
                _copyAddressToClipboard();
              },
            ),
          ),
        ],
      ),
    );
  }

  _warningView() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32.0),
      child: Text(
        '请勿向上述地址充值任何非ERC20-USDT资产，否则资产将不可找回。您充值至上述地址后，需要整个网站节点的确认，12次网络确认后到账12次网络确认后可提币。\n最小充币金额：1USTD,小于最小金额的充值将不会上账切无法退回。',
        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
      ),
    );
  }

  _updateAddress() {}

  _saveBarcode() {}

  _copyAddressToClipboard() {}
}
