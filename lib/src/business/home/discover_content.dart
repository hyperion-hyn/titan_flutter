import 'package:flutter/material.dart';

class DiscoverContentWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DiscoverContentState();
  }
}

class _DiscoverContentState extends State<DiscoverContentWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text("发现"),
    );
  }
}
