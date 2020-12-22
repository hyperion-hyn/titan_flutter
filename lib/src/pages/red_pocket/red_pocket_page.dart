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
import 'package:titan/src/pages/red_pocket/entity/rp_my_level_info.dart';
import 'package:titan/src/pages/red_pocket/rp_my_level_record_page.dart';
import 'package:titan/src/pages/red_pocket/rp_my_friends_page.dart';
import 'package:titan/src/pages/red_pocket/rp_invite_friend_page.dart';
import 'package:titan/src/pages/red_pocket/rp_my_rp_records_page.dart';
import 'package:titan/src/pages/red_pocket/rp_transmit_page.dart';
import 'package:titan/src/pages/red_pocket/rp_transmit_records_page.dart';
import 'package:titan/src/pages/red_pocket/widget/rp_airdrop_widget.dart';
import 'package:titan/src/pages/red_pocket/widget/rp_statistics_widget.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/map3_nodes_widget.dart';
import 'package:titan/src/widget/wallet_widget.dart';
import 'entity/rp_airdrop_round_info.dart';
import 'entity/rp_statistics.dart';
import 'rp_record_tab_page.dart';

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
            physics: BouncingScrollPhysics(),
            slivers: <Widget>[
              _myRPInfo(),
              _airdropWidget(),
              _levelWidget(),
              _rpPool(),
              //_statisticsWidget(),
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
                        fontSize: 13,
                        color: DefaultColors.color999,
                      ),
                      textAlign: TextAlign.end,
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      '$rpBalance',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.end,
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

  _levelWidget() {
    var totalBurningStr = FormatUtil.stringFormatCoinNum(
      _rpStatistics?.rpHoldingContractInfo?.totalBurningStr ?? '0',
      decimal: 4,
    );
    var totalBurning = '$totalBurningStr RP';

    var totalHoldingStr = FormatUtil.stringFormatCoinNum(
      _rpStatistics?.rpHoldingContractInfo?.totalHoldingStr ?? '0',
      decimal: 4,
    );
    var totalHolding = '$totalHoldingStr RP';

    var totalSupplyStr = FormatUtil.stringFormatCoinNum(
      _rpStatistics?.rpHoldingContractInfo?.totalSupplyStr ?? '0',
      decimal: 4,
    );
    var totalSupply = '$totalSupplyStr RP';

    int currentLevel = _myLevelInfo?.currentLevel ?? 0;
    int highestLevel = _myLevelInfo?.highestLevel ?? 0;

    var isShowDowngrade = highestLevel > currentLevel;

    return SliverToBoxAdapter(
      child: Padding(
        padding: _cardPadding(),
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          onTap: _navToLevel,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            '量级',
                            style: TextStyle(
                              color: HexColor('#333333'),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 8,
                            ),
                            child: Text(
                              '当前持币 ${_myLevelInfo?.currentHoldingStr ?? '0'} RP',
                              style: TextStyle(
                                color: HexColor('#999999'),
                                fontSize: 10,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 2,
                            child: SizedBox(),
                          ),
                          Expanded(
                            flex: 3,
                            child: Image.asset(
                              "res/drawable/ic_rp_level_$currentLevel.png",
                              height: 100,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: isShowDowngrade
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                      top: 32,
                                    ),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          'res/drawable/ic_rp_level_down.png',
                                          width: 15,
                                        ),
                                        SizedBox(
                                          width: 6,
                                        ),
                                        Expanded(
                                          child: Text(
                                            '等级下降了',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 6,
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox(),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(
                        currentLevel < 5 ? '去提升' : '去查看',
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                      if (currentLevel == 0)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 20,
                            left: 50,
                            right: 50,
                            bottom: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 4,
                                ),
                                child: Image.asset(
                                  'res/drawable/error_rounded.png',
                                  width: 15,
                                  height: 15,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 4,
                                  ),
                                  child: Text(
                                    '当前量级为0级，不能获得红包，请尽快升级',
                                    style: TextStyle(
                                      color: HexColor('#333333'),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      height: 1.5,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 8),
                          child: Container(
                            child: Text(
                              '你正在参与红包空投',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            decoration: BoxDecoration(
                                color: Colors.orange[500],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4))),
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 16),
                          ),
                        ),
                      SizedBox(
                        height: 16,
                      ),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: _toolTipColumn(
                              totalSupply,
                              '全网已发行量',
                              null,
                            ),
                          ),
                          Expanded(
                            child: _toolTipColumn(
                              totalHolding,
                              '全网量级持币',
                              '参与量级持币的总量',
                            ),
                          ),
                          Expanded(
                            child: _toolTipColumn(
                              totalBurning,
                              '全网燃烧',
                              null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          onTap: _navToRPPool,
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
                      _inkwellColumn(
                        '$myHYNStaking HYN',
                        S.of(context).rp_my_hyn_staking,
                        onTap: _navToRPPool,
                      ),
                      Spacer(),
                      Row(
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: 100,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  '$rpYesterday RP',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: HexColor("#FF001B"),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(
                                  height: 4.0,
                                ),
                                Text(
                                  S.of(context).rp_transmit_yesterday,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: DefaultColors.color999,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 16,
                          )
                        ],
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
                  SizedBox(
                    height: 24,
                  )
                  /*Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: ClickOvalButton(
                      S.of(context).check,
                      _navToRPPool,
                      width: 160,
                      height: 32,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),*/
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _statisticsWidget() {
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
  }

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
          builder: (context) => RpTransmitPage(),
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
          builder: (context) => RpTransmitRecordsPage(),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: S.of(context).create_or_import_wallet_first);
    }
  }

  _navToLevel() {
    var activeWallet = WalletInheritedModel.of(context)?.activatedWallet;
    if (activeWallet != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RpMyLevelRecordsPage(),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: S.of(context).create_or_import_wallet_first);
    }
  }

  _navToManageWallet() {
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
          // builder: (context) => RpRecordTabPage(),
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
      if (mounted) {
        _loadDataBloc.add(RefreshSuccessEvent());
        setState(() {});
      }
    } catch (e) {
      _loadDataBloc.add(RefreshFailEvent());
    }
  }
}
