import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/red_pocket/api/rp_api.dart';
import 'package:titan/src/pages/red_pocket/red_pocket_exchange_page.dart';
import 'package:titan/src/pages/red_pocket/red_pocket_exchange_records_page.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

import 'entity/rp_statistics.dart';

class RedPocketPage extends StatefulWidget {
  RedPocketPage();

  @override
  State<StatefulWidget> createState() {
    return _RedPocketPageState();
  }
}

class _RedPocketPageState extends State<RedPocketPage> {
  RPApi _rpApi = RPApi();
  LoadDataBloc _loadDataBloc = LoadDataBloc();
  RPStatistics _rpStatistics;
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
              _airdropWidget(),
              _rpPool(),
              _projectIntro(),
            ],
          )),
    );
  }

  _cardPadding() {
    return const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0);
  }

  Widget _contentColumn(
    String content,
    String subContent,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            '$content',
            style: TextStyle(
              fontSize: 11,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: 4.0,
          ),
          Text(
            subContent,
            style: TextStyle(
              fontSize: 10,
              color: DefaultColors.color999,
            ),
          ),
        ],
      ),
    );
  }

  _myRPInfo() {
    // var level = _rpInfo?.level ?? '--';
    //var rpToday = _rpStatistics?.self? ?? '--';
    //var rpYesterday = _rpInfo?.rpYesterday ?? '--';
    // var rpMissed = _rpInfo?.rpMissed ?? '--';

    var rpBalance = '--';
    var rpToken = WalletInheritedModel.of(context).getCoinVoBySymbol(
      SupportedTokens.HYN_RP_ERC30_ROPSTEN.symbol,
    );

    try {
      rpBalance = FormatUtil.coinBalanceHumanReadFormat(
        rpToken,
      );
    } catch (e) {}

    var rpBalanceStr = '$rpBalance RP';

    // var rpTodayStr = '$rpToday RP';
    // var rpYesterdayStr = '$rpYesterday RP';
    // var rpMissedStr = '$rpMissed RP';

    var rpTodayStr = '未';
    var rpYesterdayStr = '空';
    var rpMissedStr = '投';

    var imgPath = _activeWallet != null
        ? 'res/drawable/ic_map3_node_default_icon.png'
        : 'res/drawable/img_avatar_default.png';

    var userName = _activeWallet?.wallet?.keystore?.name ?? '--';

    var userAddress = shortBlockChainAddress(
      WalletUtil.ethAddressToBech32Address(
        _activeWallet?.wallet?.getAtlasAccount()?.address ?? '',
      ),
    );

    var accountInfoWidget = _activeWallet != null
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
                      child: accountInfoWidget,
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    // Column(
                    //   children: [
                    //     Text(
                    //       level,
                    //       style: TextStyle(
                    //         color: Colors.red,
                    //         fontSize: 20,
                    //         fontWeight: FontWeight.w500,
                    //       ),
                    //     ),
                    //     Text(
                    //       '抵押量级',
                    //       style: TextStyle(
                    //         fontSize: 10,
                    //         color: DefaultColors.color999,
                    //       ),
                    //     ),
                    //   ],
                    // )
                  ],
                ),
                SizedBox(
                  height: 24,
                ),
                Row(
                  children: [
                    Expanded(
                      child: _contentColumn(rpBalanceStr, '余额'),
                    ),
                    _verticalLine(),
                    Expanded(
                      child: _contentColumn(rpTodayStr, '今日红包'),
                    ),
                    _verticalLine(),
                    Expanded(
                      child: _contentColumn(rpYesterdayStr, '昨日红包'),
                    ),
                    _verticalLine(),
                    Expanded(
                      child: _contentColumn(rpMissedStr, '我错过的'),
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

  _airdropWidget() {
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
                    padding: const EdgeInsets.only(
                      top: 16.0,
                      bottom: 8.0,
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 24,
                        ),
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '红包空投',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: HexColor('#333333'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 4,
                      ),
                      child: Text(
                        '总量90万RP',
                        style: TextStyle(
                          color: DefaultColors.color999,
                          fontSize: 12,
                        ),
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

  _rpPool() {
    var rpYesterday = '--';
    var myHYNStaking = '--';
    var globalHYNStaking = '--';
    var globalTotalTransmit = '--';

    try {
      rpYesterday = FormatUtil.stringFormatCoinNum(
        _rpStatistics?.self?.yesterdayStr,
      );
      myHYNStaking = FormatUtil.stringFormatCoinNum(
        _rpStatistics?.self?.totalStakingHynStr,
      );
      globalHYNStaking = FormatUtil.stringFormatCoinNum(
        _rpStatistics?.global?.totalStakingHynStr,
      );
      globalTotalTransmit = FormatUtil.stringFormatCoinNum(
        _rpStatistics?.global?.totalTransmitStr,
      );
    } catch (e) {}

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
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 4,
                      ),
                      child: Text(
                        '总量10万RP',
                        style: TextStyle(
                          color: DefaultColors.color999,
                          fontSize: 12,
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
                      child: _inkwellColumn(
                        '$myHYNStaking HYN',
                        '我的抵押',
                        onTap: _pushExchangeAction,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: _inkwellColumn(
                        '$rpYesterday RP',
                        '昨日获得',
                        onTap: _pushRecordAction,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  child: Container(
                    height: 0.5,
                    color: HexColor('#F2F2F2'),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _poolInfoColumn(
                        '$globalHYNStaking HYN',
                        '全网抵押',
                      ),
                    ),
                    Expanded(
                      child: _poolInfoColumn(
                        '$globalTotalTransmit RP',
                        '全网累计传导',
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: ClickOvalButton(
                    S.of(context).check,
                    _pushExchangeAction,
                    width: 160,
                    height: 32,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _projectIntro() {
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
                    _tipRow('首个基于可信地图位置+HRC30去中心化交易结构的去中心化应用场景'),
                    _tipRow('用户只需抵押HYN即可体验去中心化抢红包，与朋友圈共同分享RP'),
                    _tipRow('越早加入，收获越多，更有隐藏红包福利等你来解锁！'),
                    _tipRow('RP总发行量为100万枚，在红包HRC30智能合约内进行传导和空投，无预挖，无预售。')
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

  ///widgets
  Widget _poolInfoColumn(
    String content,
    String subContent,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          content,
          style: TextStyle(
            fontSize: 12,
            color: DefaultColors.color999,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(
          height: 4.0,
        ),
        Text(
          subContent,
          style: TextStyle(
            fontSize: 8,
            color: DefaultColors.color999,
          ),
        ),
      ],
    );
  }

  Widget _inkwellColumn(
    String content,
    String subContent, {
    GestureTapCallback onTap,
    double contentFontSize = 14,
    double subContentFontSize = 10,
    CrossAxisAlignment columnCrossAxisAlignment = CrossAxisAlignment.start,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: 100,
            ),
            child: Column(
              crossAxisAlignment: columnCrossAxisAlignment,
              children: <Widget>[
                Text(
                  content,
                  style: TextStyle(
                    fontSize: contentFontSize,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: 4.0,
                ),
                Text(
                  subContent,
                  style: TextStyle(
                    fontSize: subContentFontSize,
                    color: DefaultColors.color999,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 15,
                color: DefaultColors.color999,
              ),
            ),
        ],
      ),
    );
  }

  Widget _tipRow(
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

  Widget _verticalLine({
    bool havePadding = false,
  }) {
    return Center(
      child: Container(
        height: 20,
        width: 0.5,
        color: HexColor('#000000').withOpacity(0.2),
        margin: havePadding
            ? const EdgeInsets.only(
                right: 4.0,
                left: 4.0,
              )
            : null,
      ),
    );
  }

  ///Actions
  _pushExchangeAction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RedPocketExchangePage(),
      ),
    );
  }

  _pushRecordAction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RedPocketExchangeRecordsPage(),
      ),
    );
  }

  _requestData() async {
    try {
      _rpStatistics = await _rpApi.getRPStatistics(
        _activeWallet?.wallet?.getAtlasAccount()?.address,
      );
      setState(() {});
      _loadDataBloc.add(RefreshSuccessEvent());
    } catch (e) {
      _loadDataBloc.add(RefreshFailEvent());
    }
  }
}
