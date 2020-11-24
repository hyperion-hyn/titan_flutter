import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/red_pocket/red_pocket_exchange_records_page.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_info.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/utils.dart';

class RedPocketPage extends StatefulWidget {
  RedPocketPage();

  @override
  State<StatefulWidget> createState() {
    return _RedPocketPageState();
  }
}

class _RedPocketPageState extends State<RedPocketPage> {
  AtlasApi _atlasApi = AtlasApi();
  LoadDataBloc _loadDataBloc = LoadDataBloc();
  RPInfo _rpInfo;
  WalletVo _activeWallet;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _activeWallet = WalletInheritedModel.of(context).activatedWallet;
  }

  @override
  void dispose() {
    super.dispose();
    _loadDataBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: '红包 HRC30',
        backgroundColor: Colors.grey[50],
      ),
      body: LoadDataContainer(
          bloc: _loadDataBloc,
          enablePullUp: false,
          onLoadData: () async {
            _requestData();
          },
          onRefresh: () async {
            _requestData();
          },
          child: CustomScrollView(
            slivers: <Widget>[
              _myRPInfo(),
              _rpInfoWidget(),
              _rpPool(),
              _projectIntro(),
            ],
          )),
    );
  }

  _cardPadding() {
    return const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0);
  }

  _myRPInfo() {
    var level = _rpInfo?.level ?? '--';
    var rpBalance = _rpInfo?.rpBalance ?? '--';
    var rpToday = _rpInfo?.rpToday ?? '--';
    var rpYesterday = _rpInfo?.rpYesterday ?? '--';
    var rpMissed = _rpInfo?.rpMissed ?? '--';

    var imgPath = _activeWallet != null
        ? 'res/drawable/ic_map3_node_default_icon.png'
        : 'res/drawable/img_avatar_default.png';
    var userName = _activeWallet?.wallet?.keystore?.name ?? '--';
    var userAddress = shortBlockChainAddress(
      WalletUtil.ethAddressToBech32Address(
        _activeWallet?.wallet?.getAtlasAccount()?.address ?? '',
      ),
    );
    var accountInfo = _activeWallet != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                userAddress,
                style: TextStyle(
                  fontSize: 11,
                  color: DefaultColors.color999,
                ),
              )
            ],
          )
        : InkWell(
            child: Text(
              '请创建/导入钱包',
              style: TextStyle(
                color: Colors.blue,
              ),
            ),
            onTap: () {
              Application.router.navigateTo(
                context,
                Routes.wallet_manager,
              );
            },
          );

    return SliverToBoxAdapter(
      child: Padding(
        padding: _cardPadding(),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(60.0),
                      child: Image.asset(
                        imgPath,
                        width: 42,
                        height: 42,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
                      width: 16.0,
                    ),
                    Expanded(
                      child: accountInfo,
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Column(
                      children: [
                        Text(
                          level,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '抵押量级',
                          style: TextStyle(
                            fontSize: 10,
                            color: DefaultColors.color999,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 24,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Text(
                            '$rpBalance RP',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          Text(
                            '余额',
                            style: TextStyle(
                              fontSize: 10,
                              color: DefaultColors.color999,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 20,
                      width: 1,
                      color: HexColor('#33000000'),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Text(
                            '$rpToday RP',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          Text(
                            '今日红包',
                            style: TextStyle(
                              fontSize: 10,
                              color: DefaultColors.color999,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 20,
                      width: 1,
                      color: HexColor('#33000000'),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Text(
                            '$rpYesterday RP',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          Text(
                            '昨日红包',
                            style: TextStyle(
                              fontSize: 10,
                              color: DefaultColors.color999,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 20,
                      width: 1,
                      color: HexColor('#33000000'),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Text(
                            '$rpMissed RP',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          Text(
                            '我错过的',
                            style: TextStyle(
                              fontSize: 10,
                              color: DefaultColors.color999,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _rpInfoWidget() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: _cardPadding(),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      children: [
                        Image.asset(
                          'res/drawable/img_rp_airdrop.png',
                          width: 80,
                          height: 80,
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          '即将上线',
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '红包空投',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '总发行100W',
                          style: TextStyle(
                            color: DefaultColors.color999,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _rpPool() {
    var myStaking = '--';
    var rpYesterday = '--';
    var totalStaking = '--';
    var totalTransmission = '--';
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          child: Padding(
            padding: _cardPadding(),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      '传导池',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {},
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '$myStaking HYN',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                  height: 4.0,
                                ),
                                Text(
                                  '我的抵押',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: DefaultColors.color999,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 15,
                              color: DefaultColors.color999,
                            )
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RedPocketExchangeRecordsPage(),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '$rpYesterday RP',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                  height: 4.0,
                                ),
                                Text(
                                  '昨日获得',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: DefaultColors.color999,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 15,
                              color: DefaultColors.color999,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '$totalStaking HYN',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                height: 4.0,
                              ),
                              Text(
                                '全网抵押',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: DefaultColors.color999,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '$totalTransmission RP',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                height: 4.0,
                              ),
                              Text(
                                '全网累计传导',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: DefaultColors.color999,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _projectIntro() {
    var intro =
        '首个基于可信地图位置+HRC30去中心化交易结构的去中心化应用场景\n用户只需抵押HYN即可体验去中心化抢红包，与朋友圈共同分享RP\n越早加入，收获越多，更有隐藏红包福利等你来解锁！\nRP总发行量为100万枚，只通过红包形式在DDex内进行传导和空投，无预挖，无预售。';
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          child: Padding(
            padding: _cardPadding(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '项目简介',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    InkWell(
                      onTap: () {
                        AtlasApi.goToAtlasMap3HelpPage(context);
                      },
                      child: Text(
                        '详细介绍',
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Column(
                  children: [
                    rowTipsItem('首个基于可信地图位置+HRC30去中心化交易结构的去中心化应用场景'),
                    rowTipsItem('用户只需抵押HYN即可体验去中心化抢红包，与朋友圈共同分享RP'),
                    rowTipsItem('越早加入，收获越多，更有隐藏红包福利等你来解锁！'),
                    rowTipsItem('RP总发行量为100万枚，在红包HRC30智能合约内进行传导和空投，无预挖，无预售。')
                  ],
                ),
                SizedBox(
                  height: 32,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget rowTipsItem(
    String title, {
    double top = 8,
    String subTitle = "",
    GestureTapCallback onTap,
  }) {
    var _nodeWidget = Padding(
      padding: const EdgeInsets.only(right: 10, top: 10),
      child: Container(
        width: 3,
        height: 3,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: DefaultColors.color999,
            border: Border.all(color: DefaultColors.color999, width: 1.0)),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(top: top),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _nodeWidget,
          Expanded(
              child: InkWell(
            onTap: onTap,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: subTitle,
                    style: TextStyle(color: HexColor("#1F81FF"), fontSize: 12),
                  )
                ],
                text: title,
                style: TextStyle(
                    height: 1.8, color: DefaultColors.color999, fontSize: 12),
              ),
            ),
          )),
        ],
      ),
    );
  }

  _requestData() async {
    try {
      _rpInfo = await _atlasApi.postRpInfo(
        _activeWallet?.wallet?.getAtlasAccount()?.address,
      );
      _loadDataBloc.add(RefreshSuccessEvent());
    } catch (e) {
      _loadDataBloc.add(RefreshFailEvent());
    }
  }
}
