import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/src/widget/progress_dialog_mask/bloc/bloc.dart';
import 'package:titan/src/widget/progress_dialog_mask/progress_mask_dialog.dart';

class UtilUi {
  static double getRenderObjectHeight(GlobalKey key) {
    RenderBox renderBox = key.currentContext?.findRenderObject();
    var h = renderBox?.size?.height ?? 0;
    return h;
  }

  static ProgressMaskDialogBloc showMaskDialog(BuildContext context) {
    var _progressMaskDialogBloc = ProgressMaskDialogBloc();
    showDialog(
        context: context,
        builder: (context) {
          return ProgressMaskDialog(
            bloc: _progressMaskDialogBloc,
          );
        });
    return _progressMaskDialogBloc;
  }

  static toast(String message) {
    Fluttertoast.showToast(msg: message, backgroundColor: Colors.black, textColor: Colors.white);
  }
}
