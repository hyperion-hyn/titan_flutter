import 'package:flutter/material.dart';

class WalletContentWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WalletContentState();
  }
}

class _WalletContentState extends State<WalletContentWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      alignment: Alignment.center,
      child: Text("钱包"),
    );
  }
}
