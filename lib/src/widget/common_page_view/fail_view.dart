import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/l10n.dart';

class FailView extends StatelessWidget {
  final Function onRetry;
  final String message;

  FailView({this.onRetry, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image.asset('res/drawable/load_fail.png', width: 100.0),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              message,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          FlatButton(
              onPressed: onRetry,
              child: Text(
                S.of(context).click_retry,
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontSize: 16,
                ),
              )),
        ],
      ),
    );
  }
}
