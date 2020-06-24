import 'package:flutter/material.dart';
import 'package:gesture_unlock/lock_pattern.dart';

class GestureUnlockWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GestureUnlockWidgeState();
  }
}

class _GestureUnlockWidgeState extends State<GestureUnlockWidget> {
  @override
  Widget build(BuildContext context) {
    var _status = GestureCreateStatus.Create;
    LockPattern _lockPattern;

    _lockPattern = LockPattern(
      type: LockPatternType.Solid,
      padding: 30,
      onCompleted: _gestureComplete,
    );

    return SizedBox(
      width: 300,
      height: 300,
      child: LockPattern(
        type: LockPatternType.Solid,
      ),
    );
  }

  _gestureComplete(List<int> selected, LockPatternStatus status) {

//    setState(() {
//      switch (_status) {
//        case GestureCreateStatus.Create:
//        case GestureCreateStatus.Create_Failed:
//          if (selected.length < 4) {
//            _msg = "连接数不能小于4个，请重新尝试";
//            _status = GestureCreateStatus.Create_Failed;
//            _lockPattern.updateStatus(LockPatternStatus.Failed);
//          } else {
//            _msg = "请再次验证手势";
//            _gesturePassword = LockPattern.selectedToString(selected);
//            _status = GestureCreateStatus.Verify;
//            _lockPattern.updateStatus(LockPatternStatus.Success);
//            _indicator.setSelectPoint(selected);
//          }
//          break;
//        case GestureCreateStatus.Verify:
//        case GestureCreateStatus.Verify_Failed:
//          var password = LockPattern.selectedToString(selected);
//          if (_gesturePassword == password) {
//            _msg = "设置成功,手势密码为$password";
//            Strings.gesturePassword = password;
//            _lockPattern.updateStatus(LockPatternStatus.Success);
//          } else {
//            _msg = "验证失败，请重新尝试";
//            _status = GestureCreateStatus.Verify_Failed;
//            _lockPattern.updateStatus(LockPatternStatus.Failed);
//          }
//          break;
//        case GestureCreateStatus.Verify_Failed_Count_Overflow:
//          break;
//      }
//    });
  }
}

enum GestureCreateStatus {
  Create,
  Create_Failed,
  Verify,
  Verify_Failed,
  Verify_Failed_Count_Overflow
}
