import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/utils/log_util.dart';

class RedPocketExchangeRecordsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RedPocketExchangeRecordsState();
  }
}

class _RedPocketExchangeRecordsState extends BaseState<RedPocketExchangeRecordsPage> {
  LoadDataBloc loadDataBloc = LoadDataBloc();

  int currentPage = 0;
  final AtlasApi _atlasApi = AtlasApi();
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
      var netData;
      _response = netData.data;
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
      var netData;

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
              

              var key = '昨天';
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
                        itemCount: 2,
                        itemBuilder: (context, index) {
                        
                          
                          var createAt = DateTime.now().millisecondsSinceEpoch;

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
                                        'kk',
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
                                            DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(createAt)),
                                            style: TextStyle(fontSize: 12, color: Colors.black54),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                    ],
                                  ),
                                  Spacer(),
                                  
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

}
