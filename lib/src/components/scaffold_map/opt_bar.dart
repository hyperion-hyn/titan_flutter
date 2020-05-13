import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/l10n.dart';

import '../../global.dart';

class OperationBar extends StatelessWidget {
  final VoidCallback onRouteTap;

  OperationBar({this.onRouteTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
//      color: Theme.of(context).backgroundColor,
      color: Colors.white,
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
                buildButton(text: S.of(context).route, icon: Icons.directions, onTap: onRouteTap),
//                buildButton(text: S.of(context).share_location, icon: Icons.lock, onTap: onShareTap),
              ],
            ),
          ),
          Divider(
            height: 0,
          ),
          SizedBox(
            height: MediaQuery.of(context).padding.bottom > 0 ? safeAreaBottomPadding : 0,
          ),
        ],
      ),
    );
  }

  Widget buildButton({@required String text, IconData icon, VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(4),
      ),
      height: 28,
      child: MaterialButton(
        elevation: 0,
        highlightElevation: 0,
        minWidth: 60,
        onPressed: onTap,
        padding: EdgeInsets.symmetric(horizontal: 8),
        textColor: Color(0xddffffff),
        highlightColor: Colors.black,
        splashColor: Colors.white10,
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              color: Color(0xddffffff),
              size: 15,
            ),
            SizedBox(
              width: 4,
            ),
            Text(
              text,
              style: TextStyle(fontSize: 14, color: Color(0xddffffff)),
            )
          ],
        ),
      ),
    );
  }
}
