import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_pickers/UIConfig.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:r_scan/r_scan.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/config/extends_icon_font.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/validator_util.dart';
import 'package:titan/src/widget/keyboard/wallet_password_dialog.dart';

import 'wallet_finish_import_page.dart';
import 'package:bip39/bip39.dart' as bip39;

class ImportAccountPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ImportAccountState();
  }
}

class _ImportAccountState extends BaseState<ImportAccountPage> {
  TextEditingController _mnemonicController = TextEditingController(text: "");

  TextEditingController _walletNameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isShowPassword = false;

  @override
  void onCreated() async {
    await availableRScanCameras();
    super.onCreated();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          centerTitle: true,
          title: Text(
            S.of(context).import_account,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
          actions: <Widget>[
            InkWell(
              onTap: () async {
                _openModalBottomSheet();
                /*String mnemonicWords = await BarcodeScanner.scan();
                if (!bip39.validateMnemonic(mnemonicWords)) {
                  Fluttertoast.showToast(msg: S.of(context).illegal_mnemonic);
                  return;
                } else {
                  _mnemonicController.text = mnemonicWords;
                }*/
              },
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 8.0, bottom: 8, left: 15, right: 15),
                child: Icon(
                  ExtendsIconFont.qrcode_scan,
                  color: Colors.black,
                ),
              ),
            ),
            /*InkWell(
              onTap: () async {
                var themeColor = '#${Theme.of(context).primaryColor.value.toRadixString(16)}';
                List<Asset> resultList = await MultiImagePicker.pickImages(
                  maxImages: 1,
                  enableCamera: true,
                  cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
                  materialOptions: MaterialOptions(
                    actionBarColor: themeColor,
                    actionBarTitle: "选择二维码图片",
                    allViewTitle: "All Photos",
                    useDetailsView: false,
                    selectCircleStrokeColor: "#ffffff",
                  ),
                );
                if(resultList.length > 0){
                  var filePath = await FlutterAbsolutePath.getAbsolutePath(resultList[0].identifier);
                  RScanResult mnemonicWords = await RScan.scanImagePath(filePath);
                  if (mnemonicWords == null || !bip39.validateMnemonic(mnemonicWords.message)) {
                    Fluttertoast.showToast(msg: S.of(context).illegal_mnemonic);
                    return;
                  } else {
                    _mnemonicController.text = mnemonicWords.message;
                  }
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.image,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            )*/
          ],
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            // hide keyboard when touch other widgets
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  SizedBox(
                    height: 36,
                  ),
                  Text(
                    S.of(context).input_resume_mnemonic,
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Container(
                    constraints: BoxConstraints.expand(height: 120),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFFB7B7B7), width: 1)),
                    child: Stack(
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8),
                            child: TextFormField(
                              validator: (value) {
                                if (value.isEmpty) {
                                  return S.of(context).please_input_mnemonic;
                                } else {
                                  return null;
                                }
                              },
                              controller: _mnemonicController,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              decoration:
                                  InputDecoration(border: InputBorder.none),
                            )),
                        Align(
                          alignment: Alignment(1, 1),
                          child: InkWell(
                            onTap: () async {
                              var mnemonicWords = (await Clipboard.getData(
                                      Clipboard.kTextPlain))
                                  ?.text;
                              if (mnemonicWords == null ||
                                  mnemonicWords == '') {
                                print('no clipboard word');
                                return;
                              }
                              if (!bip39.validateMnemonic(mnemonicWords)) {
                                Fluttertoast.showToast(
                                    msg: S.of(context).illegal_mnemonic);
                                return;
                              } else {
                                _mnemonicController.text = mnemonicWords;
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                S.of(context).paste,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        S.of(context).wallet_name_label,
                        style: TextStyle(
                            color: HexColor('#333333'),
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                    child: TextFormField(
                        validator: (value) {
                          if (value.isEmpty) {
                            return S.of(context).input_wallet_name_hint;
                          } else {
                            return null;
                          }
                        },
                        controller: _walletNameController,
                        decoration: InputDecoration(
                          hintText: S.of(context).input_wallet_name_length_hint,
                          hintStyle: TextStyle(
                            color: HexColor('#FF999999'),
                            fontSize: 13,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: HexColor('#FFD0D0D0'),
                              width: 0.5,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: HexColor('#FFD0D0D0'),
                              width: 0.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: HexColor('#FFD0D0D0'),
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
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(6),
                        ],
                        keyboardType: TextInputType.text),
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(16, 24, 16, 48),
                    constraints: BoxConstraints.expand(height: 48),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      disabledColor: Colors.grey[600],
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      disabledTextColor: Colors.white,
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          var walletName = _walletNameController.text;
                          var password =
                              await UiUtil.showDoubleCheckPwdDialog(context);

                          var mnemonic = _mnemonicController.text.trim();
                          if (!bip39.validateMnemonic(mnemonic)) {
                            Fluttertoast.showToast(
                                msg: S.of(context).illegal_mnemonic);
                            return;
                          }

                          try {
                            var wallet = await WalletUtil.storeByMnemonic(
                                name: walletName,
                                password: password,
                                mnemonic: mnemonic);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        FinishImportPage(wallet)));
                          } catch (_) {
                            Fluttertoast.showToast(
                                msg: S.of(context).import_account_fail);
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              S.of(context).import,
                              style: TextStyle(
                                  fontWeight: FontWeight.normal, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Future _openModalBottomSheet() async {
    final option = await showModalBottomSheet(
        context: context,
        builder: (BuildContext dialogContext) {
          return Wrap(
            children: <Widget>[
              ListTile(
                title: Text(S.of(context).camera_scan,
                    textAlign: TextAlign.center),
                onTap: () async {
                  Future.delayed(Duration(milliseconds: 500), () {
                    Navigator.pop(dialogContext);
                  });
                  String mnemonicWords = await BarcodeScanner.scan();
                  if (!bip39.validateMnemonic(mnemonicWords)) {
                    Fluttertoast.showToast(msg: S.of(context).illegal_mnemonic);
                  } else {
                    _mnemonicController.text = mnemonicWords;
                  }
                },
              ),
              ListTile(
                title: Text(S.of(context).import_from_album,
                    textAlign: TextAlign.center),
                onTap: () async {
                  Future.delayed(Duration(milliseconds: 500), () {
                    Navigator.pop(dialogContext);
                  });

                  var tempListImagePaths = await ImagePickers.pickerPaths(
                    galleryMode: GalleryMode.image,
                    selectCount: 1,
                    showCamera: true,
                    cropConfig: null,
                    compressSize: 500,
                    uiConfig: UIConfig(uiThemeColor: Color(0xff0f95b0)),
                  );
                  if (tempListImagePaths != null &&
                      tempListImagePaths.length == 1) {
                    RScanResult mnemonicWords =
                        await RScan.scanImagePath(tempListImagePaths[0].path);
                    if (mnemonicWords == null ||
                        !bip39.validateMnemonic(mnemonicWords.message)) {
                      Fluttertoast.showToast(
                          msg: S.of(context).illegal_mnemonic);
                    } else {
                      _mnemonicController.text = mnemonicWords.message;
                    }
                  }

                  /*var themeColor = '#${Theme.of(context).primaryColor.value.toRadixString(16)}';
                  List<Asset> resultList = await MultiImagePicker.pickImages(
                    maxImages: 1,
                    enableCamera: true,
                    cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
                    materialOptions: MaterialOptions(
                      statusBarColor: themeColor,
                      actionBarColor: themeColor,
                      actionBarTitle: S.of(context).select_qrcode_picture,
                      allViewTitle: S.of(context).all_picture,
                      useDetailsView: false,
                      selectCircleStrokeColor: "#ffffff",
                    ),
                  );

                  if(resultList.length > 0){
                  var filePath = await FlutterAbsolutePath.getAbsolutePath(resultList[0].identifier);
                    RScanResult mnemonicWords = await RScan.scanImagePath(filePath);
                    if (mnemonicWords == null || !bip39.validateMnemonic(mnemonicWords.message)) {
                      Fluttertoast.showToast(msg: S.of(context).illegal_mnemonic);
                    } else {
                      _mnemonicController.text = mnemonicWords.message;
                    }
                  }*/
                },
              ),
              ListTile(
                title: Text(S.of(context).cancel, textAlign: TextAlign.center),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
}
