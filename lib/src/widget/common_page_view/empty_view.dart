import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/i18n.dart';

class EmptyView extends StatelessWidget {
  final Function reload;

  EmptyView({this.reload});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image.asset('res/drawable/empty_data.png', width: 100.0),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: <Widget>[
                Text(
                  S.of(context).search_empty_data,
                  style: TextStyle(color: Colors.grey),
                ),
                if (reload != null)
                  FlatButton(
                      onPressed: reload,
                      child: Text(
                        '，' + S.of(context).click_refresh,
                        style: TextStyle(color: Colors.blue),
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
