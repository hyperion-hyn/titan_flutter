import 'package:flutter/material.dart';
import 'package:titan/src/global.dart';

class Map3NodeIntroductionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Map3IntroductionState();
  }
}

class _Map3IntroductionState extends State<Map3NodeIntroductionPage> {
  @override
  Widget build(BuildContext context) {
    var image;
    if (appLocale.languageCode == "zh") {
      image = "res/drawable/map3_node_introduction.jpeg";
    } else {
      image = "res/drawable/map3_node_introduction_en.jpg";
    }
    return SingleChildScrollView(child: Padding(padding: const EdgeInsets.all(16.0), child: Image.asset(image)));
  }
}
