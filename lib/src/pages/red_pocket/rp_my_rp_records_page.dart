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
import 'package:titan/src/pages/red_pocket/red_pocket_detail_page.dart';
import 'package:titan/src/utils/format_util.dart';

class RpMyRpRecordsPage extends StatefulWidget {
  RpMyRpRecordsPage();

  @override
  State<StatefulWidget> createState() {
    return _RpMyRpRecordsState();
  }
}

class _RpMyRpRecordsState extends BaseState<RpMyRpRecordsPage> {
  final LoadDataBloc _loadDataBloc = LoadDataBloc();
  final RPApi _rpApi = RPApi();

  Map<String, dynamic> _currentPageKey;
  var _address = "";
  // RpMyRpRecordEntity _rpMyRecordEntity;
  List<RpOpenRecordEntity> _dataList = [];

  int lastDay;

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
      appBar: BaseAppBar(
        baseTitle: '我的红包',
        backgroundColor: HexColor('#F8F8F8'),
      ),
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
              var model = _dataList[index];

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
            childCount: _dataList?.length ?? 0,
          ))
        ],
      ),
    );
  }

  Widget _itemBuilder(int index) {
    var model = _dataList[index];

    var desc = '';
    switch (model.luck) {
      case 0:
        desc = '错过';
        break;

      case 1:
        if (model.type == 0) {
          desc = '砸中';
        } else {
          desc = '';
        }
        break;

      case 2:
        desc = '最佳';
        break;

      default:
        desc = '';
        break;
    }

    var title = '';
    switch (model.type) {
      case 0:
        title = '幸运红包';
        break;

      case 1:
        title = '量级红包';
        break;

      case 2:
        title = '晋升红包';
        break;

      default:
        title = '';
        break;
    }

    var createdAt = DateTime.fromMillisecondsSinceEpoch(model.createdAt * 1000);
    var createdAtStr = DateFormat("HH:mm").format(createdAt);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RedPocketDetailPage(rpOpenRecordEntity: model),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Wrap(
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
                          '${S.of(context).rp_total_pretext} ${model?.totalAmountStr ?? '0'} RP',
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
                        model.luck == 0 ? '0 RP' : '+ ${model?.amountStr ?? '0'} RP',
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
                          color: model.luck == 2 ? HexColor('#F0BE00') : HexColor('#999999'),
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

  void getNetworkData() async {
    try {
      var netData = await _rpApi.getMyRpRecordList(_address, pagingKey: _currentPageKey);

      if (netData?.data?.isNotEmpty ?? false) {
        _currentPageKey = netData.pagingKey;
        _dataList = netData.data;
        if (mounted) {
          setState(() {
            _loadDataBloc.add(RefreshSuccessEvent());
          });
        }
      } else {
        _loadDataBloc.add(LoadEmptyEvent());
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
        _dataList.addAll(netData.data);
        if (mounted) {
          setState(() {
            // todo: 不应该调用set state
            _loadDataBloc.add(LoadingMoreSuccessEvent());
          });
        }
      } else {
        _loadDataBloc.add(LoadMoreEmptyEvent());
      }
    } catch (e) {
      _loadDataBloc.add(LoadMoreFailEvent());
    }
  }
}
