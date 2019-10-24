import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:titan/src/business/load_data_container/bloc/bloc.dart';

import '../../global.dart';
import 'base_state.dart';

abstract class DataListState<T extends StatefulWidget> extends BaseState<T> {
  List<dynamic> dataList = [];
  int currentPage;

  int getStartPage() {
    return 0;
  }

  LoadDataBloc loadDataBloc;

  void postFrameCallBackAfterInitState() {}

  Future<List<dynamic>> onLoadData(int page);

  Future onWidgetLoadDataCallback() async {
    try {
      currentPage = getStartPage();
      var list = await onLoadData(currentPage);
      _updateDataListOnReceive(list, currentPage);

      if (dataList.length == 0) {
        loadDataBloc.add(LoadEmptyEvent());
      } else {
        loadDataBloc.add(RefreshSuccessEvent());
      }
    } catch (e) {
      logger.e(e);
      loadDataBloc.add(LoadFailEvent());
    }
  }

  Future onWidgetRefreshCallback() async {
    try {
      currentPage = getStartPage();
      var list = await onLoadData(currentPage);
      _updateDataListOnReceive(list, currentPage);

      if (dataList.length == 0) {
        loadDataBloc.add(LoadEmptyEvent());
      } else {
        loadDataBloc.add(RefreshSuccessEvent());
      }
    } catch (e) {
      logger.e(e);
      loadDataBloc.add(RefreshFailEvent());
    }
  }

  Future onWidgetLoadingMoreCallback() async {
    try {
      int lastSize = dataList.length;
      int nextPage = currentPage + 1;
      var list = await onLoadData(nextPage);
      currentPage = nextPage;
      _updateDataListOnReceive(list, currentPage);

      if (dataList.length == lastSize) {
        loadDataBloc.add(LoadMoreEmptyEvent());
      } else {
        loadDataBloc.add(LoadingMoreSuccessEvent());
      }
    } catch (e) {
      logger.e(e);
      loadDataBloc.add(LoadMoreFailEvent());
    }
  }

  void _updateDataListOnReceive(List<dynamic> list, int page) {
    setState(() {
      if (page == 0) {
        dataList.clear();
        dataList.addAll(list);
      } else {
        dataList.addAll(list);
      }
    });
  }

  @override
  void initState() {
    super.initState();

    loadDataBloc = LoadDataBloc();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallBackAfterInitState();
    });
  }

  @override
  void dispose() {
    loadDataBloc.close();
    super.dispose();
  }
}
