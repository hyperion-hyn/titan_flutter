import 'package:flutter/material.dart';

class Map3NodeIntroductionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Map3IntroductionState();
  }
}

class _Map3IntroductionState extends State<Map3NodeIntroductionPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(16.0), child: Image.asset("res/drawable/map3_node_introduction.jpeg")));
  }
}
