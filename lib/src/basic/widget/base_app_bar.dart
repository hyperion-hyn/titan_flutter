import 'package:flutter/material.dart';
import 'package:titan/src/config/consts.dart';

class BaseAppBar extends AppBar {
  final String baseTitle;

  //final List<Widget> baseActions;
  final List<Widget> actions;
  final Widget leading;
  final Color backgroundColor;
  final bool showBottom;
  BaseAppBar({
    this.baseTitle,
    this.actions,
    this.leading,
    this.backgroundColor = Colors.white,
    this.showBottom = false,
  }) : super(
          title: Text(
            baseTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 17,
            ),
          ),
          elevation: 0,
          backgroundColor: backgroundColor,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          actions: actions,
          leading: leading,
          bottom: showBottom
              ? PreferredSize(
                  child: Container(
                    color: Theme.of(Keys.rootKey.currentContext).scaffoldBackgroundColor,
                    height: 5,
                  ),
                  preferredSize: Size.fromHeight(5))
              : null,
          /*bottom: showBottom?PreferredSize(
              child: Container(
                color: Theme.of(Keys.rootKey.currentContext).scaffoldBackgroundColor,
                height: 1,
              ),
              preferredSize: Size.fromHeight(1)):null,*/
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
