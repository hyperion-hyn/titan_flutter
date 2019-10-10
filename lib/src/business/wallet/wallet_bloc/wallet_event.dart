import 'package:flutter/material.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

@immutable
abstract class WalletEvent {}

class ScanWalletEvent extends WalletEvent {}
