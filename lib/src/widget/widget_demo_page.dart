import 'package:flutter/material.dart';
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
      body: Column(
        children: <Widget>[
          Map3NodesWidget(),
          SizedBox(
            height: 16,
          ),
          Container(
            child: AtlasMapWidget(),
            width: double.infinity,
            height: 250,
          ),
        ],
      ),
    );
  }
}
