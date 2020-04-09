import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
                  '暂无数据',
                  style: TextStyle(color: Colors.grey),
                ),
                if (reload != null)
                  FlatButton(
                      onPressed: reload,
                      child: Text(
                        '，点击刷新',
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
