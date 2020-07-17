import 'package:meta/meta.dart';

@immutable
abstract class SocketState {}

class InitialSocketState extends SocketState {}

class SubChannelSuccessState extends SocketState {}

class SubChannelFailState extends SocketState {}
