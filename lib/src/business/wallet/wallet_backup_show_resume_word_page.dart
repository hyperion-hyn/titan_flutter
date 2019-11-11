import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/wallet/wallet_backup_confirm_resume_word_page.dart';

class BackupShowResumeWordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BackupShowResumeWordState();
  }
}

class _BackupShowResumeWordState extends State<BackupShowResumeWordPage> {
  List _resumeWords = [
    "hello1",
    "hello2",
    "hello3",
    "hello4",
    "hello5",
    "hello6",
    "hello7",
    "hello8",
    "hello9",
    "hello10",
    "hello11",
    "hello12"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "您的恢复短语",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "按正确的顺序记下或复制这些单词，并将他们保存在安全的地方。",
                  style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 14),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Container(
                height: 240,
                width: 360,
                child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, mainAxisSpacing: 10.0, crossAxisSpacing: 10.0, childAspectRatio: 3),
                    itemCount: _resumeWords.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border.all(color: HexColor("#FFB7B7B7")),
                              borderRadius: BorderRadius.circular(12)),
                          child: Text("${index + 1} ${_resumeWords[index]}"));
                    }),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(color: HexColor("#FFFAEAEC")),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.notification_important,
                          color: Color(0xFFD0021B),
                        ),
                      ),
                      Flexible(
                          child: Text(
                        "永远不要与任何人共享恢复短语，安全的存储它！",
                        style: TextStyle(color: Color(0xFFD0021B)),
                        softWrap: true,
                      ))
                    ],
                  ),
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
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => BackupConfirmResumeWordPage()));
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
        ));
  }
}
