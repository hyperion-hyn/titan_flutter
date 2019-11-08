import 'package:flutter/material.dart';
import 'package:titan/src/business/wallet/wallert_backup_show_resume_word_page.dart';

class WalletBackupNoticePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WalletBackupNoticeState();
  }
}

class _WalletBackupNoticeState extends State<WalletBackupNoticePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          "备份提示",
                          style: TextStyle(fontSize: 22, color: Color(0xFF252525)),
                        ),
                      ),
                      Text(
                        "获得助记词等于拥有钱包资产所有权",
                        style: TextStyle(fontSize: 14, color: Color(0xFF9B9B9B)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Image.asset(
                          "res/drawable/backup_notice_image.png",
                          height: 128,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("●"),
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "备份助记次",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Text(
                          "使用纸和笔正确抄写助记词\n如果你的手机丢失、被盗。损坏，助记词将可以恢复你的资产",
                          style: TextStyle(fontSize: 15, color: Color(0xFF6D6D6D)),
                        )
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("●"),
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "离线保管",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Text(
                          "妥善保管至隔离网络的安全地方\n请勿讲助记词在联网环境下分享和存储，比如邮件、相册、社交应用等",
                          style: TextStyle(fontSize: 15, color: Color(0xFF6D6D6D)),
                        )
                      ],
                    ),
                  )
                ],
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 30, horizontal: 36),
                constraints: BoxConstraints.expand(height: 48),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  disabledColor: Colors.grey[600],
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  disabledTextColor: Colors.white,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => BackupShowResumeWordPage()));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "下一步",
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
    );
  }
}
