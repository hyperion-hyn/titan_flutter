import 'package:equatable/equatable.dart';

abstract class AppTabBarEvent extends Equatable {
  AppTabBarEvent();
}

class CheckNewAnnouncementEvent extends AppTabBarEvent {
  @override
  List<Object> get props => null;
}
