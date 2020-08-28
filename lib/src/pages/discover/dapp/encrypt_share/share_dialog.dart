import 'package:barcode_scan/barcode_scan.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/components/inject/injector.dart';
import 'package:titan/src/data/entity/poi/poi_interface.dart';
import 'package:titan/src/utils/encryption.dart';
import 'package:titan/src/widget/loading_button/custom_click_oval_button.dart';

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
    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets +
          const EdgeInsets.symmetric(horizontal: 32.0),
      duration: insetAnimationDuration,
      curve: insetAnimationCurve,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        color: Colors.white,
                      ),
                      child: buildContent(context),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Image.asset(
                          'res/drawable/ic_dialog_close.png',
                          width: 18,
                          height: 18,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: BaseGestureDetector(
            context: context,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Text(
                      S.of(context).share_encrypted_location,
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    margin: EdgeInsets.only(top: 16),
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.poi.name,
                          style: TextStyle(
                              color: HexColor('#FF333333'),
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.location_on,
                              color: HexColor('#FF999999'),
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
                  if (expandOptions) _p2pShareOptions(),
                  Row(
                    children: <Widget>[
                      Spacer(),
                      Text(
                        S.of(context).advanced_mode,
                        style: TextStyle(color: HexColor('#FF999999')),
                      ),
                      Switch(
                        activeColor: Colors.grey[100],
                        activeTrackColor: Theme.of(context).primaryColor,
                        onChanged: (value) {
                          expandOptions = value;
                          setState(() {});
                        },
                        value: expandOptions,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: CustomClickOvalButton(
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.lock_outline,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            S.of(context).share,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      onShare,
                      width: 120,
                      height: 40,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _p2pShareOptions() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                S.of(context).accept_share_pub_key,
                style: TextStyle(
                    fontSize: 17,
                    color: HexColor('#FF333333'),
                    fontWeight: FontWeight.bold),
              ),
              Spacer(),
              InkWell(
                onTap: onScan,
                child: Icon(IconData(0xe75a, fontFamily: 'iconfont')),
              ),
              SizedBox(
                width: 16.0,
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
            child: TextFormField(
              validator: validatePubAddress,
              autofocus: true,
              controller: pubKeyTextEditController,
              decoration: InputDecoration(
                filled: true,
                fillColor: HexColor('#FFF2F2F2'),
                hintText: S.of(context).receiver_encrypted_address,
                hintStyle: TextStyle(
                  color: HexColor('#FF999999'),
                  fontSize: 13,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: HexColor('#FFF2F2F2'),
                    width: 0.5,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: HexColor('#FFF2F2F2'),
                    width: 0.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: HexColor('#FFF2F2F2'),
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
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: TextStyle(fontSize: 13),
              onSaved: (value) {
                pubAddress = value;
              },
            ),
          ),
          SizedBox(
            height: 12.0,
          ),
          Text(
            S.of(context).postscript,
            style: TextStyle(
                fontSize: 17,
                color: HexColor('#FF333333'),
                fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: HexColor('#FFF2F2F2')),
              child: TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: S.of(context).postscript_hint,
                  hintStyle: TextStyle(
                    color: HexColor('#FF999999'),
                    fontSize: 13,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: HexColor('#FFF2F2F2'),
                      width: 0.5,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: HexColor('#FFF2F2F2'),
                      width: 0.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: HexColor('#FFF2F2F2'),
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
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onSaved: (value) {
                  remark = value;
                },
                style: TextStyle(
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
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
//      if (barcode.length != 130) {
//        Fluttertoast.showToast(
//            msg: S.of(context).public_key_scan_fail_rescan,
//            toastLength: Toast.LENGTH_SHORT);
//      } else {
        pubKeyTextEditController.text = barcode;
        setState(() => {});
//      }
    } catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        Fluttertoast.showToast(
            msg: S.of(context).open_camera, toastLength: Toast.LENGTH_SHORT);
      } else {
        logger.e("", e);
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
        cipherText = await reEncryptPoi(
            Injector.of(context).repository, widget.poi, remark);
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
      Share.text(
          S.of(context).share_encrypted_location, cipherText, 'text/plain');
      Navigator.pop(context, true);
    }
  }
}
