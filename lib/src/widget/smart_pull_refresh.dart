import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:titan/src/global.dart';

class SmartPullRefresh extends StatefulWidget {
  final Widget child;
  final Function onRefresh;
  final Function onLoading;

  SmartPullRefresh({@required this.onRefresh, @required this.onLoading, @required this.child});

  @override
  State<StatefulWidget> createState() {
    return _SmartPullRefreshState();
  }
}

class _SmartPullRefreshState extends State<SmartPullRefresh> {
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
        controller: _refreshController,
        enablePullUp: true,
        footer: ClassicFooter(
          loadStyle: LoadStyle.ShowWhenLoading,
          completeDuration: Duration(milliseconds: 500),
        ),
        header: WaterDropHeader(),
        onRefresh: () async {
          await Future.delayed(Duration(milliseconds: 1000));
          try {
            widget.onRefresh();
          } catch (_) {
            logger.e(_);
          }
          _refreshController.refreshCompleted();
        },
        onLoading: () async {
          await Future.delayed(Duration(milliseconds: 1000));
          try {
            widget.onLoading();
          } catch (_) {
            logger.e(_);
          }
          _refreshController.loadComplete();
        },
        child: widget.child);
  }
}
