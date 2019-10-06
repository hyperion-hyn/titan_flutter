import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoadingPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: SizedBox(
            height: 32,
            width: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
            ),
          ),
        ),
      ],
    );
  }
}

class FailPanel extends StatelessWidget {
  final String message;

  FailPanel({this.message});

  @override
  Widget build(BuildContext context) {
    return Text(message ?? 'search fault');
  }
}
