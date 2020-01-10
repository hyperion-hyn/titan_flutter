import 'package:flutter/material.dart';

@immutable
abstract class WalletManagerEvent {}

class ScanWalletEvent extends WalletManagerEvent {}

//class SwitchWalletEvent extends WalletManagerEvent {
//  final Wallet wallet;
//
//  SwitchWalletEvent(this.wallet);
//}
