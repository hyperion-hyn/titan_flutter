import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

abstract class AppTabBarEvent {
  AppTabBarEvent();
}

class InitialAppTabBarEvent extends AppTabBarEvent {
}

class CheckNewAnnouncementEvent extends AppTabBarEvent {}

class BottomNavigationBarEvent extends AppTabBarEvent {
  final bool isHided;

  BottomNavigationBarEvent({@required this.isHided});
}

class ChangeTabBarItemEvent extends AppTabBarEvent {
  int index;
  ChangeTabBarItemEvent({this.index});
}

class ChangeNodeTabBarItemEvent extends AppTabBarEvent {
  int index;
  ChangeNodeTabBarItemEvent({this.index});
}