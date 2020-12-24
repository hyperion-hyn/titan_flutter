import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/rp/bloc/bloc.dart';
import 'package:titan/src/components/rp/redpocket_component.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/red_pocket/api/rp_api.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_level_airdrop_info.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_my_level_info.dart';
import 'package:titan/src/pages/red_pocket/rp_level_records_page.dart';
import 'package:titan/src/pages/red_pocket/rp_friend_list_page.dart';
import 'package:titan/src/pages/red_pocket/rp_friend_invite_page.dart';
import 'package:titan/src/pages/red_pocket/rp_record_list_page.dart';
import 'package:titan/src/pages/red_pocket/rp_record_tab_page.dart';
import 'package:titan/src/pages/red_pocket/rp_transmit_page.dart';
import 'package:titan/src/pages/red_pocket/widget/rp_airdrop_widget.dart';
import 'package:titan/src/pages/red_pocket/widget/rp_statistics_widget.dart';
import 'package:titan/src/pages/wallet/wallet_manager/wallet_manager_page.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/wallet_widget.dart';
import 'entity/rp_airdrop_round_info.dart';
import 'entity/rp_statistics.dart';

class RedPocketPage extends StatefulWidget {
  RedPocketPage();

  @override
  State<StatefulWidget> createState() {
    return _RedPocketPageState();
  }
}

class _RedPocketPageState extends BaseState<RedPocketPage> with RouteAware {
  RPApi _rpApi = RPApi();
  LoadDataBloc _loadDataBloc = LoadDataBloc();
  RPStatistics _rpStatistics;
  RpMyLevelInfo _myLevelInfo;
  RpAirdropRoundInfo _latestRoundInfo;
  RpLevelAirdropInfo _rpLevelAirdropInfo;

  @override
  void initState() {
    super.initState();
  }

  @override
  void onCreated() {
    Application.routeObserver.subscribe(this, ModalRoute.of(context));

    var activeWallet = WalletInheritedModel.of(context).activatedWallet;
    if (activeWallet == null) {
      if (context != null) {
        BlocProvider.of<RedPocketBloc>(context).add(ClearMyLevelInfoEvent());
      }
    }
    super.onCreated();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _myLevelInfo = RedPocketInheritedModel.of(context).rpMyLevelInfo;
    _rpStatistics = RedPocketInheritedModel.of(context).rpStatistics;
  }

  @override
  void didPopNext() {
    _requestData();
    super.didPopNext();
  }

  @override
  void dispose() {
    Application.routeObserver.unsubscribe(this);
    _loadDataBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: S.of(context).rp_hrc30,
        backgroundColor: Colors.grey[50],
        actions: <Widget>[
          FlatButton(
            onPressed: _navToMyRpRecords,
            child: Text(
              '我的红包',
              style: TextStyle(
                color: HexColor("#1F81FF"),
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: LoadDataContainer(
            bloc: _loadDataBloc,
            enablePullUp: false,
            onLoadData: () async {
              _requestData();
            },
            onRefresh: () async {
              _requestData();
            },
            child: CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: <Widget>[
                _myRPInfo(),
                _rpPool(),
                _airdropWidget(),
                _statisticsWidget(),
                _projectIntro(),
              ],
            )),
      ),
    );
  }

  _cardPadding() {
    return const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0);
  }

  Widget _contentColumn(
    String content,
    String subContent, {
    double contentFontSize = 14,
    double subContentFontSize = 10,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            '$content',
            style: TextStyle(
              fontSize: contentFontSize,
              color: Colors.black,
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
    );
  }

  _myRPInfo() {
    var activeWallet = WalletInheritedModel.of(context).activatedWallet;

    var rpBalanceStr = '--';
    var rpToken = WalletInheritedModel.of(context).getCoinVoBySymbol(
      SupportedTokens.HYN_RP_HRC30_ROPSTEN.symbol,
    );
    try {
      rpBalanceStr = FormatUtil.coinBalanceHumanReadFormat(
        rpToken,
      );
    } catch (e) {}

    var rpBalance = '$rpBalanceStr RP';

    var userName = activeWallet?.wallet?.keystore?.name ?? '--';

    var walletAddress = activeWallet?.wallet?.getAtlasAccount()?.address ?? "";

    var userAddress = shortBlockChainAddress(
      WalletUtil.ethAddressToBech32Address(
        walletAddress,
      ),
    );

    var accountInfoWidget = activeWallet != null
        ? InkWell(
            onTap: _navToManageWallet,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      userAddress,
                      style: TextStyle(
                        fontSize: 9,
                        color: DefaultColors.color999,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 2,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '钱包余额',
                      style: TextStyle(
                        fontSize: 12,
                        color: DefaultColors.color999,
                      ),
                      textAlign: TextAlign.end,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '$rpBalance',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        : InkWell(
            child: Text(
              S.of(context).create_or_import_wallet_first,
              style: TextStyle(
                color: Colors.blue,
              ),
            ),
            onTap: _navToManageWallet,
          );

    int currentLevel = _myLevelInfo?.currentLevel ?? 0;
    int highestLevel = _myLevelInfo?.highestLevel ?? 0;

    var isShowDowngrade = highestLevel > currentLevel;
    var isZeroLevel = currentLevel == 0;

    var hint = isShowDowngrade || isZeroLevel
        ? Padding(
            padding: const EdgeInsets.only(
              top: 4,
            ),
            child: Row(
              children: [
                Image.asset(
                  isZeroLevel
                      ? 'res/drawable/error_rounded.png'
                      : 'res/drawable/ic_rp_level_down.png',
                  width: 8,
                ),
                SizedBox(
                  width: 2,
                ),
                Expanded(
                  child: Text(
                    isZeroLevel ? '当前量级无法参与红包空投' : '等级下降了',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
          )
        : Text(
            currentLevel < 5 ? '去提升' : '去查看',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 9,
            ),
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
                    SizedBox(
                      width: 42,
                      height: 42,
                      child: walletHeaderWidget(
                        userName,
                        isShowShape: false,
                        address: walletAddress,
                        isCircle: true,
                      ),
                    ),
                    SizedBox(
                      width: 16.0,
                    ),
                    Expanded(
                      child: accountInfoWidget,
                    ),
                    InkWell(
                      onTap: _navToLevel,
                      child: Container(
                        width: 70,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              "res/drawable/ic_rp_level_$currentLevel.png",
                              height: 33,
                            ),
                            hint,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 0,
                    right: 0,
                    top: 16,
                    bottom: 10,
                  ),
                  child: Container(
                    height: 0.5,
                    color: HexColor('#F2F2F2'),
                  ),
                ),
                if (activeWallet != null)
                  Row(
                    children: <Widget>[
                      InkWell(
                        onTap: _navToMyFriends,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 8,
                                left: 12,
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      '${_rpStatistics?.self?.friends ?? 0}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 4.0,
                                    ),
                                    Text(
                                      S.of(context).rp_friends,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: DefaultColors.color999,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              /*child: _contentColumn(
                                '${_rpStatistics?.self?.friends ?? 0}',
                                S.of(context).rp_friends,
                                contentFontSize: 16,
                              ),*/
                            ),
                            Image.asset(
                              'res/drawable/rp_add_friends_arrow.png',
                              width: 15,
                              height: 15,
                              color: HexColor('#FF5959'),
                            ),
                          ],
                        ),
                      ),
                      //Spacer(),
                      Expanded(
                        child: InkWell(
                          onTap: _navToRPInviteFriends,
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 12,
                                  right: 8,
                                ),
                                child: Text(
                                  S.of(context).rp_invite_to_collect,
                                  style: TextStyle(
                                    color: HexColor('#333333'),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                ),
                              ),
                              Image.asset(
                                'res/drawable/rp_add_friends.png',
                                width: 17,
                                height: 17,
                                color: HexColor('#FF5959'),
                              ),
                            ],
                            mainAxisAlignment: MainAxisAlignment.end,
                          ),
                        ),
                      ),
                    ],
                  ),
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
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: RPAirdropWidget(
              rpStatistics: _rpStatistics,
              rpAirdropRoundInfo: _latestRoundInfo,
              rpLevelAirdropInfo: _rpLevelAirdropInfo,
            ),
          ),
        ),
      ),
    );
  }

  _rpPool() {
    var rpYesterday = '--';
    var myHYNStaking = '--';
    var poolPercent = _rpStatistics?.rpContractInfo?.poolPercent ?? '--';

    try {
      rpYesterday = FormatUtil.stringFormatCoinNum(
        _rpStatistics?.self?.yesterdayStr,
      );
      myHYNStaking = FormatUtil.stringFormatCoinNum(
        _rpStatistics?.self?.totalStakingHynStr,
      );
    } catch (e) {}

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
        ),
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
                      S.of(context).rp_transmit_pool,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 4,
                      ),
                      child: Text(
                        S.of(context).rp_total_amount_percent(poolPercent),
                        style: TextStyle(
                          color: DefaultColors.color999,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 4,
                      ),
                      child: Text(
                        '越早传导，获得越多RP!',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  '$myHYNStaking',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    '${S.of(context).rp_my_hyn_staking} (HYN)',
                    style: TextStyle(
                      color: DefaultColors.color999,
                      fontSize: 12,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 2.0,
                      horizontal: 8.0,
                    ),
                    color: DefaultColors.colorf2f2f2,
                    child: RichText(
                        text: TextSpan(children: [
                      TextSpan(
                          text: '${S.of(context).rp_transmit_yesterday}',
                          style: TextStyle(
                            color: DefaultColors.color999,
                            fontSize: 13,
                          )),
                      TextSpan(
                          text: '  $rpYesterday RP',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ))
                    ])),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: ClickOvalButton(
                    '马上传导',
                    _navToRPPool,
                    width: 140,
                    height: 32,
                    fontSize: 13,
                    btnColor: [
                      HexColor('#FFFF4D4D'),
                      HexColor('#FFFF0829'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _statisticsWidget() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: _cardPadding(),
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
                      '统计',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
                RPStatisticsWidget(),
                SizedBox(
                  height: 16,
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
                      S.of(context).rp_project_intro,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    InkWell(
                      onTap: () {
                        String webUrl = FluroConvertUtils.fluroCnParamsEncode(
                          "https://h.hyn.space/redpocket",
                        );
                        String webTitle = FluroConvertUtils.fluroCnParamsEncode(
                          S.of(context).detailed_introduction,
                        );
                        Application.router.navigateTo(
                            context,
                            Routes.toolspage_webview_page +
                                '?initUrl=$webUrl&title=$webTitle');
                      },
                      child: Text(
                        S.of(context).detailed_introduction,
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
                    _tipRow(S.of(context).rp_desc_1),
                    _tipRow(S.of(context).rp_desc_2),
                    _tipRow(S.of(context).rp_desc_3),
                    _tipRow(S.of(context).rp_desc_4)
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
  /*
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
            fontSize: 14,
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
            fontSize: 10,
            color: DefaultColors.color999,
          ),
        ),
      ],
    );
  }*/

  Widget _toolTipColumn(
    String content,
    String subContent,
    String toolTipMsg,
  ) {
    GlobalKey _toolTipKey = GlobalKey();
    return InkWell(
      onTap: () {
        final dynamic tooltip = _toolTipKey.currentState;
        tooltip?.ensureTooltipVisible();
      },
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                Row(
                  children: [
                    Spacer(),
                    Text(
                      subContent,
                      style: TextStyle(
                        fontSize: 8,
                        color: DefaultColors.color999,
                      ),
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    if (toolTipMsg != null)
                      Tooltip(
                        key: _toolTipKey,
                        verticalOffset: 16,
                        message: toolTipMsg,
                        child: Image.asset(
                          'res/drawable/ic_tooltip.png',
                          width: 10,
                          height: 10,
                        ),
                      ),
                    Spacer(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /*
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
          SizedBox(
            width: 10,
          ),
          Image.asset(
            'res/drawable/rp_add_friends_arrow.png',
            width: 15,
            height: 15,
            color: HexColor('#FF5959'),
          ),
        ],
      ),
    );
  }
  */

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

  /*
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
  */

  ///Actions
  _navToRPPool() {
    var activeWallet = WalletInheritedModel.of(context)?.activatedWallet;
    if (activeWallet != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RpTransmitPage(),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: S.of(context).create_or_import_wallet_first);
    }
  }

  /*
  _navToRPReleaseRecord() {
    var activeWallet = WalletInheritedModel.of(context)?.activatedWallet;
    if (activeWallet != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RpTransmitRecordsPage(),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: S.of(context).create_or_import_wallet_first);
    }
  }*/

  _navToLevel() {
    var activeWallet = WalletInheritedModel.of(context)?.activatedWallet;
    if (activeWallet != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RpLevelRecordsPage(),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: S.of(context).create_or_import_wallet_first);
    }
  }

  _navToManageWallet() {
    WalletManagerPage.jumpWalletManager(context, hasWalletUpdate: (wallet) {
      if (mounted) {
        setState(() {});
      }
    });

    /*Application.router
        .navigateTo(
          context,
          Routes.wallet_manager,
        )
        .then((value) => () {
              if (mounted) {
                setState(() {});
              }
            });*/
  }

  _navToMyFriends() {
    var activeWallet = WalletInheritedModel.of(context)?.activatedWallet;
    if (activeWallet != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RpFriendListPage(),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: S.of(context).create_or_import_wallet_first);
    }
  }

  _navToMyRpRecords() {
    var activeWallet = WalletInheritedModel.of(context)?.activatedWallet;
    if (activeWallet != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RpRecordTabPage(),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: S.of(context).create_or_import_wallet_first);
    }
  }

  _navToRPInviteFriends() {
    var activeWallet = WalletInheritedModel.of(context)?.activatedWallet;
    if (activeWallet != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RpFriendInvitePage(),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: S.of(context).create_or_import_wallet_first);
    }
  }

  _requestData() async {
    var activeWallet = WalletInheritedModel.of(context).activatedWallet;
    var _address = activeWallet?.wallet?.getAtlasAccount()?.address;

    try {
      if (context != null) {
        BlocProvider.of<RedPocketBloc>(context).add(UpdateStatisticsEvent());
      }

      if (context != null) {
        BlocProvider.of<RedPocketBloc>(context).add(UpdateMyLevelInfoEvent());
      }

      if (context != null) {
        BlocProvider.of<WalletCmpBloc>(context)
            .add(UpdateActivatedWalletBalanceEvent());
      }

      _latestRoundInfo = await _rpApi.getLatestRpAirdropRoundInfo(
        _address,
      );

      _rpLevelAirdropInfo = await _rpApi.getLatestLevelAirdropInfo(
        _address,
      );

      if (mounted) {
        _loadDataBloc.add(RefreshSuccessEvent());
        setState(() {});
      }
    } catch (e) {
      _loadDataBloc.add(RefreshFailEvent());
    }
  }
}
