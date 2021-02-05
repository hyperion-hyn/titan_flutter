import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/red_pocket/api/rp_api.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_share_entity.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_util.dart';
import 'package:titan/src/pages/red_pocket/rp_share_get_success_page.dart';
import 'package:titan/src/utils/format_util.dart';
import "package:collection/collection.dart";

class RpShareGetListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RpShareGetListState();
  }
}

class _RpShareGetListState extends BaseState<RpShareGetListPage> with AutomaticKeepAliveClientMixin {
  final LoadDataBloc _loadDataBloc = LoadDataBloc();
  final RPApi _rpApi = RPApi();

  int _page = 1;
  int _size = 20;
  var _address = "";
  List<RpShareOpenEntity> _dataList = [];
  Map<String, List<RpShareOpenEntity>> get _filterDataMap =>
      groupBy(_dataList, (model) => FormatUtil.humanReadableDay(model.createdAt));

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
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return Scaffold(
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
      enablePullUp: true,
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
                    padding: const EdgeInsets.only(
                      top: 12,
                      left: 24,
                      bottom: 4,
                    ),
                    child: Text(
                      key,
                      style: TextStyle(
                        color: Color(0xff999999),
                        fontSize: 12,
                      ),
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

  Widget _itemBuilder(RpShareOpenEntity model) {
    var isNormal = (model.rpType ?? RpShareType.normal) == RpShareType.normal;

    var createdAt = DateTime.fromMillisecondsSinceEpoch(model.createdAt * 1000);
    var createdAtStr = DateFormat("HH:mm").format(createdAt);

    var location = (model?.location ?? '').isNotEmpty ? '${model.location}' : '';
    var locationRange = '$location';

    var total = '+ ';
    var hyn = FormatUtil.truncateDecimalNum(Decimal.parse(model.getHYNAmount), 4);
    var rp = FormatUtil.truncateDecimalNum(Decimal.parse(model.getRPAmount), 4);
    var amount = total + amountValueToString(hyn:hyn, rp:rp);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RpShareGetSuccessPage(model.id),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 6, left: 12, right: 12, bottom: 6),
        child: Container(
          padding: const EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 8),
          decoration: BoxDecoration(
            color: HexColor('#FFFFFF'),
            borderRadius: BorderRadius.all(
              Radius.circular(6.0),
            ), //设置四周圆角 角度
          ),
          child: Column(
            children: [
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 10,
                    ),
                    child: Image.asset(
                      "res/drawable/rp_share_record_${model.rpType}.png",
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
                          /*
                          Container(
                            margin: const EdgeInsets.only(
                              right: 8,
                              // top: 16,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  HexColor('#FF0527'),
                                  HexColor('#FF4D4D'),
                                ],
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(2)),
                            ),
                            child: Text(
                              shareTypeEntity.nameZh,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          */
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 6,
                            ),
                            child: Text(
                              '${model.username} 的红包',
                              style: TextStyle(
                                color: HexColor("#333333"),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                        ],
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Text(
                        ((model?.greeting ?? '')?.isNotEmpty ?? false) ? model.greeting : S.of(context).good_luck_and_get_rich,
                        style: TextStyle(
                          fontSize: 12,
                          color: HexColor('#999999'),
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(
                        height: 6,
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
                          /*
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  WalletShowAccountInfoPage.jumpToAccountInfoPage(
                                      context, model?.rpHash ?? '', SupportedTokens.HYN_RP_HRC30.symbol);
                                },
                                child: Text(
                                  "+ ${model.rpAmount} RP",
                                  style: TextStyle(
                                    color: HexColor("#333333"),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 3,
                                  textAlign: TextAlign.right,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  WalletShowAccountInfoPage.jumpToAccountInfoPage(
                                      context, model?.hynHash ?? '', SupportedTokens.HYN_Atlas.symbol);
                                },
                                child: Text(
                                  " ,${model.hynAmount} HYN",
                                  style: TextStyle(
                                    color: HexColor("#333333"),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 3,
                                  textAlign: TextAlign.right,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          */
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
                          Row(
                            children: [
                              Spacer(),
                              SizedBox(width: 10,),
                              Text(
                                createdAtStr,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: HexColor('#999999'),
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (!isNormal)
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 36,
                      ),
                      Image.asset(
                        "res/drawable/rp_share_location_tag.png",
                        width: 10,
                        height: 14,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Text(
                          locationRange,
                          style: TextStyle(
                            fontSize: 12,
                            color: HexColor('#999999'),
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void getNetworkData() async {
    _page = 1;

    try {
      var netData = await _rpApi.getShareGetList(
        _address,
        page: _page,
        size: _size,
      );

      if (netData?.isNotEmpty ?? false) {
        _dataList = netData;

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
    _page += 1;

    try {
      var netData = await _rpApi.getShareGetList(
        _address,
        page: _page,
        size: _size,
      );

      var isNotEmpty = netData?.isNotEmpty ?? false;
      if (isNotEmpty) {
        _dataList.addAll(netData);

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
