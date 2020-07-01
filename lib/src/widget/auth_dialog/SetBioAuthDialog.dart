import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/widget/click_oval_button.dart';
import 'package:titan/src/widget/enter_wallet_password.dart';

class SetBioAuthDialog extends StatefulWidget {
  final BiometricType biometricType;

  SetBioAuthDialog(this.biometricType);

  @override
  BaseState<StatefulWidget> createState() {
    return _SetBioAuthDialogState();
  }
}

class _SetBioAuthDialogState extends BaseState<SetBioAuthDialog> {
  void initState() {
    super.initState();
    // TODO: implement initState
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void onCreated() {
    // TODO: implement onCreated
    super.onCreated();
  }

  @override
  Widget build(BuildContext context) {
    Duration insetAnimationDuration = const Duration(milliseconds: 100);
    Curve insetAnimationCurve = Curves.decelerate;
    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets +
          const EdgeInsets.symmetric(horizontal: 32.0),
      duration: insetAnimationDuration,
      curve: insetAnimationCurve,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '生物识别',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _content()
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _content() {
    if (widget.biometricType == BiometricType.face) {
      return _faceAuthWidget();
    } else {
      return _fingerprintAuthWidget();
    }
  }

  _faceAuthWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'res/drawable/ic_face_id.png',
            width: 80,
            height: 80,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('您的设备支持面容识别功能，是否开启面容识别？'),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              Spacer(),
              InkWell(
                child: Text('暂不开启'),
                onTap: () {
                  Navigator.of(context).pop(false);
                },
              ),
              SizedBox(
                width: 32.0,
              ),
              ClickOvalButton(
                '开启',
                () {
                  Navigator.of(context).pop(true);
                },
                width: 120,
              ),
              Spacer()
            ],
          ),
        )
      ],
    );
  }

  _fingerprintAuthWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'res/drawable/ic_fingerprint.png',
            width: 80,
            height: 80,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '您的设备支持指纹识别功能，是否开启指纹识别？',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              Spacer(),
              Text('暂不开启'),
              SizedBox(
                width: 32.0,
              ),
              ClickOvalButton(
                '开启',
                () {},
                width: 120,
              ),
              Spacer()
            ],
          ),
        )
      ],
    );
  }
}
