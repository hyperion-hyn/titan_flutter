import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/widget/circle_dash_line.dart';

typedef OnRoute = void Function(String profile);

class RouteBar extends StatefulWidget {
  final String fromName;
  final String toName;
  final String profile;
  final OnRoute onReRoute;
  final VoidCallback onBack;

  RouteBar({
    this.fromName,
    this.profile,
    this.toName,
    this.onReRoute,
    this.onBack,
  });

  @override
  State<StatefulWidget> createState() {
    return _RouteBarState();
  }
}

class _RouteBarState extends State<RouteBar> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Material(
          elevation: 2,
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, left: 16, right: 16, bottom: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    InkWell(
                      onTap: widget.onBack,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0, right: 8, bottom: 8),
                        child: Icon(Icons.arrow_back_ios),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Color(0xfff7f7f7)),
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.only(left: 8),
                        child: Row(
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  decoration:
                                      BoxDecoration(color: Color(0xff2ebc57), borderRadius: BorderRadius.circular(24)),
                                  width: 8,
                                  height: 8,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: CustomPaint(
                                    size: Size(8, 20),
                                    painter: CircleDashLine(
                                      direction: CircleDashDirection.VERTICAL,
                                      dotRadius: 1.6,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration:
                                      BoxDecoration(color: Color(0xffe6162f), borderRadius: BorderRadius.circular(24)),
                                  width: 8,
                                  height: 8,
                                )
                              ],
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8, right: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      widget.fromName ?? '',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    Divider(
                                      height: 16,
                                    ),
                                    Text(
                                      widget.toName ?? '',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      buildRouteTypeItem(
                          Icons.drive_eta,
                          S.of(context).driving,
                          widget.profile == 'driving',
                          widget.profile == 'driving'
                              ? null
                              : () {
                                  if (widget.onReRoute != null) {
                                    widget.onReRoute('driving');
                                  }
                                }),
                      buildRouteTypeItem(
                          Icons.directions_bike,
                          S.of(context).cycling,
                          widget.profile == 'cycling',
                          widget.profile == 'cycling'
                              ? null
                              : () {
                                  if (widget.onReRoute != null) {
                                    widget.onReRoute('cycling');
                                  }
                                }),
                      buildRouteTypeItem(
                          Icons.directions_walk,
                          S.of(context).walking,
                          widget.profile == 'walking',
                          widget.profile == 'walking'
                              ? null
                              : () {
                                  if (widget.onReRoute != null) {
                                    widget.onReRoute('walking');
                                  }
                                }),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildRouteTypeItem(IconData iconData, String text, bool isSelected, [GestureTapCallback onTap]) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.all(Radius.circular(16)),
      child: Ink(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        decoration: BoxDecoration(
            color: isSelected ? Color(0xff3473fe) : null, borderRadius: BorderRadius.all(Radius.circular(16))),
        child: Row(
          children: <Widget>[
            Icon(
              iconData,
              color: isSelected ? Colors.white : Colors.black54,
              size: 22,
            ),
            Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
