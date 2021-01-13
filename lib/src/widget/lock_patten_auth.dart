import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:gesture_unlock/lock_pattern.dart';
import 'package:gesture_unlock/lock_pattern_indicator.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/config/consts.dart';

class LockPatternVerify extends StatefulWidget {
  final Function onVerifyPassed;
  final Function onVerifyFailed;
  final String password;

  LockPatternVerify(
      {@required this.onVerifyPassed,
      @required this.onVerifyFailed,
      @required this.password});

  @override
  LockPatternVerifyState createState() {
    return LockPatternVerifyState();
  }
}

class LockPatternVerifyState extends State<LockPatternVerify> {
  var _status = LockPatternCreateStatus.Verify;
  LockPattern _lockPattern;

  @override
  Widget build(BuildContext context) {
    if (_lockPattern == null) {
      _lockPattern = LockPattern(
        padding: 30,
        onCompleted: _gestureComplete,
      );
    }
    return Container(
      padding: EdgeInsets.all(12),
      child: SizedBox(
        width: 300,
        height: 300,
        child: _lockPattern,
      ),
    );
  }

  _gestureComplete(List<int> selected, LockPatternStatus status) {
    setState(() {
      switch (_status) {
        case LockPatternCreateStatus.Verify:
        case LockPatternCreateStatus.Verify_Failed:
          var password = LockPattern.selectedToString(selected);
          Fluttertoast.showToast(msg: password);
          if (widget.password == password) {
            _lockPattern.updateStatus(LockPatternStatus.Success);
            widget.onVerifyPassed();
          } else {
            _status = LockPatternCreateStatus.Verify_Failed;
            _lockPattern.updateStatus(LockPatternStatus.Failed);
            widget.onVerifyFailed();
          }
          break;
        case LockPatternCreateStatus.Verify_Failed_Count_Overflow:
          break;
        default:
          break;
      }
    });
  }
}

class LockPatternCreate extends StatefulWidget {
  final Function onPatternCreated;

  LockPatternCreate({
    this.onPatternCreated(String password),
  });

  @override
  LockPatternCreateState createState() {
    return LockPatternCreateState();
  }
}

class LockPatternCreateState extends State<LockPatternCreate> {
  var _status = LockPatternCreateStatus.Create;
  var _msg = S.of(Keys.rootKey.currentContext).please_draw_unlock_gasture;
  var _gesturePassword;
  LockPatternIndicator _indicator;
  LockPattern _lockPattern;

  @override
  Widget build(BuildContext context) {
    if (_indicator == null) {
      _indicator = LockPatternIndicator();
    }
    if (_lockPattern == null) {
      _lockPattern = LockPattern(
        type: LockPatternType.Solid,
        padding: 30,
        onCompleted: _gestureComplete,
      );
    }
    return Container(
      padding: EdgeInsets.all(12),
      child: Column(
        children: <Widget>[
          Center(
            child: SizedBox(
              width: 60,
              height: 60,
              child: _indicator,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 12, bottom: 12),
            child: Center(
              child: Text(
                _msg,
                style: TextStyle(
                    color: (_status == LockPatternCreateStatus.Verify_Failed ||
                            _status == LockPatternCreateStatus.Create_Failed)
                        ? Colors.red
                        : Colors.black),
              ),
            ),
          ),
          Center(
            child: SizedBox(
              width: 300,
              height: 300,
              child: _lockPattern,
            ),
          )
        ],
      ),
    );
  }

  _gestureComplete(List<int> selected, LockPatternStatus status) {
    setState(() {
      switch (_status) {
        case LockPatternCreateStatus.Create:
        case LockPatternCreateStatus.Create_Failed:
          if (selected.length < 4) {
            _msg = S.of(context).number_connections_less_than_four;
            _status = LockPatternCreateStatus.Create_Failed;
            _lockPattern.updateStatus(LockPatternStatus.Failed);
          } else {
            _msg = S.of(context).please_verify_gasture_again;
            _gesturePassword = LockPattern.selectedToString(selected);
            _status = LockPatternCreateStatus.Verify;
            _lockPattern.updateStatus(LockPatternStatus.Success);
            _indicator.setSelectPoint(selected);
          }
          break;
        case LockPatternCreateStatus.Verify:
        case LockPatternCreateStatus.Verify_Failed:
          var password = LockPattern.selectedToString(selected);
          if (_gesturePassword == password) {
            _msg = S.of(context).setting_successful_gasture_password_is(password);
            widget.onPatternCreated(password);
            _lockPattern.updateStatus(LockPatternStatus.Success);
          } else {
            _msg = S.of(context).verification_failed_try_again;
            _status = LockPatternCreateStatus.Verify_Failed;
            _lockPattern.updateStatus(LockPatternStatus.Failed);
          }
          break;
        case LockPatternCreateStatus.Verify_Failed_Count_Overflow:
          break;
      }
    });
  }
}

enum LockPatternCreateStatus {
  Create,
  Create_Failed,
  Verify,
  Verify_Failed,
  Verify_Failed_Count_Overflow
}
