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
import 'package:titan/src/pages/red_pocket/red_pocket_detail_page.dart';
import 'package:titan/src/utils/format_util.dart';
import 'entity/rp_release_info.dart';

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

  int _currentPage = 1;
  var _address = "";
  List<RpReleaseInfo> _dataList = [];

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

              var currentDate = DateTime.fromMillisecondsSinceEpoch(model.updatedAt * 1000);

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
                        FormatUtil.humanReadableDay(model.updatedAt),
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

    var hynAmount = FormatUtil.weiToEtherStr(model?.hynAmount ?? '0');

    var amount = model?.amount ?? 0;

    var rpAmount = FormatUtil.weiToEtherStr(model?.rpAmount ?? '0');
    // rpAmount = FormatUtil.stringFormatCoinNum10(rpAmount);
    // rpAmount = '00000000000000000000000000000000000000000000000000000000000000';

    var currentDate = DateTime.fromMillisecondsSinceEpoch(model.updatedAt * 1000);
    var updatedAt = DateFormat("HH:mm").format(currentDate);

    var title = '';
    var desc = '';

    switch (index) {
      case 0:
        desc = '最佳';
        break;

      case 1:
        desc = '错过';
        break;

      case 2:
        desc = '砸中';
        break;

      default:
        desc = '';
        break;
    }

    switch (index) {
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
        title = '幸运红包';
        break;
    }
    return InkWell(
      onTap: () {
        // WalletShowAccountInfoPage.jumpToAccountInfoPage(
        //     context, model?.txHash ?? '', SupportedTokens.HYN_RP_HRC30.symbol);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RedPocketDetailPage(rpType: index,),
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
                          '${S.of(context).rp_total_pretext} $rpAmount RP',
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
                      updatedAt,
                      //'${S.of(context).rp_staking_id}：${model?.stakingId ?? 0}',
                      //DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(createAt)),
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
                        desc,
                        style: TextStyle(
                          fontSize: 10,
                          color: index == 0 ? HexColor('#F0BE00') : HexColor('#999999'),
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
        _dataList.addAll(netData);
        _loadDataBloc.add(LoadingMoreSuccessEvent());
      } else {
        _loadDataBloc.add(LoadMoreEmptyEvent());
      }
    } catch (e) {
      _loadDataBloc.add(LoadMoreFailEvent());
    }
  }
}
