import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:titan/src/pages/news/model/news_detail.dart';

abstract class AppTabBarState {}

class InitialAppTabBarState extends AppTabBarState {
  @override
  List<Object> get props => [];
}

class CheckNewAnnouncementState extends AppTabBarState {
  NewsDetail announcement;
  CheckNewAnnouncementState({this.announcement});
}

class BottomNavigationBarState extends AppTabBarState with EquatableMixin {
  final bool isHided;

  BottomNavigationBarState({@required this.isHided});

  @override
  List<Object> get props => [isHided];

  @override
  bool get stringify => true;
}
