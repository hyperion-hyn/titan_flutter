import 'package:flutter/material.dart';

typedef void OnTabChanged(int index);

class ClipTabBar extends StatefulWidget {
  final List<Widget> children;
  final OnTabChanged onTabChanged;
  final BorderRadiusGeometry borderRadius;

  ClipTabBar({
    @required this.children,
    @required this.onTabChanged,
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
              color: Colors.white,
              borderRadius: widget.borderRadius
            ),
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
                      widget.onTabChanged(0);
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
                      widget.onTabChanged(1);
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
