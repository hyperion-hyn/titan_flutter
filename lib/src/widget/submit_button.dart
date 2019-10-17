import 'package:flutter/material.dart';
import 'package:loading/indicator/ball_spin_fade_loader_indicator.dart';
import 'package:loading/loading.dart';

class SubmitButton extends StatelessWidget {
  bool isWaiting;
  String waitingText;
  String text;
  VoidCallback onPress;

  SubmitButton({@required this.isWaiting, @required this.waitingText, @required this.text, @required this.onPress});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      disabledColor: Colors.grey[600],
      color: Theme.of(context).primaryColor,
      textColor: Colors.white,
      disabledTextColor: Colors.white,
      onPressed: onPress,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (isWaiting)
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: SizedBox(
                    height: 30,
                    width: 30,
                    child: Loading(
                      indicator: BallSpinFadeLoaderIndicator(),
                    )),
              ),
            Text(
              isWaiting ? waitingText : text,
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
            ),
          ],
        ),
      ),
    );
    ;
  }
}
