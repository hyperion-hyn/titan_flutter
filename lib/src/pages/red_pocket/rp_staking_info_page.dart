import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/pages/red_pocket/api/rp_api.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_release_info.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_staking_info.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_statistics.dart';
import 'package:titan/src/pages/wallet/wallet_show_account_info_page.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/utils/format_util.dart';
import 'entity/rp_staking_release_info.dart';

class RpStakingInfoPage extends StatefulWidget {
  final RPStatistics rpStatistics;
  final RpStakingInfo rpStakingInfo;

  RpStakingInfoPage(
    this.rpStatistics,
    this.rpStakingInfo,
  );

  @override
  State<StatefulWidget> createState() {
    return _RpStakingInfoPageState();
  }
}

class _RpStakingInfoPageState extends BaseState<RpStakingInfoPage> with RouteAware {
  final RPApi _rpApi = RPApi();

  final LoadDataBloc _loadDataBloc = LoadDataBloc();

  String get _address => _activeWallet?.wallet?.getEthAccount()?.address ?? "";

  String get _stakingIndex => widget?.rpStakingInfo?.id?.toString() ?? '0';

  WalletVo _activeWallet;
  RPStatistics _rpStatistics;
  RpStakingReleaseInfo _stakingInfo;

  int _currentPage = 1;
  List<RpReleaseInfo> _dataList = [];

  @override
  void initState() {
    super.initState();

    _rpStatistics = widget.rpStatistics;

    _activeWallet = WalletInheritedModel.of(Keys.rootKey.currentContext)?.activatedWallet;
  }

  @override
  void onCreated() {
    _loadDataBloc.add(LoadingEvent());

    Application.routeObserver.subscribe(this, ModalRoute.of(context));

    super.onCreated();
  }

  @override
  void didPopNext() {
    getNetworkData();
  }

  @override
  void dispose() {
    super.dispose();

    Application.routeObserver.unsubscribe(this);
    _loadDataBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: '抵押详情',
        backgroundColor: HexColor('#F8F8F8'),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              WalletShowAccountInfoPage.jumpToAccountInfoPage(
                  context, widget.rpStakingInfo?.txHash ?? '', SupportedTokens.HYN_RP_HRC30.symbol);
            },
            child: Text(
              '查看抵押交易',
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
          slivers: [
            _stakingInfoWidget(),
            _myReleaseListHeader(),
            _myReleaseListView(),
          ],
        ),
      ),
    );
  }

  Widget _stakingInfoWidget() {
    HexColor stateColor = HexColor('#999999');
    String stateDesc = '运行中';
    var model = _stakingInfo;

    //1:确认中 2:失败 3:成功 4:释放中 5:释放结束 6:可取回 7:取回中 8: 已提取
    var status = model?.status ?? 0;
    switch (status) {
      case 1:
        stateColor = HexColor('#FFC500');
        stateDesc = '抵押确认中...';
        break;

      case 2:
        stateColor = HexColor('#999999');
        stateDesc = '失败';
        break;

      case 3:
        stateColor = HexColor('#333333');
        stateDesc = '运行中';
        break;

      case 4:
        stateColor = HexColor('#FFC500');
        stateDesc = '释放中...';
        break;

      case 5:
        stateColor = HexColor('#333333');
        stateDesc = '释放结束';
        break;

      case 6:
        stateColor = HexColor('#00C081');
        stateDesc = '可取回';
        break;

      case 7:
        stateColor = HexColor('#FFC500');
        stateDesc = '取回中...';
        break;

      case 8:
        stateColor = HexColor('#999999');
        stateDesc = '已提取';
        break;
    }

    var hynAmount = FormatUtil.weiToEtherStr(model?.hynAmount ?? '0');
    var hynAmountBig = ConvertTokenUnit.strToBigInt(model?.hynAmount ?? '0');
    var hynPerRpBig = ConvertTokenUnit.strToBigInt(_rpStatistics?.rpContractInfo?.hynPerRp ?? '0');
    var amountBig = (hynAmountBig / hynPerRpBig);

    if (amountBig.isNaN || amountBig.isInfinite) {
      amountBig = 0;
    }

    var amount = amountBig.toInt();
    if (amount.isNaN) {
      amount = 1;
    }

    var stakingAt = FormatUtil.newFormatUTCDateStr(model?.stakingAt ?? '0', isSecond: true);
    var expectReleaseTime = FormatUtil.newFormatUTCDateStr(model?.expectRetrieveTime ?? '0', isSecond: true);

    return SliverToBoxAdapter(
      child: Container(
        color: HexColor('#F8F8F8'),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 12,
            left: 16,
            right: 16,
          ),
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
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 10,
                      ),
                      child: Image.asset(
                        "res/drawable/red_pocket_contract.png",
                        width: 28,
                        height: 28,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 6,
                              ),
                              child: Text(
                                '抵押 $amount 份',
                                style: TextStyle(
                                  color: HexColor("#333333"),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Text(
                              '第 ${model?.releaseTimes ?? 0} 天',
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '价值 $hynAmount HYN',
                              style: TextStyle(
                                color: HexColor("#999999"),
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          stateDesc,
                          //textAlign: TextAlign.end,
                          style: TextStyle(
                            color: stateColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '  ',
                              style: TextStyle(
                                color: HexColor("#999999"),
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 20,
                    bottom: 12,
                  ),
                  child: Container(
                    height: 0.5,
                    color: HexColor('#F2F2F2'),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '抵押时间 ${stakingAt ?? '--'}',
                      //DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(model?.createdAt)),
                      style: TextStyle(
                        fontSize: 10,
                        color: HexColor('#999999'),
                      ),
                      textAlign: TextAlign.left,
                    ),
                    Spacer(),
                    if (status >= 3 && status <= 5)
                      Text(
                        '到期时间 ${expectReleaseTime ?? '--'}',
                        //DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(createAt)),
                        style: TextStyle(
                          fontSize: 10,
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
      ),
    );
  }

  Widget _myReleaseListHeader() {
    return SliverToBoxAdapter(
      child: Container(
        color: HexColor('#F8F8F8'),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 20,
            left: 18,
            bottom: 6,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                'RP传导明细',
                style: TextStyle(
                  color: HexColor("#333333"),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                '累计${FormatUtil.weiToEtherStr(_stakingInfo?.rpAmount ?? '0') ?? '0'} RP',
                style: TextStyle(
                  color: HexColor("#999999"),
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _myReleaseListView() {
    print("[$runtimeType] _dataList?.length:${_dataList?.length ?? 0}");

    if (_dataList?.isEmpty??true) {
      return SliverToBoxAdapter(
        child: Container(
          color: HexColor('#F8F8F8'),
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 160),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: emptyListWidget(title: "暂无数据", isAdapter: false),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return _itemBuilder(index);
        },
        childCount: _dataList?.length ?? 0,
      ),
    );
  }

  Widget _itemBuilder(int index) {
    var model = _dataList[index];
    var rpAmount = FormatUtil.weiToEtherStr(model?.rpAmount ?? '0');
    rpAmount = FormatUtil.stringFormatCoinNum10(rpAmount);

    var currentDate = DateTime.fromMillisecondsSinceEpoch(model.updatedAt * 1000);
    var updatedAt = Const.DATE_FORMAT.format(currentDate);

    return InkWell(
      onTap: () {
        WalletShowAccountInfoPage.jumpToAccountInfoPage(
            context, model?.txHash ?? '', SupportedTokens.HYN_RP_HRC30.symbol);
      },
      child: Container(
        color: HexColor('#F8F8F8'),
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  '+ $rpAmount RP',
                  style: TextStyle(
                    color: HexColor("#333333"),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                Text(
                  updatedAt,
                  style: TextStyle(
                    fontSize: 12,
                    color: HexColor('#999999'),
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void getNetworkData() async {
    _currentPage = 1;
    try {
      var netData = await _rpApi.getStakingReleaseList(
        _stakingIndex,
        _address,
        page: _currentPage,
      );

      _stakingInfo = await _rpApi.getRPStakingReleaseInfo(
        _address,
        _stakingIndex,
      );

      if (mounted) {
        setState(() {
          _loadDataBloc.add(RefreshSuccessEvent());
        });
      }

      if (netData?.isNotEmpty ?? false) {
        _dataList = netData;
      }
    } catch (e) {
      _loadDataBloc.add(LoadFailEvent());
    }
  }

  void getMoreNetworkData() async {
    try {
      _currentPage = _currentPage + 1;
      var netData = await _rpApi.getStakingReleaseList(
        _stakingIndex,
        _address,
        page: _currentPage,
      );

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
