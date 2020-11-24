import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
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
  LoadDataBloc _loadDataBloc = LoadDataBloc();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
              _rpInfo(),
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
    var level = '5';
    var rpBalance = '--';
    var rpToday = '--';
    var rpYesterday = '--';
    var rpMissed = '--';

    var activeWallet = WalletInheritedModel.of(context).activatedWallet;
    var imgPath = activeWallet != null
        ? 'res/drawable/ic_map3_node_default_icon.png'
        : 'res/drawable/img_avatar_default.png';
    var userName = activeWallet?.wallet?.keystore?.name ?? '--';
    var userAddress = shortBlockChainAddress(
      WalletUtil.ethAddressToBech32Address(
        activeWallet?.wallet?.getAtlasAccount()?.address ?? '',
      ),
    );
    var accountInfo = activeWallet != null
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

  _rpInfo() {
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
    var totalStaking = '--';
    var rpYesterday = '--';
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
                      child: Column(
                        children: <Widget>[
                          Text(
                            '$myStaking HYN',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          Text(
                            '我的抵押',
                            style: TextStyle(
                              fontSize: 13,
                              color: DefaultColors.color999,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Text(
                            '$rpYesterday RP',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          Text(
                            '昨日获得',
                            style: TextStyle(
                              fontSize: 13,
                              color: DefaultColors.color999,
                            ),
                          ),
                        ],
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
                      child: Column(
                        children: <Widget>[
                          Text(
                            '$totalStaking HYN',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          Text(
                            '全网抵押',
                            style: TextStyle(
                              fontSize: 13,
                              color: DefaultColors.color999,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Text(
                            '$totalTransmission RP',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          Text(
                            '全网累计传导',
                            style: TextStyle(
                              fontSize: 13,
                              color: DefaultColors.color999,
                            ),
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
    var intro = '发行量恒定100W，无预挖，无预售。\n10%为HYN传导池。\n90%通过空投发行，投完结束，不超过180天';
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
                      onTap: () {},
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
                Text(
                  intro,
                  style: TextStyle(
                    height: 1.8,
                    color: DefaultColors.color999,
                    fontSize: 13,
                  ),
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

  _requestData() {
    _loadDataBloc.add(RefreshSuccessEvent());
  }
}
