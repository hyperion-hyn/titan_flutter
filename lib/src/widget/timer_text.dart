import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/src/utils/format_util.dart';

class TimerTextWidget extends StatefulWidget {
  final int remainTime;
  final int loopTime;
  final Function loopFunc;

  TimerTextWidget({
    @required this.remainTime,
    @required this.loopTime,
    bool isSeconds,
    this.loopFunc,
  });

  @override
  State<StatefulWidget> createState() => TimerTextState();
}

class TimerTextState extends State<TimerTextWidget> {
  Timer _timer;

  int _remainTime = 0;

  bool _isStartLoopFunc = false;

  @override
  void initState() {
    super.initState();
    _isStartLoopFunc = widget.remainTime > 0;
    _remainTime = widget.remainTime;
    _setUpTimer();
  }

  @override
  void dispose() {
    if (_timer != null) {
      if (_timer.isActive) {
        _timer.cancel();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Text(
      FormatUtil.formatTimer(_remainTime),
      style: TextStyle(
        color: Colors.white,
        fontSize: 7,
      ),
    );
  }

  _setUpTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (t) {
      setState(() {
        if (_remainTime == 0) {
          _remainTime = widget.loopTime;
          if (_isStartLoopFunc) {
            widget.loopFunc();
          }
        } else {
          _remainTime--;
        }
      });
    });
  }
}
