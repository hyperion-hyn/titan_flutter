import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/presentation/extends_icon_font.dart';
import 'package:titan/src/utils/validator_util.dart';

import 'wallet_finish_import_page.dart';
import 'package:bip39/bip39.dart' as bip39;

class ImportAccountPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ImportAccountState();
  }
}

class _ImportAccountState extends State<ImportAccountPage> {
  TextEditingController _mnemonicController = TextEditingController(text: "");

  TextEditingController _walletNameController = TextEditingController();
  TextEditingController _walletPasswordController = TextEditingController();
  TextEditingController _walletConfimPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
          title: Text(
            "导入账户",
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            InkWell(
              onTap: () async {
                String mnemonicWords = await BarcodeScanner.scan();
                if (!bip39.validateMnemonic(mnemonicWords)) {
                  Fluttertoast.showToast(msg: '不是合法的助记词');
                  return;
                } else {
                  _mnemonicController.text = mnemonicWords;
                }
              },
              child: IconButton(
                icon: Icon(
                  ExtendsIconFont.qrcode_scan,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                SizedBox(
                  height: 36,
                ),
                Text(
                  "输入用空格隔开的备份助记词",
                  style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 14),
                ),
                SizedBox(
                  height: 12,
                ),
                Container(
                  constraints: BoxConstraints.expand(height: 160),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFFB7B7B7), width: 1)),
                  child: Stack(
                    children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            validator: (value) {
                              if (value.isEmpty) {
                                return "请输入助记词";
                              } else {
                                return null;
                              }
                            },
                            controller: _mnemonicController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: InputDecoration(border: InputBorder.none),
                          )),
                      Align(
                        alignment: Alignment(1, 1),
                        child: InkWell(
                          onTap: () async {
                            var mnemonicWords = (await Clipboard.getData(Clipboard.kTextPlain)).text;
                            if (!bip39.validateMnemonic(mnemonicWords)) {
                              Fluttertoast.showToast(msg: '不是合法的助记词');
                              return;
                            } else {
                              _mnemonicController.text = mnemonicWords;
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              "粘贴",
                              style: TextStyle(color: Theme.of(context).primaryColor),
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
                      "钱包名称",
                      style: TextStyle(
                        color: Color(0xFF6D6D6D),
                        fontSize: 16,
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                  child: TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return "请输入钱包名称";
                        } else if (value.length > 6) {
                          return "请输入6位以内的名称";
                        } else {
                          return null;
                        }
                      },
                      controller: _walletNameController,
                      decoration: InputDecoration(
                        hintText: "请输入6位以内的钱包名称",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      keyboardType: TextInputType.text),
                ),
                SizedBox(
                  height: 12,
                ),
                Row(
                  children: <Widget>[
                    Text(
                      "钱包密码",
                      style: TextStyle(
                        color: Color(0xFF6D6D6D),
                        fontSize: 16,
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                  child: TextFormField(
                    validator: (value) {
                      if (!ValidatorUtil.validatePassword(value)) {
                        return "请输入至少6位的密码";
                      } else {
                        return null;
                      }
                    },
                    controller: _walletPasswordController,
                    decoration: InputDecoration(
                      hintText: "请输入至少6位数的钱包密码",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                Row(
                  children: <Widget>[
                    Text(
                      "重复密码",
                      style: TextStyle(
                        color: Color(0xFF6D6D6D),
                        fontSize: 16,
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                  child: TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return "请再次输入密码";
                      } else if (value != _walletPasswordController.text) {
                        return "密码不一致";
                      } else {
                        return null;
                      }
                    },
                    controller: _walletConfimPasswordController,
                    decoration: InputDecoration(
                      hintText: "请再次输入至少6位数的钱包密码",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 16, horizontal: 36),
                  constraints: BoxConstraints.expand(height: 48),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    disabledColor: Colors.grey[600],
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    disabledTextColor: Colors.white,
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        var walletName = _walletNameController.text;
                        var password = _walletPasswordController.text;
                        var mnemonic = _mnemonicController.text;

                        try {
                          var wallet = await WalletUtil.storeByMnemonic(
                              name: walletName, password: password, mnemonic: mnemonic);
                          Navigator.push(context, MaterialPageRoute(builder: (context) => FinishImportPage(wallet)));
                        } catch (_) {
                          Fluttertoast.showToast(msg: "导入失败");
                        }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "导 入",
                            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
