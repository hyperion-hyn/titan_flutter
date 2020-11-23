import 'package:flutter/material.dart';
import 'package:titan/src/widget/common_page_view/empty_view.dart';
import 'package:titan/src/widget/common_page_view/fail_view.dart';
import 'package:titan/src/widget/common_page_view/loading_view.dart';

import 'all_page_state.dart';

class AllPageStateContainer extends StatefulWidget {
  final AllPageState allPageState;
  final VoidCallback onLoadData;
  final Widget child;

  AllPageStateContainer(this.allPageState, this.onLoadData,{this.child});

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
      if(widget.child != null)
        return widget.child;
      return Container(
        width: 0.0,
        height: 0.0,
      );
  }

  Widget buildLoading(context) {
    return LoadingView();
  }

  Widget buildFail(context, String message) {
    return FailView(
      message: message,
      onRetry: widget.onLoadData,
    );
  }

  Widget buildEmpty(context) {
    return EmptyView();
  }
}
