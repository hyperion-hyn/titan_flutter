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
import 'package:titan/src/pages/wallet/wallet_show_trasaction_simple_info_page.dart';
import 'package:titan/src/plugins/wallet/config/tokens.dart';
import 'package:titan/src/utils/format_util.dart';
import 'entity/rp_release_info.dart';
import "package:collection/collection.dart";

class RpTransmitRecordsPage extends StatefulWidget {

  RpTransmitRecordsPage();

  @override
  State<StatefulWidget> createState() {
    return _RpTransmitRecordsState();
  }
}

class _RpTransmitRecordsState extends BaseState<RpTransmitRecordsPage> {
  final LoadDataBloc _loadDataBloc = LoadDataBloc();
  final RPApi _rpApi = RPApi();

  int _currentPage = 1;
  var _address = "";
  List<RpReleaseInfo> _dataList = [];
  Map<String, List<RpReleaseInfo>> get _filterDataMap =>
      groupBy(_dataList, (model) => FormatUtil.humanReadableDay(model.updatedAt));


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
        baseTitle: S.of(context).rp_transmit_detail,
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
                  var key = _filterDataMap.keys.toList()[index];
                  var value = _filterDataMap[key];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16, left: 24, bottom: 6),
                        child: Text(
                          key,
                          style: TextStyle(color: Color(0xff999999)),
                        ),
                      ),
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return _itemBuilder(value[index]);
                        },
                        itemCount: value.length,
                      ),
                    ],
                  );
                },
                childCount: _filterDataMap?.length ?? 0,
              ))
        ],
      ),
    );
  }

  Widget _itemBuilder(RpReleaseInfo model) {

    var hynAmount = FormatUtil.weiToEtherStr(model?.hynAmount ?? '0');

    var amount = model?.amount ?? 0;

    var rpAmount = FormatUtil.weiToEtherStr(model?.rpAmount ?? '0');
    rpAmount = FormatUtil.stringFormatCoinNum(rpAmount);
    // rpAmount = '00000000000000000000000000000000000000000000000000000000000000';

    var currentDate = DateTime.fromMillisecondsSinceEpoch(model.updatedAt * 1000);
    var updatedAt = Const.DATE_FORMAT.format(currentDate);

    return InkWell(
      onTap: () {
        WalletShowTransactionSimpleInfoPage.jumpToAccountInfoPage(
            context, model?.txHash ?? '', DefaultTokenDefine.HYN_RP_HRC30.symbol);
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
                  "res/drawable/red_pocket_coins.png",
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
                          '$amount ${S.of(context).rp_amount_unit}',
                          style: TextStyle(
                            color: HexColor("#333333"),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${S.of(context).rp_total_pretext} $hynAmount HYN',
                        style: TextStyle(
                          color: HexColor("#999999"),
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Text(
                    '${S.of(context).rp_staking_id}：${model?.stakingId ?? 0}',
                    //DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(createAt)),
                    style: TextStyle(
                      fontSize: 12,
                      color: HexColor('#333333'),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
              // Spacer(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12,),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '+ $rpAmount RP',
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
                        updatedAt,
                        //'21:21:21',
                        style: TextStyle(
                          fontSize: 12,
                          color: HexColor('#999999'),
                        ),
                        textAlign: TextAlign.left,
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
    _currentPage = 1;

    try {
      var netData = await _rpApi.getRPReleaseInfoList(_address, page: _currentPage);

      if (netData?.isNotEmpty ?? false) {
        _dataList = netData;
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
    try {
      _currentPage = _currentPage + 1;
      var netData = await _rpApi.getRPReleaseInfoList(_address, page: _currentPage);

      if (netData?.isNotEmpty ?? false) {
        if (mounted) {
          setState(() {
            _dataList.addAll(netData);
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
