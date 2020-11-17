import 'package:flutter/material.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_node_tabs_page.dart';

typedef void OnTabChanged(NodeTab nodeTab);
typedef void OnTabDoubleTap(NodeTab nodeTab);

class ClipTabBar extends StatefulWidget {
  final List<Widget> children;
  final OnTabChanged onTabChanged;
  final OnTabDoubleTap onTabDoubleTap;
  final BorderRadiusGeometry borderRadius;

  ClipTabBar({
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
  bool leftSelected = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: widget.borderRadius),
          ),
          clipper: leftSelected ? LeftTabClipPath() : RightTabClipPath(),
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
                      leftSelected = true;
                      widget.onTabChanged(NodeTab.map3);
                    });
                  },
                  onDoubleTap: () {
                    setState(() {
                      leftSelected = true;
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
                      leftSelected = false;
                      widget.onTabChanged(NodeTab.atlas);
                    });
                  },
                  onDoubleTap: () {
                    setState(() {
                      leftSelected = false;
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
