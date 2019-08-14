import 'dart:math';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/inject/injector.dart';
import 'package:titan/src/model/poi_interface.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:titan/src/utils/encryption.dart';
import 'package:titan/src/utils/open_location_code.dart' as locationCode;

import '../../global.dart';

class ShareDialog extends StatefulWidget {
  final IPoi poi;

  ShareDialog({@required this.poi});

  @override
  State<StatefulWidget> createState() {
    return ShareDialogState();
  }
}

class ShareDialogState extends State<ShareDialog> {
  bool expandOptions = false;

  String pubAddress;
  String remark;

  var pubKeyTextEditController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    pubKeyTextEditController.addListener(() {
      if (addressErrorStr != null) {
        setState(() {
          addressErrorStr = null;
          _formKey.currentState.validate();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Duration insetAnimationDuration = const Duration(milliseconds: 100);
    Curve insetAnimationCurve = Curves.decelerate;

    RoundedRectangleBorder _defaultDialogShape =
        RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2.0)));

    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets + const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
      duration: insetAnimationDuration,
      curve: insetAnimationCurve,
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                color: Colors.white,
              ),
              child: buildContent(context),
            )
          ],
        ),
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Align(
          child: InkWell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.close),
            ),
            onTap: () => Navigator.pop(context),
          ),
          alignment: Alignment.topRight,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '位置加密分享',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                Container(
                  color: Colors.grey[100],
                  margin: EdgeInsets.only(top: 16),
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.poi.name,
                        style: TextStyle(color: Colors.grey[600], fontSize: 15),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.location_on,
                            color: Colors.grey[500],
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.poi.address,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!expandOptions)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          expandOptions = true;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            '分享选项',
                            style: TextStyle(color: Colors.blue),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.blue,
                          )
                        ],
                      ),
                    ),
                  ),
                if (expandOptions)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        TextFormField(
                          controller: pubKeyTextEditController,
                          autofocus: true,
                          decoration: InputDecoration(
                              labelText: "点对点分享",
                              hintText: "接收者加密地址（公钥）",
                              contentPadding: EdgeInsets.only(top: 16, right: 32, bottom: 8)),
                          validator: validatePubAddress,
                          onSaved: (value) {
                            print('xx onSave address $value');
                            pubAddress = value;
                          },
                        ),
                        Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: onScan,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Icon(IconData(0xe75a, fontFamily: 'iconfont')),
                              ),
                            ))
                      ],
                    ),
                  ),
                if (expandOptions)
                  TextFormField(
                    autofocus: true,
                    maxLength: 50,
                    decoration: InputDecoration(
                        labelText: "附言", hintText: "50字内", contentPadding: EdgeInsets.only(top: 16, bottom: 8)),
                    onSaved: (value) {
                      print('xx onSave remark $value');
                      remark = value;
                    },
                  ),
                SizedBox(
                  height: 16,
                ),
                Align(
                  alignment: Alignment.center,
                  child: RaisedButton.icon(
                    onPressed: onShare,
                    icon: Icon(
                      Icons.lock,
                      size: 20,
                    ),
                    label: Text(
                      '分享',
                      style: TextStyle(fontSize: 16),
                    ),
                    color: Colors.black87,
                    splashColor: Colors.white10,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0)),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  String addressErrorStr;
  String validatePubAddress(String address) {
    return addressErrorStr;
  }

  Future onScan() async {
//    print('TODO scan');
    try {
      String barcode = await BarcodeScanner.scan();
      if (barcode.length != 130) {
        Fluttertoast.showToast(msg: "公钥有误，请重新扫描", toastLength: Toast.LENGTH_SHORT);
      } else {
        pubKeyTextEditController.text = barcode;
        setState(() => {});
      }
    } catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        Fluttertoast.showToast(msg: "请开启相机权限", toastLength: Toast.LENGTH_SHORT);
      } else {
        setState(() => this.pubAddress = 'Unknown error: $e');
      }
    }
  }

  void onShare() async {
    _formKey.currentState.save();

    String cipherText;

    bool isReEncrypt = pubAddress == null || pubAddress.isEmpty;
    if (isReEncrypt) {
      try {
        cipherText = await reEncryptPoi(Injector.of(context).repository, widget.poi, remark);
      } catch (err) {
        logger.e(err);
        Fluttertoast.showToast(msg: '加密发生异常');
      }
    } else {
      //p2p
      try {
        cipherText = await p2pEncryptPoi(pubAddress, widget.poi, remark);
      } catch (err) {
        logger.e(err);

        setState(() {
          addressErrorStr = '不是合法的公钥';
          _formKey.currentState.validate();
        });
      }
    }

    if (cipherText != null && cipherText.isNotEmpty) {
      Share.text('分享加密位置', cipherText, 'text/plain');
    }
  }
}
