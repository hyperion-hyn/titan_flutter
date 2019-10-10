import 'package:flutter/material.dart';
import 'package:titan/src/business/me/service/user_service.dart';

import '../../global.dart';

abstract class UserState<T extends StatefulWidget> extends State<T> {
  UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  Future getUserInfo() async {
    LOGIN_USER_INFO = await _userService.getUserInfo();
    if (mounted) {
      setState(() {});
    }
  }
}
