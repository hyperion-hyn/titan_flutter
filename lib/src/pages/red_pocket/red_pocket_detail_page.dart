import 'dart:math';
import 'dart:ui';

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
import 'package:titan/src/pages/red_pocket/entity/rp_miners_entity.dart';
import 'package:titan/src/pages/red_pocket/widget/rp_airdrop_widget.dart';
import 'package:titan/src/pages/wallet/wallet_show_account_info_page.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/wallet_widget.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';

class RedPocketDetailPage extends StatefulWidget {

  final int rpType;

  RedPocketDetailPage({this.rpType});

  @override
  State<StatefulWidget> createState() {
    return _RedPocketDetailState();
  }
}

class _RedPocketDetailState extends BaseState<RedPocketDetailPage> {
  final LoadDataBloc _loadDataBloc = LoadDataBloc();
  final RPApi _rpApi = RPApi();

  int _currentPage = 1;
  var _address = "";

  List<RpMinerInfo> _dataList = List();
  RpMinerInfo _inviter;

  int _rpType = Random().nextInt(3);

  @override
  void initState() {
    super.initState();

    _rpType = widget.rpType;

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
        baseTitle: '红包详情',
        backgroundColor: HexColor('#F8F8F8'),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              WalletShowAccountInfoPage.jumpToAccountInfoPage(context, '', SupportedTokens.HYN_RP_HRC30.symbol);
            },
            child: Text(
              '查看交易',
              style: TextStyle(
                color: HexColor("#1F81FF"),
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
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
          SliverToBoxAdapter(
            child: Column(
              children: [
                _infoDetailBuilder(),
                _rpListHeaderWidget(),
              ],
            ),
          ),
          _rpRecordListWidget(),
        ],
      ),
    );
  }

  Widget _infoDetailBuilder() {

    var title = '';
    var subTitle = '';
    print("[$runtimeType] _infoDetailBuilder, rpType:$_rpType");


    var rpAmount = '12 RP';

    var isIgnored = _rpType == 1;

    switch (_rpType) {
      case 0:
        title = '幸运红包';
        break;

      case 1:
        title = '量级红包';
        subTitle = '（量级1）';
        rpAmount = '0 RP';
        break;

      case 2:
        title = '晋升红包';
        break;

      default:
        title = '幸运红包';
        break;
    }


    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 12, right: 12, bottom: 6),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 12,
            ),
            decoration: BoxDecoration(
              color: HexColor('#FFFFFF'),
              borderRadius: BorderRadius.all(
                Radius.circular(12.0),
              ), //设置四周圆角 角度
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    top: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'res/drawable/red_pocket_logo_small.png',
                        width: 12,
                        height: 16,
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      Text(
                        title,
                        style: TextStyle(
                          color: HexColor("#333333"),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        subTitle,
                        style: TextStyle(
                          color: HexColor("#999999"),
                          fontSize: 10,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_rpType == 2)Padding(
                  padding: const EdgeInsets.only(
                    top: 6,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Text(
                        '派大星',
                        style: TextStyle(
                          color: HexColor("#333333"),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      Text(
                        'hyn19493…43222',
                        style: TextStyle(
                          color: HexColor("#999999"),
                          fontSize: 10,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_rpType == 2)Padding(
                  padding: const EdgeInsets.only(
                    top: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '量级1 - 量级3',
                        style: TextStyle(
                          color: HexColor("#333333"),
                          fontSize: 10,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Image.asset(
                        "res/drawable/red_pocket_bg_left.png",
                        width: 14,
                        height: 42,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                        ),
                        child: Image.asset(
                          "res/drawable/red_pocket_coins.png",
                          width: 28,
                          height: 28,
                        ),
                      ),
                      Text(
                        rpAmount,
                        style: TextStyle(
                          color: HexColor("#E3A900"),
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Image.asset(
                        "res/drawable/red_pocket_bg_right.png",
                        width: 43,
                        height: 49,
                      ),
                    ],
                  ),
                ),
                if (isIgnored)Padding(
                  padding: const EdgeInsets.only(
                    top: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Text(
                        '你已错过红包机会',
                        style: TextStyle(
                          color: HexColor("#999999"),
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      Image.asset(
                        'res/drawable/red_pocket_detail_info.png',
                        width: 12,
                        height: 12,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16,),
              ],
            ),
          ),
          Positioned(
            left: 30,
            child: Container(
              width: 200,
              height: 200,
              child: RPAirdropWidget(),
            ),
          ),
        ],
      ),
    );
  }

  _rpListHeaderWidget() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: 6,
      ),
      child: Row(
        children: [
          Text(
            '红包共 303 RP',
            style: TextStyle(
              color: Color(0xff333333),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          Spacer(),
          Text(
            '2020/12/12 21:21:21',
            style: TextStyle(
              color: Color(0xff999999),
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  _rpRecordListWidget() {
    if (_dataList.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 36,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  'res/drawable/ic_empty_contract.png',
                  width: 100,
                  height: 100,
                ),
              ),
              Text(
                '暂无记录',
                style: TextStyle(
                  fontSize: 13,
                  color: DefaultColors.color999,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if ((index + 1) == _dataList.length && _rpType == 1) {
              return _defaultItem(index);
            }
            return _itemBuilder(index);
          },
          childCount: _dataList.length,
        ),
      );
    }
  }

  Widget _itemBuilder(int index) {
    var info = _dataList[index];
    var name = info?.name ?? '';
    var level = info?.level ?? 0;
    var bech32Address = WalletUtil.ethAddressToBech32Address(
      info?.address ?? '',
    );
    var address = shortBlockChainAddress(bech32Address);
    var inviteTime = info?.inviteTime ?? 0;
    var inviteTimeDate = DateTime.fromMillisecondsSinceEpoch(inviteTime * 1000);
    var inviteTimeStr = Const.DATE_FORMAT.format(inviteTimeDate);

    var rpAmount = FormatUtil.weiToEtherStr('0');
    // rpAmount = FormatUtil.stringFormatCoinNum10(rpAmount);
    // rpAmount = '00000000000000000000000000000000000000000000000000000000000000';

    var desc = '';
    switch (index) {
      case 0:
        desc = '最佳';
        break;

      case 1:
        desc = '量级不足，错过机会';
        break;

      case 2:
        desc = '';
        break;

      default:
        desc = '';
        break;
    }

    return InkWell(
      onTap: () {
        AtlasApi.goToHynScanPage(context, bech32Address);
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  right: 10,
                ),
                child: SizedBox(
                  height: 40,
                  width: 40,
                  child: walletHeaderWidget(
                    name,
                    address: info?.address ?? '',
                    isCircle: true,
                    isShowShape: false,
                    size: 32,
                  ),
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
                        child: name.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6.0),
                                child: Text(
                                  name,
                                  style: TextStyle(
                                    color: HexColor("#333333"),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : SizedBox(),
                      ),
                      Text(
                        ' $level 级',
                        style: TextStyle(
                          color: HexColor("#999999"),
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${UiUtil.shortEthAddress(address)}',
                    //DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(createAt)),
                    style: TextStyle(
                      fontSize: 10,
                      color: HexColor('#999999'),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
              //Spacer(),
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

  Widget _defaultItem(int index) {
    var info = _dataList[index];
    var name = info?.name ?? '';
    var level = info?.level ?? 0;
    var bech32Address = WalletUtil.ethAddressToBech32Address(
      info?.address ?? '',
    );
    var address = shortBlockChainAddress(bech32Address);
    var inviteTime = info?.inviteTime ?? 0;
    var inviteTimeDate = DateTime.fromMillisecondsSinceEpoch(inviteTime * 1000);
    var inviteTimeStr = Const.DATE_FORMAT.format(inviteTimeDate);

    var rpAmount = FormatUtil.weiToEtherStr('0');
    // rpAmount = FormatUtil.stringFormatCoinNum10(rpAmount);
    rpAmount = '00000000000000000000000000000000000000000000000000000000000000';
    rpAmount = '300';

    return InkWell(
      onTap: () {
        AtlasApi.goToHynScanPage(context, bech32Address);
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  right: 10,
                ),
                child: Image.asset(
                  'res/drawable/red_pocket_default_icon.png',
                  width: 32,
                  height: 32,
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Text(
                            '其他相同量级账户',
                            style: TextStyle(
                              color: HexColor("#333333"),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        ' 12 个',
                        style: TextStyle(
                          color: HexColor("#999999"),
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  /*Text(
                    '${UiUtil.shortEthAddress(address)}',
                    //DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(createAt)),
                    style: TextStyle(
                      fontSize: 10,
                      color: HexColor('#999999'),
                    ),
                    textAlign: TextAlign.left,
                  ),*/
                ],
              ),
              //Spacer(),
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
    _dataList.clear();

    try {
      var netData = await _rpApi.getRPMinerList(
        _address,
        page: _currentPage,
      );

      _inviter = netData.inviter;
      _dataList = netData.miners ?? [];
      if (mounted) {
        setState(() {
          _loadDataBloc.add(RefreshSuccessEvent());
        });
      }
      setState(() {});
    } catch (e) {
      _loadDataBloc.add(LoadFailEvent());
    }
  }

  void getMoreNetworkData() async {
    try {
      _currentPage = _currentPage + 1;
      var netData = await _rpApi.getRPMinerList(
        _address,
        page: _currentPage,
      );

      if (netData?.miners?.isNotEmpty ?? false) {
        _dataList.addAll(netData.miners);
        _loadDataBloc.add(LoadingMoreSuccessEvent());
      } else {
        _loadDataBloc.add(LoadMoreEmptyEvent());
      }
    } catch (e) {
      _loadDataBloc.add(LoadMoreFailEvent());
    }
  }
}
