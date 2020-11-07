import 'package:flutter/material.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_node_tabs_page.dart';
import 'package:titan/src/widget/map3_nodes_widget.dart';

import 'atlas_map_widget.dart';

class WidgetDemoPage extends StatefulWidget {
  WidgetDemoPage();

  @override
  State<StatefulWidget> createState() {
    return _WidgetDemoPageState();
  }
}

class _WidgetDemoPageState extends State<WidgetDemoPage> {
  ///
  Widget child = Container();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Widget Demo',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[],
        ),
      ),
    );
  }
}
