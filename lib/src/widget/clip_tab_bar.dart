import 'package:flutter/material.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_node_tabs_page.dart';

typedef void OnTabChanged(NodeTab nodeTab);
typedef void OnTabDoubleTap(NodeTab nodeTab);

class ClipTabBar extends StatefulWidget {
  final NodeTab selectedNodeTab;
  final List<Widget> children;
  final OnTabChanged onTabChanged;
  final OnTabDoubleTap onTabDoubleTap;
  final BorderRadiusGeometry borderRadius;

  ClipTabBar({
    @required this.selectedNodeTab,
    @required this.children,
    @required this.onTabChanged,
    this.onTabDoubleTap,
    this.borderRadius,
  });

  @override
  State<StatefulWidget> createState() {
    return _LoadDataState();
  }
}

class _LoadDataState extends State<ClipTabBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          child: Container(
            width: double.infinity,
            height: 70,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: widget.borderRadius),
          ),
          clipper: widget.selectedNodeTab == NodeTab.map3
              ? LeftTabClipPath()
              : RightTabClipPath(),
        ),
        Container(
          width: double.infinity,
          height: 50,
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  child: Container(
                    child: Center(
                      child: widget.children[0] ?? Container(),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      widget.onTabChanged(NodeTab.map3);
                    });
                  },
                  onDoubleTap: () {
                    setState(() {
                      widget.onTabDoubleTap(NodeTab.map3);
                    });
                  },
                ),
              ),
              Expanded(
                child: InkWell(
                  child: Container(
                    child: Center(
                      child: widget.children[1] ?? Container(),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      widget.onTabChanged(NodeTab.atlas);
                    });
                  },
                  onDoubleTap: () {
                    setState(() {
                      widget.onTabDoubleTap(NodeTab.atlas);
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
    path.lineTo(size.width / 2, size.height - 35);
    path.arcToPoint(
      Offset(size.width / 2 + 15, size.height - 20),
      clockwise: false,
      radius: Radius.circular(radius),
    );
    path.lineTo(size.width / 2 + 15, size.height);
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
    path.lineTo(size.width / 2, size.height - 35);
    path.arcToPoint(
      Offset(size.width / 2 - 15, size.height - 20),
      clockwise: true,
      radius: Radius.circular(radius),
    );
    path.lineTo(size.width / 2 - 15, size.height);
    path.lineTo(size.width, size.height);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
