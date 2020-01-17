


import 'package:flutter/material.dart';
import 'package:titan/generated/i18n.dart';

import 'all_page_state.dart';

class AllPageStateContainer extends StatefulWidget {

  AllPageState allPageState;
  VoidCallback onLoadData;

  AllPageStateContainer(this.allPageState,this.onLoadData);

  @override
  State<StatefulWidget> createState() {
    return AllPageStateContainerState();
  }
}

class AllPageStateContainerState extends State<AllPageStateContainer> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.allPageState is LoadingState)
      return buildLoading(context);
    else if (widget.allPageState is LoadEmptyState)
      return buildEmpty(context);
    else if (widget.allPageState is LoadFailState)
      return buildFail(context, (widget.allPageState as LoadFailState).message);
    else
      return Container(
        width: 0.0,
        height: 0.0,
      );
  }

  Widget buildLoading(context) {
    return Center(
      child: SizedBox(
        height: 40,
        width: 40,
        child: CircularProgressIndicator(
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget buildFail(context, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image.asset('res/drawable/load_fail.png', width: 100.0),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              '网络请求异常~',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          FlatButton(
              onPressed: () {
                widget.onLoadData();
              },
              child: Text(
                '点击重试',
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontSize: 16,
                ),
              )),
        ],
      ),
    );
  }

  Widget buildEmpty(context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image.asset('res/drawable/empty_data.png', width: 100.0),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              S.of(context).search_empty_data,
              style: TextStyle(color: Colors.grey),
            ),
          )
//          FlatButton(onPressed: () {}, child: Text('点击刷新')),
        ],
      ),
    );
  }

}