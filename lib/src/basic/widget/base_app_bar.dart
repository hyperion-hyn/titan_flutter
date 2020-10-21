import 'package:flutter/material.dart';

class BaseAppBar extends AppBar {
  final String baseTitle;
  //final List<Widget> baseActions;
  final List<Widget> actions;
  final Widget leading;

  BaseAppBar({this.baseTitle, this.actions, this.leading})
      : super(
          title: Text(
            baseTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 17,
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          actions: actions,
          leading: leading,
        );
}

class BaseGestureDetector extends GestureDetector {
  BaseGestureDetector({BuildContext context, Widget child})
      : super(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            // hide keyboard when touch other widgets
            //print("[Gesture] hide keyboard when touch other widgets");
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: child,
        );
}