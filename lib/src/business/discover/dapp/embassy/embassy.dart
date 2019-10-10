import 'package:flutter/widgets.dart';

class Embassy extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return EmbassyState();
  }
}

class EmbassyState extends State<Embassy> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('我是大使馆dapp'),
    );
  }
}
