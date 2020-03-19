import 'package:flutter/material.dart';
class BurningDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BurningDialogState();
  }
}

class _BurningDialogState extends State<BurningDialog> with TickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> coverOpacity;
  Animation<double> iconOpacity;
  Animation<double> iconScale;
  Animation<double> rainRadius;
  Animation<double> rainDropOpacity;

  var rainDropCurves = Interval(0, 0.6, curve: Curves.decelerate);
  var iconZoomCurves = Interval(0.6, 1.0, curve: Curves.easeInQuart);

  @override
  void initState() {
    animationController = new AnimationController(
      duration: new Duration(milliseconds: 1500),
      vsync: this,
    );

    coverOpacity = Tween<double>(begin: 0.6, end: 0.3).animate(CurvedAnimation(
      parent: animationController,
      curve: iconZoomCurves,
    ))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          Navigator.pop(context);
        }
      });
    iconScale = Tween(begin: 0.1, end: 3.0).animate(CurvedAnimation(
      parent: animationController,
      curve: iconZoomCurves,
    ));

    iconOpacity = Tween<double>(begin: 1, end: 0.3).animate(CurvedAnimation(
      parent: animationController,
      curve: iconZoomCurves,
    ));

    rainDropOpacity = Tween<double>(begin: 1, end: 0.0).animate(CurvedAnimation(
      parent: animationController,
      curve: rainDropCurves,
    ));

    rainRadius = Tween<double>(begin: 5, end: 200).animate(CurvedAnimation(
      parent: animationController,
      curve: rainDropCurves,
    ));

    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Opacity(
            opacity: coverOpacity.value,
            child: Container(
              color: Colors.black,
            )),
        Center(
            child: Container(
          child: CustomPaint(
            painter: RainDrop(rainRadius.value, rainDropOpacity.value),
          ),
        )),
        ScaleTransition(
          scale: iconScale,
          child: Opacity(
              opacity: iconOpacity.value,
              child: Container(child: Center(child: Image.asset("res/drawable/ic_logo.png")))),
        ),
      ],
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}

class RainDrop extends CustomPainter {
  Paint _paint = new Paint()..style = PaintingStyle.fill;
  double radius;
  double opacity;

  RainDrop(this.radius, this.opacity);

  @override
  void paint(Canvas canvas, Size size) {
    print("drawRainDrop");
    _paint.color = Color.fromRGBO(255, 255, 255, opacity);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius, _paint); // (4)
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
