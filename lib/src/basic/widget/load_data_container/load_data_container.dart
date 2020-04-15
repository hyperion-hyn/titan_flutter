import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:titan/generated/i18n.dart';

import './bloc/bloc.dart';

typedef OnLoadData = void Function(int page);

class LoadDataContainer extends StatefulWidget {
  final LoadDataBloc bloc;
  final Widget child;
  final bool enablePullUp;
  final bool enablePullDown;
  final VoidCallback onLoadData;
  final VoidCallback onRefresh;
  final VoidCallback onLoadingMore;
  final VoidCallback onLoadingMoreEmpty;

  LoadDataContainer({
    @required this.child,
    @required this.bloc,
    this.enablePullDown = true,
    this.enablePullUp = true,
    this.onLoadData,
    this.onRefresh,
    this.onLoadingMore,
    this.onLoadingMoreEmpty
  });

  @override
  State<StatefulWidget> createState() {
    return LoadDataContainerState();
  }
}

class LoadDataContainerState extends State<LoadDataContainer> {
  RefreshController controller = RefreshController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoadDataBloc, LoadDataState>(
      bloc: widget.bloc,
      builder: (context, state) {
        if (state is LoadingState) {
          widget.onLoadData();
        }

        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            //loading\empty\fail
            if (state is LoadingState /*|| state is InitialLoadDataState*/)
              buildLoading(context)
            else if (state is LoadEmptyState)
              buildEmpty(context)
            else if (state is LoadFailState)
              buildFail(context, state.message)
            else
              buildPullRefreshWithChild(context, state),
          ],
        );
      },
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
                widget.bloc.add(LoadingEvent());
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

  Widget buildPullRefreshWithChild(context, LoadDataState state) {
    if (state is RefreshingState) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!controller.isRefresh) {
          controller.requestRefresh();
        }
        widget.onRefresh();
      });
    } else if (state is RefreshSuccessState) {
      controller.refreshCompleted(resetFooterState: true);
    } else if (state is RefreshFailState) {
      controller.refreshFailed();
    } else if (state is LoadingMoreState) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!controller.isLoading) {
          controller.requestLoading();
        }
        widget.onLoadingMore();
      });
    } else if (state is LoadingMoreSuccessState) {
      controller.loadComplete();
    } else if (state is LoadMoreEmptyState) {
      controller.loadNoData();
      if(widget.onLoadingMoreEmpty != null) widget.onLoadingMoreEmpty();
    } else if (state is LoadMoreFailState) {
      controller.loadFailed();
    }

    return RefreshConfiguration.copyAncestor(
      context: context,
      child: SmartRefresher(
        controller: controller,
        enablePullDown: widget.enablePullDown,
        enablePullUp: widget.enablePullUp,
        footer: CustomFooter(builder: (BuildContext context, LoadStatus mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
//            body = Text("上拉加载");
            body = Container();
          } else if (mode == LoadStatus.loading) {
            body = CupertinoActivityIndicator();
          } else if (mode == LoadStatus.failed) {
            body = Text(
              '加载失败，点击重试',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            );
          } else if (mode == LoadStatus.canLoading) {
            body = Container();
          } else {
            body = Text(
              "没有更多数据了~",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            );
          }
          return Container(
            height: 56.0,
            child: Center(child: body),
          );
        }),
        onRefresh: widget.onRefresh,
        onLoading: widget.onLoadingMore,
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
