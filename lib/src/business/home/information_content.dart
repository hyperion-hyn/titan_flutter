import 'package:flutter/material.dart';

class InformationContentWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _InformationContentState();
  }
}

class _InformationContentState extends State<InformationContentWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text("信息"),
    );
  }
}
