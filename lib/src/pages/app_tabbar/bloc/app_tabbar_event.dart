import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

abstract class AppTabBarEvent {
  AppTabBarEvent();
}

class CheckNewAnnouncementEvent extends AppTabBarEvent {}

class BottomNavigationBarEvent extends AppTabBarEvent {
  final bool isHided;

  BottomNavigationBarEvent({@required this.isHided});
}
