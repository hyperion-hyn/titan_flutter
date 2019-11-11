import 'package:flutter/material.dart';
import 'package:titan/src/presentation/extends_icon_font.dart';
import 'package:titan/src/utils/validator_util.dart';

import 'wallet_finish_import_page.dart';

class ImportAccountPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ImportAccountState();
  }
}

class _ImportAccountState extends State<ImportAccountPage> {
  TextEditingController _accountNameTEController = TextEditingController(text: "我的账户名称");

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
            IconButton(
              icon: Icon(
                ExtendsIconFont.qrcode_scan,
                color: Colors.white,
              ),
            )
          ],
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: <Widget>[
              SizedBox(
                height: 36,
              ),
              Text(
                "输入12个用空格隔开的备份助记词",
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
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: InputDecoration(border: InputBorder.none),
                        )),
                    Align(
                      alignment: Alignment(1, 1),
                      child: InkWell(
                        onTap: () {},
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
                      if (!ValidatorUtil.validateCode(6, value)) {
                        return "请输入6位邀请码";
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
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
                      if (!ValidatorUtil.validateCode(6, value)) {
                        return "请输入6位邀请码";
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
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
                      if (!ValidatorUtil.validateCode(6, value)) {
                        return "请输入6位邀请码";
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    keyboardType: TextInputType.text),
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
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FinishImportPage()));
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
        ));
  }
}
