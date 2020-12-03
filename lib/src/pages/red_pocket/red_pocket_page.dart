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
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/red_pocket/api/rp_api.dart';
import 'package:titan/src/pages/red_pocket/rp_my_friends_page.dart';
import 'package:titan/src/pages/red_pocket/rp_invite_friend_page.dart';
import 'package:titan/src/pages/red_pocket/rp_my_rp_records_page.dart';
import 'package:titan/src/pages/red_pocket/rp_transmit_page.dart';
import 'package:titan/src/pages/red_pocket/rp_release_records_page.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/wallet_widget.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  void onCreated() {
    Application.routeObserver.subscribe(this, ModalRoute.of(context));
    super.onCreated();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didPopNext() {
    _requestData();
    super.didPopNext();
  }

  @override
  void dispose() {
    Application.routeObserver.unsubscribe(this);
    super.dispose();
    _loadDataBloc.close();
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
    // var level = _rpInfo?.level ?? '--';
    //var rpToday = _rpStatistics?.self? ?? '--';
    //var rpYesterday = _rpInfo?.rpYesterday ?? '--';
    // var rpMissed = _rpInfo?.rpMissed ?? '--';

    var rpBalance = '--';
    var rpToken = WalletInheritedModel.of(context).getCoinVoBySymbol(
      SupportedTokens.HYN_RP_HRC30_ROPSTEN.symbol,
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

    var rpTodayStr = S.of(context).rp_not_airdrop_1;
    var rpYesterdayStr = S.of(context).rp_not_airdrop_2;
    var rpMissedStr = S.of(context).rp_not_airdrop_3;

    // var avatarPath = activeWallet != null
    //     ? 'res/drawable/ic_map3_node_default_icon.png'
    //     : 'res/drawable/img_avatar_default.png';

    var userName = activeWallet?.wallet?.keystore?.name ?? '--';

    var walletAddress = activeWallet?.wallet?.getEthAccount()?.address ?? "";

    var userAddress = shortBlockChainAddress(
      WalletUtil.ethAddressToBech32Address(
        walletAddress,
      ),
    );

    var accountInfoWidget = activeWallet != null
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
              S.of(context).create_or_import_wallet_first,
              style: TextStyle(
                color: Colors.blue,
              ),
            ),
            onTap: () {
              Application.router
                  .navigateTo(
                    context,
                    Routes.wallet_manager,
                  )
                  .then((value) => () {
                        if (mounted) {
                          setState(() {});
                        }
                      });
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
                InkWell(
                  onTap: _navToMyRpRecords,
                  child: Row(
                    children: [
                      Expanded(
                        child: _contentColumn(
                            rpBalanceStr, S.of(context).rp_balance),
                      ),
                      _verticalLine(),
                      Expanded(
                        child:
                            _contentColumn(rpTodayStr, S.of(context).rp_today_rp),
                      ),
                      _verticalLine(),
                      Expanded(
                        child: _contentColumn(
                            rpYesterdayStr, S.of(context).rp_yesterday_rp),
                      ),
                      _verticalLine(),
                      Expanded(
                        child:
                            _contentColumn(rpMissedStr, S.of(context).rp_missed),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 10,
                  ),
                  child: Container(
                    height: 0.5,
                    color: HexColor('#F2F2F2'),
                  ),
                ),
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
                            child: _contentColumn(
                              '${_rpStatistics?.self?.friends ?? 0}',
                              S.of(context).rp_friends,
                              contentFontSize: 16,
                            ),
                          ),
                          Image.asset(
                            'res/drawable/rp_add_friends_arrow.png',
                            width: 15,
                            height: 15,
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
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                              ),
                            ),
                            Image.asset(
                              'res/drawable/rp_add_friends.png',
                              width: 17,
                              height: 17,
                            ),
                          ],
                          mainAxisAlignment: MainAxisAlignment.end,
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

  _airdropWidget() {
    var airDropPercent = _rpStatistics?.rpContractInfo?.dropOnPercent ?? '--';
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
                          S.of(context).rp_available_soon,
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
                      S.of(context).rp_airdrop,
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
                        S.of(context).rp_total_amount_percent(airDropPercent),
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
    var globalTransmit = '--';
    var poolPercent = _rpStatistics?.rpContractInfo?.poolPercent ?? '--';

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
      globalTransmit = FormatUtil.stringFormatCoinNum(
        _rpStatistics?.global?.transmitStr,
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
                        S.of(context).rp_my_hyn_staking,
                        onTap: _navToRPPool,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: _inkwellColumn(
                        '$rpYesterday RP',
                        S.of(context).rp_transmit_yesterday,
                        onTap: _navToRPReleaseRecord,
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
                        S.of(context).rp_global_hyn_staking,
                      ),
                    ),
                    Expanded(
                      child: _poolInfoColumn(
                        '$globalTransmit RP',
                        S.of(context).rp_global_transmit,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: ClickOvalButton(
                    S.of(context).check,
                    _navToRPPool,
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
  _navToRPPool() {
    var activeWallet = WalletInheritedModel.of(context)?.activatedWallet;
    if (activeWallet != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RpTransmitPage(_rpStatistics),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: S.of(context).create_or_import_wallet_first);
    }
  }

  _navToRPReleaseRecord() {
    var activeWallet = WalletInheritedModel.of(context)?.activatedWallet;
    if (activeWallet != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RpReleaseRecordsPage(_rpStatistics),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: S.of(context).create_or_import_wallet_first);
    }
  }

  _navToMyFriends() {
    var activeWallet = WalletInheritedModel.of(context)?.activatedWallet;
    if (activeWallet != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RpMyFriendsPage(),
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
          builder: (context) => RpMyRpRecordsPage(),
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
          builder: (context) => RpInviteFriendPage(),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: S.of(context).create_or_import_wallet_first);
    }
  }

  _requestData() async {
    var activeWallet = WalletInheritedModel.of(context).activatedWallet;
    try {
      _rpStatistics = await _rpApi.getRPStatistics(
        activeWallet?.wallet?.getAtlasAccount()?.address,
      );

      if (context != null) {
        BlocProvider.of<WalletCmpBloc>(context)
            .add(UpdateActivatedWalletBalanceEvent());
      }

      if (mounted) {
        setState(() {});
      }

      _loadDataBloc.add(RefreshSuccessEvent());
    } catch (e) {
      _loadDataBloc.add(RefreshFailEvent());
    }
  }
}
