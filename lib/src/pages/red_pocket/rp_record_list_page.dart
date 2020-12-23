import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/red_pocket/api/rp_api.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_my_rp_record_entity.dart';
import 'package:titan/src/pages/red_pocket/rp_record_detail_page.dart';
import 'package:titan/src/utils/format_util.dart';

class RpRecordListPage extends StatefulWidget {
  final RedPocketType state; // 1: 已经打开，2：未打开
  RpRecordListPage({this.state});

  @override
  State<StatefulWidget> createState() {
    return _RpRecordListState();
  }
}

class _RpRecordListState extends BaseState<RpRecordListPage> with AutomaticKeepAliveClientMixin {
  final LoadDataBloc _loadDataBloc = LoadDataBloc();
  final RPApi _rpApi = RPApi();

  Map<String, dynamic> _currentPageKey;
  var _address = "";
  List<RpOpenRecordEntity> _dataList = [];
  List<RpOpenRecordEntity> get _filterDataList =>
      _dataList?.where((element) => element.type == widget.state.index)?.toList()?.reversed?.toList() ?? [];

  int lastDay;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    var activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext)?.activatedWallet;
    _address = activatedWallet?.wallet?.getEthAccount()?.address ?? "";
  }

  @override
  void onCreated() {
    _loadDataBloc.add(LoadingEvent());
  }

  @override
  void dispose() {
    _loadDataBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#F8F8F8'),
      // appBar: BaseAppBar(
      //   baseTitle: '我的红包',
      //   backgroundColor: HexColor('#F8F8F8'),
      // ),
      body: _pageView(),
    );
  }

  _pageView() {
    return LoadDataContainer(
      bloc: _loadDataBloc,
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
              var model = _filterDataList[index];

              var currentDate = DateTime.fromMillisecondsSinceEpoch(model.createdAt * 1000);

              bool isNewDay = false;
              if (index == 0) {
                isNewDay = true;
              } else {
                if (currentDate.day != lastDay) {
                  isNewDay = true;
                }
              }
              lastDay = currentDate.day;

              //print("[$runtimeType] model.createdAt:${model.createdAt},length:${model.createdAt.toString().length}");

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isNewDay)
                    Padding(
                      padding: const EdgeInsets.only(top: 16, left: 24, bottom: 6),
                      child: Text(
                        FormatUtil.humanReadableDay(model.createdAt),
                        style: TextStyle(color: Color(0xff999999)),
                      ),
                    ),
                  _itemBuilder(index),
                ],
              );
            },
            childCount: _filterDataList?.length ?? 0,
          ))
        ],
      ),
    );
  }

  Widget _itemBuilder(int index) {
    var model = _filterDataList[index];

    var luckState = RpLuckState.values[(model?.luck ?? 0)];
    var rpInfoModel = getRpLuckStateInfo(model);
    var desc = rpInfoModel.desc;
    var amount = rpInfoModel.amount;

    var title = '';
    RedPocketType rpType = RedPocketType.values[model.type];
    switch (rpType) {
      case RedPocketType.LUCKY:
        title = '幸运红包';
        break;

      case RedPocketType.LEVEL:
        title = '量级红包';
        break;

      case RedPocketType.PROMOTION:
        title = '晋升红包';
        break;

      default:
        title = '';
        break;
    }

    var createdAt = DateTime.fromMillisecondsSinceEpoch(model.createdAt * 1000);
    var createdAtStr = DateFormat("HH:mm").format(createdAt);

    String totalAmountStr = FormatUtil.stringFormatCoinNum(
          model?.totalAmountStr ?? "0",
          decimal: 4,
        ) ??
        '--';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RpRecordDetailPage(rpOpenRecordEntity: model),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 6, left: 12, right: 12, bottom: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: HexColor('#FFFFFF'),
            borderRadius: BorderRadius.all(
              Radius.circular(6.0),
            ), //设置四周圆角 角度
          ),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  right: 10,
                ),
                child: Image.asset(
                  "res/drawable/red_pocket_logo.png",
                  width: 28,
                  height: 28,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 6,
                        ),
                        child: Text(
                          title,
                          style: TextStyle(
                            color: HexColor("#333333"),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${S.of(context).rp_total_pretext} $totalAmountStr RP',
                        style: TextStyle(
                          color: HexColor("#999999"),
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                        maxLines: 3,
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Text(
                    createdAtStr,
                    style: TextStyle(
                      fontSize: 10,
                      color: HexColor('#999999'),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
              // Spacer(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        amount,
                        style: TextStyle(
                          color: HexColor("#333333"),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 3,
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Text(
                        desc,
                        style: TextStyle(
                          fontSize: 10,
                          color: ([RpLuckState.BEST, RpLuckState.LUCKY_BEST].contains(luckState))
                              ? HexColor('#F0BE00')
                              : HexColor('#999999'),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  var _countRequest = 0;
  void getNetworkData() async {
    _currentPageKey = null;
    try {
      var netData = await _rpApi.getMyRpRecordList(_address, pagingKey: _currentPageKey);

      if (netData?.data?.isNotEmpty ?? false) {
        _currentPageKey = netData.pagingKey;
        _dataList = filterRpOpenDataList(netData.data);

        // todo:排序
        //_dataList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }

      if (_filterDataList?.isEmpty??true) {

        var isEmptyKey = _currentPageKey?.isNotEmpty??false;
        print("[$runtimeType] getNetworkData, _countRequest:$_countRequest");
        if (isEmptyKey) {
          _countRequest += 1;
          getMoreNetworkData();
        } else {
          if (mounted) {
            setState(() {
              _loadDataBloc.add(LoadEmptyEvent());
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _loadDataBloc.add(RefreshSuccessEvent());
          });
        }
      }
    } catch (e) {
      _loadDataBloc.add(LoadFailEvent());
    }
  }

  void getMoreNetworkData() async {
    if (_currentPageKey?.isEmpty ?? true) {
      _loadDataBloc.add(LoadMoreEmptyEvent());
      return;
    }

    try {
      var netData = await _rpApi.getMyRpRecordList(_address, pagingKey: _currentPageKey);

      if (netData?.data?.isNotEmpty ?? false) {
        _currentPageKey = netData.pagingKey;
        _dataList.addAll(filterRpOpenDataList(netData.data));
        if (mounted) {
          setState(() {
            // todo: 不应该调用set state
            _loadDataBloc.add(LoadingMoreSuccessEvent());
          });
        }
      } else {
        _loadDataBloc.add(LoadMoreEmptyEvent());
      }

      if (_filterDataList?.isEmpty??true && _currentPageKey == null) {
        if (mounted) {
          setState(() {
            _loadDataBloc.add(LoadEmptyEvent());
          });
        }
      } else {
        if (_dataList?.isNotEmpty ?? false) {
          if (mounted) {
            setState(() {
              _loadDataBloc.add(LoadingMoreSuccessEvent());
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _loadDataBloc.add(LoadMoreEmptyEvent());
            });
          }
        }
      }
    } catch (e) {
      _loadDataBloc.add(LoadMoreFailEvent());
    }
  }
}
