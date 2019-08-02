import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/i18n.dart';


class BottomOptBarWidget extends StatelessWidget {
  final VoidCallback onRouteTap;
  final VoidCallback onShareTap;

  BottomOptBarWidget({
    this.onRouteTap,
    this.onShareTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Material(
        elevation: 2,
        child: Column(
          children: <Widget>[
            Divider(
              height: 0,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    color: Colors.red,
                    height: 28,
                    child: MaterialButton(
                      elevation: 0,
                      highlightElevation: 0,
                      minWidth: 60,
                      color: Colors.black,
                      textColor: Color(0xddffffff),
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.directions,
                            color: Color(0xddffffff),
                            size: 15,
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            S.of(context).route,
                            style: TextStyle(fontSize: 14),
                          )
                        ],
                      ),
                      onPressed: onRouteTap,
                    ),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Container(
                    color: Colors.red,
                    height: 28,
                    child: MaterialButton(
                      elevation: 0,
                      highlightElevation: 0,
                      minWidth: 60,
                      onPressed: onShareTap,
                      color: Colors.black,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      textColor: Color(0xddffffff),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.share,
                            color: Color(0xddffffff),
                            size: 15,
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            '分享',
                            style: TextStyle(fontSize: 14),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
