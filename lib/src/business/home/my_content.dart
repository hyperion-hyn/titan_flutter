import 'package:flutter/material.dart';
import 'package:titan/src/business/my/my_page.dart';

class MyContentWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyContentState();
  }
}

class _MyContentState extends State<MyContentWidget> {
  @override
  Widget build(BuildContext context) {
    return MyPage();
  }
}
