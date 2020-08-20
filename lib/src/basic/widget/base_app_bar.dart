import 'package:flutter/material.dart';

class BaseAppBar extends AppBar {
  final String baseTitle;

  BaseAppBar({this.baseTitle})
      : super(
          title: Text(
            baseTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
        );
}
