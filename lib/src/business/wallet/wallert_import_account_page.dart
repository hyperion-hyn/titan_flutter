import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/wallet/wallert_backup_notice_page.dart';
import 'package:titan/src/business/wallet/wallert_confirm_resume_word_page.dart';
import 'package:titan/src/presentation/extends_icon_font.dart';

import 'wallert_finish_import_page.dart';

class ImportAccountPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ImportAccountState();
  }
}

class _ImportAccountState extends State<ImportAccountPage> {
  TextEditingController _accountNameTEController = TextEditingController(text: "我的账户名称");
  BoxDecoration _boxDecoration =
      BoxDecoration(color: Colors.white, border: Border.all(color: HexColor("#FFBBBBBB"), width: 1));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("导入账户"),
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
          color: HexColor("#FFE3E3E3"),
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 48),
                child: Container(
                  constraints: BoxConstraints.expand(height: 160),
                  decoration: _boxDecoration,
                  child: Stack(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("输入12个用空格隔开的备份助记词", style: TextStyle(color: HexColor("#FF7B7676"))),
                      ),
                      Align(
                        alignment: Alignment(1, 1),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "粘贴",
                            style: TextStyle(color: HexColor("#FF3F51B5")),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  decoration: _boxDecoration,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "名称",
                          style: TextStyle(color: HexColor("#FF7B7676")),
                        ),
                        TextField(
                          controller: _accountNameTEController,
                          decoration: InputDecoration(border: InputBorder.none),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  decoration: _boxDecoration,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "输入密码",
                          style: TextStyle(color: HexColor("#FF7B7676")),
                        ),
                        TextField(
                          obscureText: true,
                          decoration: InputDecoration(border: InputBorder.none),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Container(
                  decoration: _boxDecoration,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "重复密码",
                          style: TextStyle(color: HexColor("#FF7B7676")),
                        ),
                        TextField(
                          obscureText: true,
                          decoration: InputDecoration(border: InputBorder.none),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 40, right: 40),
                child: RaisedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FinishImportPage()));
                  },
                  color: HexColor("#FF1AAD19"),
                  child: Text(
                    "导入",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
