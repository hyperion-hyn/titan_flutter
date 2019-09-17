import 'package:flutter/material.dart';
import 'package:titan/src/business/wallet/wallert_backup_notice_page.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CreateAccountState();
  }
}

class _CreateAccountState extends State<CreateAccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(10),
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    shape: BoxShape.circle,
                  ),
                  child: Text("HYN"),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 64),
                  child: Text(
                    "创建一个私密账户",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration:
                        InputDecoration(labelText: "账户名称", border: OutlineInputBorder(borderSide: BorderSide())),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                        labelText: "账户密码",
                        border: OutlineInputBorder(borderSide: BorderSide()),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.remove_red_eye),
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration:
                        InputDecoration(labelText: "重复输入账户密码", border: OutlineInputBorder(borderSide: BorderSide())),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 60, left: 18, right: 18, bottom: 18),
                  child: RaisedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => BackupNoticePage()));
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
          ),
        ));
  }
}
