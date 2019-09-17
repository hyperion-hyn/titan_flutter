import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/wallet/wallert_backup_notice_page.dart';
import 'package:titan/src/business/wallet/wallert_confirm_resume_word_page.dart';

class ShowResumeWordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ShowResumeWordState();
  }
}

class _ShowResumeWordState extends State<ShowResumeWordPage> {
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
        appBar: AppBar(),
        body: Container(
          padding: EdgeInsets.all(10),
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
                child: Text("按正确的顺序记下或复制这些单词，并将他们保存在安全的地方。"),
              ),
              Container(
                height: 240,
                width: 360,
                child: GridView.builder(
                    gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4, mainAxisSpacing: 10.0, crossAxisSpacing: 10.0, childAspectRatio: 2),
                    itemCount: _resumeWords.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(border: Border.all(
                            color: HexColor("#FFBBBBBB")
                          )),
                          child: Text(_resumeWords[index]));
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey), color: HexColor("#223F51B5")),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.notification_important,
                          color: HexColor("#FFFF9800"),
                        ),
                      ),
                      Flexible(
                          child: Text(
                        "永远不要与任何人共享恢复短语，安全的存储它！",
                        style: TextStyle(color: HexColor("#FF3F51B5")),
                        softWrap: true,
                      ))
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 18, right: 18, bottom: 18),
                child: RaisedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ConfirmResumeWordPage()));
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
