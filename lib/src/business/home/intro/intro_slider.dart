import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/generated/i18n.dart';
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
  }

  @override
  void didChangeDependencies() {
    _initSlides();
  }

  void _initSlides() {
    var privacyImage = "";
    var burningImage = "";
    var encryptedImage = "";

    var languageCode = Localizations.localeOf(context).languageCode;
    if (languageCode == "zh") {
      privacyImage = "res/drawable/location_privacy_zh.jpeg";
      burningImage = "res/drawable/burn_zh.jpeg";
      encryptedImage = "res/drawable/encrypted_location_zh.jpeg";
    } else {
      privacyImage = "res/drawable/location_privacy.jpeg";
      burningImage = "res/drawable/burn.jpeg";
      encryptedImage = "res/drawable/encrypted_location.jpeg";
    }
    slides.add(
      new Slide(
        backgroundOpacityColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        backgroundImage: privacyImage,
      ),
    );
    slides.add(
      new Slide(
        backgroundOpacityColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        backgroundImage: burningImage,
      ),
    );
    slides.add(
      new Slide(
        backgroundOpacityColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        backgroundImage: encryptedImage,
      ),
    );
  }

  void onDonePress() {
    Navigator.pop(context, "done");
//    Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
    _saveFirstRunState();
  }

  void _saveFirstRunState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isFirstRun', false);
//    setState(() {});
//    _isNeedShowIntro();
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
        nameSkipBtn: S.of(context).skip,
        nameNextBtn: S.of(context).Next,
        nameDoneBtn: S.of(context).enter,
      ),
    );
  }
}
