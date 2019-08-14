import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/src/business/home/home_page.dart';

class IntroScreen extends StatefulWidget {
  IntroScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return IntroScreenState();
  }
}

class IntroScreenState extends State<IntroScreen> {
  List<Slide> slides = new List();

  @override
  void initState() {
    super.initState();
    slides.add(
      new Slide(
        backgroundImage: "res/drawable/location_privacy_zh.jpeg",
      ),
    );
    slides.add(
      new Slide(
        backgroundImage: "res/drawable/burn_zh.jpeg",
      ),
    );
    slides.add(
      new Slide(
        backgroundImage: "res/drawable/encrypted_location_zh.jpeg",
      ),
    );

//    _saveFirstRunState();
  }

  void onDonePress() {
    Navigator.pop(context);
//    Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> _onWillPop() => new Future.value(false);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: new IntroSlider(
        slides: this.slides,
        onSkipPress: this.onDonePress,
        onDonePress: this.onDonePress,
        nameSkipBtn: "跳过",
        nameNextBtn: "下一页",
        nameDoneBtn: "进入",
      ),
    );
  }
}
