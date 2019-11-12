import 'package:flutter/material.dart';
import 'package:titan/src/business/wallet/wallet_create_backup_notice_page.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/utils/validator_util.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CreateAccountState();
  }
}

class _CreateAccountState extends State<CreateAccountPage> {
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
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            "创建钱包",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    width: 72,
                    height: 72,
                    child: Image.asset("res/drawable/hyn_icon.png"),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 64),
                    child: Text(
                      "创建一个私密账户",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                    child: TextFormField(
                        validator: (value) {
                          if (value.isEmpty) {
                            return "请输入正确的钱包名称";
                          } else {
                            return null;
                          }
                        },
                        controller: _walletNameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        keyboardType: TextInputType.text),
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
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
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
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        "重复输入钱包密码",
                        style: TextStyle(
                          color: Color(0xFF6D6D6D),
                          fontSize: 16,
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
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
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 16),
                    constraints: BoxConstraints.expand(height: 48),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      disabledColor: Colors.grey[600],
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      disabledTextColor: Colors.white,
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          var walletName = _walletNameController.text;
                          var password = _walletPasswordController.text;

                          createWalletNameTemp = walletName;
                          createWalletPasswordTemp = password;
                          Navigator.push(
                              context, MaterialPageRoute(builder: (context) => CreateWalletBackupNoticePage()));
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "继续",
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
          ),
        ));
  }
}
