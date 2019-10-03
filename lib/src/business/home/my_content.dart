import 'package:flutter/material.dart';

class MyContentWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MyContentState();
  }
}

class _MyContentState extends State<MyContentWidget> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      color: Theme.of(context).backgroundColor,
      alignment: Alignment.center,
      child: Text("我的"),
    );
  }
}
