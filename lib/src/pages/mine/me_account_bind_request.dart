import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/utils/log_util.dart';
import 'api/contributions_api.dart';
import 'model/account_bind_info_entity.dart';

class MeAccountBindRequestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MeAccountBindRequestState();
  }
}

class _MeAccountBindRequestState extends BaseState<MeAccountBindRequestPage> {
  LoadDataBloc loadDataBloc = LoadDataBloc();

  int currentPage = 0;
  ContributionsApi _api = ContributionsApi();
  Map<String, dynamic> _response;

  get _flatTextStyle => TextStyle(
        color: HexColor("#1F81FF"),
        fontSize: 14,
        fontWeight: FontWeight.normal,
      );

  @override
  void initState() {
    super.initState();
  }

  @override
  void onCreated() {
    loadDataBloc.add(LoadingEvent());
  }

  void getNetworkData() async {
    try {
      var netData = await _api.getMrRequestList(page: currentPage);
      if (netData != null) {
        _response = netData.data;
      }
      if (mounted) {
        setState(() {
          if (_response.isEmpty) {
            loadDataBloc.add(LoadEmptyEvent());
          } else {
            loadDataBloc.add(RefreshSuccessEvent());
          }
        });
      }
    } catch (e) {
      loadDataBloc.add(LoadFailEvent());
    }
  }

  void getMoreNetworkData() async {
    try {
      currentPage = currentPage + 1;
      var netData = await _api.getMrRequestList(page: currentPage);
      if (netData != null) {
        _response = netData.data;
        loadDataBloc.add(LoadingMoreSuccessEvent());
      } else {
        loadDataBloc.add(LoadMoreEmptyEvent());
      }
      setState(() {});
    } catch (e) {
      loadDataBloc.add(LoadMoreFailEvent());
    }
  }

  @override
  void dispose() {
    loadDataBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          '新的申请',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _pageView(),
    );
  }

  _pageView() {
    return LoadDataContainer(
      bloc: loadDataBloc,
      onLoadData: () async {
        getNetworkData();
      },
      onRefresh: () async {
        getNetworkData();
      },
      onLoadingMore: () {
        getMoreNetworkData();
      },
      child: CustomScrollView(
        slivers: <Widget>[
          SliverList(
              delegate: SliverChildBuilderDelegate(
            (context, index) {
              List<Request> requestList;
              var key = _response.keys.toList()[index];
              if (_response[key] as List<dynamic> != null) {
                var value = _response[key] as List<dynamic>;
                requestList = value.map((json) => Request.fromJson(json)).toList();
              }

              return Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    key?.isNotEmpty ?? false
                        ? Padding(
                            padding: const EdgeInsets.only(
                              top: 16,
                            ),
                            child: Text(
                              key ?? '',
                              style: TextStyle(
                                color: HexColor("#999999"),
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          )
                        : Container(),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: requestList.length,
                        itemBuilder: (context, index) {
                          // 0: 等待审核
                          // -1: 已拒绝
                          // 1: 已批准
                          Request request = requestList[index];
                          bool done = request.state != 0;
                          var createAt = request?.requestTime??0;

                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Container(
                              padding: const EdgeInsets.all(
                                16,
                              ),
                              decoration: BoxDecoration(
                                color: HexColor('#F2F2F2'),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(6.0),
                                ), //设置四周圆角 角度
                              ),
                              child: Row(
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        request?.email ?? '',
                                        style: TextStyle(
                                          color: HexColor("#333333"),
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      if (createAt > 0)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 6,
                                          ),
                                          child: Text(
                                            DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(createAt * 1000)),
                                            style: TextStyle(fontSize: 12, color: Colors.black54),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                    ],
                                  ),
                                  Spacer(),

                                  // approved: 通过
                                  // refund: 拒绝
                                  if (!done)
                                    InkWell(
                                      onTap: () async {
                                        print('拒绝');

                                        _action(request.id, 'refund');
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 16,
                                        ),
                                        child: Text(
                                          '拒绝',
                                          style: _flatTextStyle,
                                        ),
                                      ),
                                    ),
                                  if (!done)
                                    InkWell(
                                      onTap: () async {
                                        print('同意');

                                        _action(request.id, 'approved');
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 16,
                                        ),
                                        child: Text(
                                          '同意',
                                          style: _flatTextStyle,
                                        ),
                                      ),
                                    ),
                                  if (done)
                                    Text(
                                      request.state == 1 ? '已同意' : '已拒绝',
                                      style: TextStyle(
                                        color: HexColor("#999999"),
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    )
                                ],
                              ),
                            ),
                          );
                        }),
                  ],
                ),
              );
            },
            childCount: _response?.keys?.length ?? 0,
          ))
        ],
      ),
    );
  }

  _action(int id, String optType) async {
    try {
      var isOk = await _api.postMrOperation(id: id, optType: optType);
      print("[${widget.runtimeType}] 拒绝, isOk:$isOk");

      /*
                                        打卡关联-审核申请
                                        optType可选的值有：
                                        approved: 通过
                                        refund: 拒绝
                                        返回错误可能的值有：
                                        -1003: 没操作权限
                                        -1004: 审核的账号已经是子账号或者有子账号申请在等待审核
                                        -1007: 子账号已经到达上限
                                        */

      if (isOk.code == 0) {
        loadDataBloc.add(LoadingEvent());
      } else if (isOk.code == -1003) {
        Fluttertoast.showToast(msg: '没操作权限');
      } else if (isOk.code == -1004) {
        Fluttertoast.showToast(msg: '审核的账号已经是子账号或者有子账号申请在等待审核');
      } else if (isOk.code == -1007) {
        Fluttertoast.showToast(msg: '子账号已经到达上限');
      } else {
        Fluttertoast.showToast(msg: isOk?.msg ?? '未知错误');
      }
    } catch (e) {
      LogUtil.toastException(e);
    }
  }
}
