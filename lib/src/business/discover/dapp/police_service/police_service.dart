import 'package:flutter/widgets.dart';

class PoliceService extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PoliceServiceState();
  }

}

class PoliceServiceState extends State<PoliceService> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('我是警察助手dapp'),
    );
  }

}