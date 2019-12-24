import 'package:barcode_scan/barcode_scan.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/components/inject/injector.dart';
import 'package:titan/src/model/poi_interface.dart';
import 'package:titan/src/utils/encryption.dart';

import '../../../../global.dart';


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
            ),
          ],
        ),
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  S.of(context).share_encrypted_location,
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
                            S.of(context).add_share_options,
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
                              labelText: S.of(context).accept_share_pub_key,
                              hintText: S.of(context).receiver_encrypted_address,
                              contentPadding: EdgeInsets.only(top: 16, right: 32, bottom: 8)),
                          validator: validatePubAddress,
                          onSaved: (value) {
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
                        labelText: S.of(context).postscript, hintText: S.of(context).postscript_hint, contentPadding: EdgeInsets.only(top: 16, bottom: 8)),
                    onSaved: (value) {
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
                      S.of(context).share,
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
        ),
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
        Fluttertoast.showToast(msg: S.of(context).public_key_scan_fail_rescan, toastLength: Toast.LENGTH_SHORT);
      } else {
        pubKeyTextEditController.text = barcode;
        setState(() => {});
      }
    } catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        Fluttertoast.showToast(msg: S.of(context).open_camera, toastLength: Toast.LENGTH_SHORT);
      } else {
        logger.e("",e);
        setState(() => this.pubAddress = S.of(context).unknown_error);
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
        Fluttertoast.showToast(msg: S.of(context).encrypt_error);
      }
    } else {
      //p2p
      try {
        cipherText = await p2pEncryptPoi(pubAddress, widget.poi, remark);
      } catch (err) {
        logger.e(err);

        setState(() {
          addressErrorStr = S.of(context).share_invalid_public_key;
          _formKey.currentState.validate();
        });
      }
    }

    if (cipherText != null && cipherText.isNotEmpty) {
      Share.text(S.of(context).share_encrypted_location, cipherText, 'text/plain');
      Navigator.pop(context, true);
    }
  }
}
