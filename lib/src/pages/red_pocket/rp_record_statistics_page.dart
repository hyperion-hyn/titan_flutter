import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/utils/format_util.dart';

class RpRecordStatisticsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RpRecordStatisticsState();
  }
}

class _RpRecordStatisticsState extends BaseState<RpRecordStatisticsPage> {
  final LoadDataBloc _loadDataBloc = LoadDataBloc();
  final RPApi _rpApi = RPApi();

  Map<String, dynamic> _currentPageKey;
  bool get _isNotEmptyKey => _currentPageKey?.isNotEmpty ?? false;

  var _address = "";
  List<RpOpenRecordEntity> _originalDataList = [];
  List<RpRecordStatisticsModel> _dataList = [];

  _setupDataList() {
    List<RpRecordStatisticsModel> list = [];

    for (var model in _originalDataList) {
      if (model.type == RedPocketType.LUCKY.index && [RpLuckState.MISS, RpLuckState.GET, RpLuckState.LUCKY_MISS_QUOTA].contains(RpLuckState.values[model.luck])) {
        continue;
      }

      bool isNewDay = false;
      if (list.isEmpty) {
        isNewDay = true;
      } else {
        var currentDate = DateTime.fromMillisecondsSinceEpoch(model.createdAt * 1000);
        var lastDate = DateTime.fromMillisecondsSinceEpoch(list.last.createdAt * 1000);

        if (currentDate.day != lastDate.day) {
          isNewDay = true;
        }
      }

      if (isNewDay) {
        RpOpenRecordEntity luckyModel = RpOpenRecordEntity.onlyType(RedPocketType.LUCKY.index);
        RpOpenRecordEntity levelModel = RpOpenRecordEntity.onlyType(RedPocketType.LEVEL.index);
        RpOpenRecordEntity promotionModel = RpOpenRecordEntity.onlyType(RedPocketType.PROMOTION.index);
        List<RpOpenRecordEntity> recordList = [luckyModel, levelModel, promotionModel];

        var newModel = RpRecordStatisticsModel(
          createdAt: model.createdAt,
          totalAmount: '0',
          list: recordList,
        );
        list.add(newModel);
      }

      RpRecordStatisticsModel statisticsModel = list.last;

      var amountDecimal = Decimal.tryParse(model?.amountStr ?? '0') ?? Decimal.zero;

      var firstModel = statisticsModel.list.firstWhere((element) => model.type == element.type, orElse: null);
      if (firstModel != null) {
        var lastDecimal = Decimal.tryParse(firstModel?.amountStr ?? '0') ?? Decimal.zero;
        lastDecimal += amountDecimal;
        firstModel.amount = ConvertTokenUnit.strToBigInt(lastDecimal?.toString() ?? '0').toString();
      }

      var totalAmountDecimal = Decimal.tryParse(statisticsModel.totalAmountStr ?? '0') ?? Decimal.zero;
      totalAmountDecimal += amountDecimal;
      statisticsModel.totalAmount = ConvertTokenUnit.strToBigInt(totalAmountDecimal?.toString() ?? '0').toString();
    }

    _dataList = list;
  }

  @override
  void initState() {
    super.initState();

    var activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext)?.activatedWallet;
    _address = activatedWallet?.wallet?.getEthAccount()?.address ?? "";
  }

  @override
  void dispose() {
    _loadDataBloc.close();
    super.dispose();
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: S.of(context).every_day_statistics,
        backgroundColor: Colors.white,
      ),
      backgroundColor: HexColor('#F8F8F8'),
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
              return Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 8,),
                child: Container(
                  decoration: BoxDecoration(
                    color: HexColor('#FFFFFF'),
                    borderRadius: BorderRadius.all(
                      Radius.circular(6.0),
                    ), //设置四周圆角 角度
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: HexColor('#FFFFF7'),
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(6.0),topRight: Radius.circular(6.0),), //设置四周圆角 角度
                        ),
                        padding: const EdgeInsets.only(
                          top: 12,
                          bottom: 12,
                          left: 12,
                          right: 12,
                        ),
                        // color: Colors.grey[200],
                        child: Row(
                          children: [
                            Text(
                              FormatUtil.humanReadableDay(model.createdAt),
                              style: TextStyle(color: Color(0xff333333), fontSize: 14, fontWeight: FontWeight.w600,),
                            ),
                            Spacer(),
                            Text(
                              '总 ${FormatUtil.stringFormatCoinNum(
                                model?.totalAmountStr ?? '0',
                                decimal: 4,
                              )}RP',
                              style: TextStyle(color: Color(0xff333333), fontSize: 14, fontWeight: FontWeight.w600,),
                            ),
                          ],
                        ),
                      ),
                      ListView.separated(
                          shrinkWrap: true,
                          physics: new NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return _itemBuilder(model.list[index]);
                          },
                          separatorBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                left: 36,
                              ),
                              child: Container(
                                height: 0.8,
                                color: HexColor('#F8F8F8'),
                              ),
                            );
                          },
                          itemCount: model.list.length),
                    ],
                  ),
                ),
              );
            },
            childCount: _dataList?.length ?? 0,
          ))
        ],
      ),
    );
  }

  Widget _itemBuilder(RpOpenRecordEntity model) {
    var title = '';
    RedPocketType rpType = RedPocketType.values[model.type];
    switch (rpType) {
      case RedPocketType.LUCKY:
        title = S.of(context).lucky_rp;
        break;

      case RedPocketType.LEVEL:
        title = S.of(context).level_rp;
        break;

      case RedPocketType.PROMOTION:
        title = S.of(context).promotion_rp;
        break;

      default:
        title = '';
        break;
    }

    var amountStr = '${FormatUtil.stringFormatCoinNum(
      model?.amountStr ?? '0',
      decimal: 4,
    )} RP';

    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12,),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
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
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
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
                      amountStr,
                      style: TextStyle(
                        color: HexColor("#333333"),
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                      maxLines: 3,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getNetworkData() async {
    _currentPageKey = null;

    try {
      var netData = await _rpApi.getMyRpRecordStatistics(
        _address,
        pagingKey: _currentPageKey,
      );

      if (netData?.data?.isNotEmpty ?? false) {
        _currentPageKey = netData.pagingKey;
        _originalDataList = filterRpOpenDataList(netData.data);
        _setupDataList();

        if (mounted) {
          setState(() {
            _loadDataBloc.add(RefreshSuccessEvent());
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _loadDataBloc.add(LoadEmptyEvent());
          });
        }
      }
    } catch (e) {
      _loadDataBloc.add(LoadFailEvent());
    }
  }

  void getMoreNetworkData() async {
    print("[$runtimeType] getNetworkData,_isNotEmptyKey:$_isNotEmptyKey");

    if (!_isNotEmptyKey) {
      _loadDataBloc.add(LoadMoreEmptyEvent());
      return;
    }

    try {
      var netData = await _rpApi.getMyRpRecordStatistics(
        _address,
        pagingKey: _currentPageKey,
      );

      var isNotEmpty = netData?.data?.isNotEmpty ?? false;
      if (isNotEmpty) {
        _currentPageKey = netData.pagingKey;
        _originalDataList.addAll(filterRpOpenDataList(netData.data));
        _setupDataList();

        if (mounted) {
          setState(() {
            _loadDataBloc.add(LoadMoreEmptyEvent());
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _loadDataBloc.add(LoadingMoreSuccessEvent());
          });
        }
      }
    } catch (e) {
      _loadDataBloc.add(LoadMoreFailEvent());
    }
  }
}

class RpRecordStatisticsModel {
  int createdAt;

  String totalAmount;

  List<RpOpenRecordEntity> list;

  RpRecordStatisticsModel({this.createdAt, this.totalAmount, this.list});

  String get totalAmountStr => FormatUtil.weiToEtherStr(totalAmount) ?? '0';
}
