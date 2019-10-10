import 'package:flutter/material.dart';
import 'package:titan/src/business/wallet/wallert_show_resume_word_page.dart';

class FinishImportPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FinishImportState();
  }
}

class _FinishImportState extends State<FinishImportPage> {
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
                  "账户导入成功",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("恭喜，你的私密账户已经创导入成功"),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(top: 60, left: 18, right: 18, bottom: 18),
                child: RaisedButton(
                  onPressed: () {
//                    Navigator.push(context, MaterialPageRoute(builder: (context) => ShowResumeWordPage()));
                  },
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 80.0, vertical: 16.0),
                      child: Text(
                        "使用该私密账户",
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
