import 'package:flutter/material.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_node_tabs_page.dart';
import 'package:titan/src/widget/clip_tab_bar.dart';
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
  String content = '';

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
          children: <Widget>[
            _tabsView(),
            Container(
              color: Colors.black.withOpacity(0.5),
              child: _tab(),
            ),
            ClipTabBar(
              children: [
                Text('0'),
                Text('1'),
              ],
              onTabChanged: (index) {
                setState(() {
                  content = index.toString();
                });
              },
            ),
            Text(content)
          ],
        ),
      ),
    );
  }

  _tabsView() {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(16.0),
      ),
      child: Column(
        children: [
          Container(
            height: 50,
            color: Colors.black.withOpacity(0.5),
            child: Stack(
              children: [
                Container(
                  height: 50,
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {},
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16.0),
                              bottomRight: Radius.circular(16.0),
                            ),
                            child: Container(
                              color: Colors.transparent,
                              child: Center(
                                child: Text(
                                  'Map3',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {},
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16.0),
                            ),
                            child: Container(
                              color: Colors.white,
                              child: Center(
                                child: Text(
                                  'Atlas',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            height: 20,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  var isLeft = true;

  _tab() {
    return Stack(
      children: [
        ClipPath(
          child: Container(
            width: double.infinity,
            height: 50,
            color: Colors.white,
          ),
          clipper: isLeft ? LeftTabClipPath() : RightTabClipPath(),
        ),
        Container(
          width: double.infinity,
          height: 50,
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  child: Container(
                    child: Center(child: Text('Map3')),
                  ),
                  onTap: () {
                    setState(() {
                      isLeft = true;
                    });
                  },
                ),
              ),
              Expanded(
                child: InkWell(
                  child: Container(
                    child: Center(child: Text('Atlas')),
                  ),
                  onTap: () {
                    setState(() {
                      isLeft = false;
                    });
                  },
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class LeftTabClipPath extends CustomClipper<Path> {
  var radius = 16.0;

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(size.width / 2 - 15, 0);
    path.arcToPoint(
      Offset(size.width / 2, 15),
      clockwise: true,
      radius: Radius.circular(radius),
    );
    path.lineTo(size.width / 2, size.height - 15);
    path.arcToPoint(
      Offset(size.width / 2 + 15, size.height),
      clockwise: false,
      radius: Radius.circular(radius),
    );
    path.lineTo(0, size.height);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class RightTabClipPath extends CustomClipper<Path> {
  var radius = 16.0;

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width, 0);
    path.lineTo(size.width / 2 + 15, 0);
    path.arcToPoint(
      Offset(size.width / 2, 15),
      clockwise: false,
      radius: Radius.circular(radius),
    );
    path.lineTo(size.width / 2, size.height - 15);
    path.arcToPoint(
      Offset(size.width / 2 - 15, size.height),
      clockwise: true,
      radius: Radius.circular(radius),
    );
    path.lineTo(size.width, size.height);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
