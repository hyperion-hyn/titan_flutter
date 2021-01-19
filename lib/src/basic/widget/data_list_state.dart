import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:titan/src/utils/log_util.dart';

import './load_data_container/bloc/bloc.dart';

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
        if (mounted) {
          loadDataBloc.add(LoadEmptyEvent());
        }
      } else {
        if (mounted) {
          loadDataBloc.add(RefreshSuccessEvent());
        }
      }
   } catch (e) {
     // logger.e(e);
     LogUtil.toastException(e);
     loadDataBloc.add(LoadFailEvent());
   }
  }

  Future onWidgetRefreshCallback() async {
    try {
      currentPage = getStartPage();
      var list = await onLoadData(currentPage);
      _updateDataListOnReceive(list, currentPage);

      if (dataList.length == 0) {
        if (mounted) {
          loadDataBloc.add(LoadEmptyEvent());
        }
      } else {
        if (mounted) {
          loadDataBloc.add(RefreshSuccessEvent());
        }
      }
    } catch (e) {
      if(mounted) {
        logger.e(e);
        loadDataBloc.add(RefreshFailEvent());
      }
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
        if (mounted) {
          loadDataBloc.add(LoadMoreEmptyEvent());
        }
      } else {
        if (mounted) {
          loadDataBloc.add(LoadingMoreSuccessEvent());
        }
      }
    } catch (e) {
      if (mounted) {
        logger.e(e);
        loadDataBloc.add(LoadMoreFailEvent());
      }
    }
  }

  void _updateDataListOnReceive(List<dynamic> list, int page) {
    if(mounted) {
      setState(() {
        if (page == getStartPage()) {
          dataList.clear();
          dataList.addAll(list);
        } else {
          dataList.addAll(list);
        }
      });
    }
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
