import 'package:flutter/material.dart';

@immutable
abstract class WalletState {}

class WalletEmptyState extends WalletState {}

class CreateNewWalletState extends WalletState {}
