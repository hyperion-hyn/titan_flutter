import 'package:flutter/material.dart';
import 'package:titan/src/business/wallet/wallert_show_resume_word_page.dart';

class FinishCreatePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FinishCreateState();
  }
}

class _FinishCreateState extends State<FinishCreatePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Image.asset(
                  "res/drawable/check_outline.png",
                  height: 60,
                  width: 60,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "账户创建成功",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "恭喜，你的私密账户已经创建成功",
                  style: TextStyle(color: Color(0xFF9B9B9B)),
                ),
              ),
              SizedBox(
                height: 36,
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
                  onPressed: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "使用该私密账户",
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
