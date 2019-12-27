import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class WalletPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WalletPageState();
  }
}

class WalletPageState extends State<WalletPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('钱包'),
      ),
      body: Text('钱包'),
    );
  }
}
