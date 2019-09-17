import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/wallet/wallert_backup_notice_page.dart';
import 'package:titan/src/business/wallet/wallert_finish_create_page.dart';

class ConfirmResumeWordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ConfirmResumeWordState();
  }
}

class _ConfirmResumeWordState extends State<ConfirmResumeWordPage> {
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

  List _selectedResumeWords = [
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
                  "输入恢复短语",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("点击单词，把他们按正确的顺序放在一起"),
              ),
              Container(
                height: 180,
                width: 360,
                color: HexColor("#2D101010"),
                child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4, mainAxisSpacing: 10.0, crossAxisSpacing: 10.0, childAspectRatio: 2),
                    itemCount: _resumeWords.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(border: Border.all(color: HexColor("#FFBBBBBB"))),
                          child: Text(_resumeWords[index]));
                    }),
              ),
              Container(
                height: 10,
              ),
              Container(
                height: 180,
                width: 360,
                child: GridView.builder(
                    gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4, mainAxisSpacing: 10.0, crossAxisSpacing: 10.0, childAspectRatio: 2),
                    itemCount: _resumeWords.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(border: Border.all(color: HexColor("#FFBBBBBB"))),
                          child: Text(_resumeWords[index]));
                    }),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 18, right: 18, bottom: 18),
                child: RaisedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FinishCreatePage()));
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
