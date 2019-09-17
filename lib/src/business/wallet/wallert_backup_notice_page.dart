import 'package:flutter/material.dart';
import 'package:titan/src/business/wallet/wallert_show_resume_word_page.dart';

class BackupNoticePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BackupNoticePageState();
  }
}

class _BackupNoticePageState extends State<BackupNoticePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Container(
          padding: EdgeInsets.all(10),
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "现在备份你的账户",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("在下一步中，您将看到12个允许您恢复账户的单词"),
              ),
              Spacer(),
              Row(
                children: <Widget>[
                  Checkbox(
                    value: false,
                    onChanged: (isSelect) {},
                  ),
                  Flexible(
                    child: Text(
                      "我明白，如果我丢失了恢复单词，我将无法访问我的账户。",
                      softWrap: true,
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 60, left: 18, right: 18, bottom: 18),
                child: RaisedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ShowResumeWordPage()));
                  },
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 128.0, vertical: 16.0),
                      child: Text(
                        "继续",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  color: Colors.blue,
                ),
              )
            ],
          ),
        ));
  }
}
