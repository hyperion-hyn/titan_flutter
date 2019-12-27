import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DiscoverPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DiscoverPageState();
  }
}

class DiscoverPageState extends State<DiscoverPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('发现'),
      ),
      body: Text('发现'),
    );
  }
}
