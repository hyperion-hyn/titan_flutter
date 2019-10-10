import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/business/wallet/model_vo.dart';
import 'package:titan/src/business/wallet/wallet_send_confirm_page.dart';
import 'package:titan/src/presentation/extends_icon_font.dart';

import '../../global.dart';

class WalletSendPage extends StatefulWidget {
  final WalletAccountVo walletAccountVo;

  WalletSendPage(this.walletAccountVo);

  @override
  State<StatefulWidget> createState() {
    return _WalletSendState();
  }
}

class _WalletSendState extends State<WalletSendPage> {
  final TextEditingController _receiverAddressController = TextEditingController();
  final TextEditingController _countController = TextEditingController();

  final _fromKey = GlobalKey<FormState>();

  double amount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("发送 ${widget.walletAccountVo.symbol}"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Form(
            key: _fromKey,
            child: Container(
              margin: EdgeInsets.only(top: 32),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(width: 0.8, color: Colors.grey[300])),
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return "接收地址不能位空";
                            }
                            return null;
                          },
                          controller: _receiverAddressController,
                          decoration: InputDecoration(labelText: "接收者地址", border: InputBorder.none),
                        ),
                      ),
                      GestureDetector(
                        onTap: onPaste,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            "粘贴",
                            style: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: onScan,
                        child: Icon(
                          ExtendsIconFont.qrcode_scan,
                          color: Colors.blue,
                          size: 22,
                        ),
                      )
                    ],
                  ),
                  Divider(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          validator: (value) {
                            if (value == "0") {
                              return "请输入正确的数量";
                            }
                            if (!RegExp(r"\d+(\.\d+)?$").hasMatch(value)) {
                              return "请输入正确的数量";
                            }
                            if(double.parse(value)>widget.walletAccountVo.count){
                              return "超过余额";
                            }
                            return null;
                          },
                          controller: _countController,
                          decoration: InputDecoration(labelText: "HYN数量", border: InputBorder.none),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            amount = double.parse(value) * widget.walletAccountVo.currencyRate;
                            setState(() {});
                          },
                          onFieldSubmitted: (value) {
                            amount = double.parse(_countController.text) * widget.walletAccountVo.currencyRate;
                            setState(() {});
                          },
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _countController.text = widget.walletAccountVo.count.toString();
                          amount = double.parse(_countController.text) * widget.walletAccountVo.currencyRate;
                          setState(() {});
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                          child: Text(
                            "最大",
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                textBaseline: TextBaseline.ideographic),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(left: 8, top: 8),
              child: Text("≈ ${amount} ${widget.walletAccountVo.currencyUnit}")),
          Spacer(),
          Row(children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                child: RaisedButton(
                  color: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 128, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  onPressed: () {
                    if (_fromKey.currentState.validate()) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WalletSendConfirmPage(widget.walletAccountVo,
                                  double.parse(_countController.text), _receiverAddressController.text)));
                    }
                  },
                  child: Text(
                    "下一步",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ])
        ],
      ),
    );
  }

  Future onScan() async {
//    print('TODO scan');
    try {
      String barcode = await BarcodeScanner.scan();
      _receiverAddressController.text = barcode;
      setState(() => {});
    } catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        Fluttertoast.showToast(msg: S.of(context).open_camera, toastLength: Toast.LENGTH_SHORT);
      } else {
        logger.e("", e);
        setState(() => _receiverAddressController.text = "");
      }
    }
  }

  Future onPaste() async {
    var text = await Clipboard.getData(Clipboard.kTextPlain);
    _receiverAddressController.text = text.text;
    setState(() {});
  }

  bool valid() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WalletSendConfirmPage(
                widget.walletAccountVo, double.parse(_countController.text), _receiverAddressController.text)));
  }
}
