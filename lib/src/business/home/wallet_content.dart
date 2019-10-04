import 'package:flutter/material.dart';
import 'package:titan/src/business/wallet/wallet_page.dart';

class WalletContentWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WalletContentState();
  }
}

class _WalletContentState extends State<WalletContentWidget> {
  @override
  Widget build(BuildContext context) {
    return WalletPage();
  }
}
