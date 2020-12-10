import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
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
import 'package:titan/src/pages/red_pocket/red_pocket_level_page.dart';
import 'package:titan/src/pages/red_pocket/rp_level_retrieve_page.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

import 'entity/rp_holding_record_entity.dart';
import 'entity/rp_my_level_info.dart';

class RpMyLevelRecordsPage extends StatefulWidget {

  RpMyLevelRecordsPage();

  @override
  State<StatefulWidget> createState() {
    return _RpMyLevelRecordsPageState();
  }
}

class _RpMyLevelRecordsPageState extends BaseState<RpMyLevelRecordsPage>
    with RouteAware {
  final RPApi _rpApi = RPApi();
  final LoadDataBloc _loadDataBloc = LoadDataBloc();

  String get _address => _activeWallet?.wallet?.getEthAccount()?.address ?? "";

  WalletVo _activeWallet;
  RpMyLevelInfo _myLevelInfo;
  int _currentPage = 1;
  List<RpHoldingRecordEntity> _dataList = [];
  int get _currentLevel => _myLevelInfo?.currentLevel ?? 0;

  @override
  void initState() {
    super.initState();

    _activeWallet =
        WalletInheritedModel.of(Keys.rootKey.currentContext)?.activatedWallet;
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
        baseTitle: '持币量级',
        backgroundColor: HexColor('#F8F8F8'),
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
            //_notificationWidget(),
            _myLevelInfoWidget(),
            _myLevelRecordHeader(),
            _myLevelRecordList(),
          ],
        ),
      ),
    );
  }

  Widget _columnWidget(String amount, String title, {bool isBold = true}) {
    return Column(
      children: <Widget>[
        Text(
          '$amount',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        SizedBox(
          height: 4.0,
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: DefaultColors.color999,
          ),
        ),
      ],
    );
  }

  _notificationWidget() {
    return SliverToBoxAdapter(
      child: Container(
        color: HexColor('#F8F8F8'),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 10,
          ),
          child: topNotifyWidget(
            notification: '新的燃烧25RP，抵押25.5RP交易确认中…',
            isWarning: false,
          ),
        ),
      ),
    );
  }

  _myLevelInfoWidget() {
    int level = _myLevelInfo?.currentLevel??0;
    var holding = '--';
    holding = '${_myLevelInfo?.currentHoldingStr??'0'}';

    var isShowDowngrade = false;

    return SliverToBoxAdapter(
      child: Container(
        color: HexColor('#F8F8F8'),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 20,
                  ),
                  child: Container(
                    child: Text(
                      '当前量级',
                      style: TextStyle(
                        color: HexColor('#333333'),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Image.asset(
                  "res/drawable/ic_rp_level_$level.png",
                  height: 100,
                ),
                if (isShowDowngrade)
                  Container(
                    width: 50,
                    child: Row(
                      children: [
                        Image.asset(
                          'res/down-grade.png',
                          width: 30,
                        ),
                        Container(
                          width: 40,
                          child: Text(
                            '等级下降了',
                          ),
                        )
                      ],
                    ),
                  ),
                if (level == 0)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                      left: 50,
                      right: 50,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 4,
                          ),
                          child: Icon(
                            Icons.warning_outlined,
                            color: HexColor('#FF5041'),
                            size: 16,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 4,
                            ),
                            child: Text(
                              '当前量级为0级，不能获得空投红包，请尽快升级',
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
                  ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 22,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /*Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                        ),
                        child: _columnWidget(
                          '$currentBurn RP',
                          '当前燃烧',
                        ),
                        // child: _columnWidget('$totalTransmit RP', '总可传导'),
                      ),*/
                      Spacer(),
                      _columnWidget(
                        '$holding RP',
                        '当期持币',
                      ),
                      Spacer(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 24,
                    bottom: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Container(
                            child: ClickOvalButton(
                              '升级/增持',
                              _navToLevelUpgradeAction,
                              width: 120,
                              height: 32,
                              fontSize: 12,
                              btnColor: [HexColor('#00B97C')],
                            ),
                            padding: const EdgeInsets.all(
                              16,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Image.asset(
                              "res/drawable/red_pocket_exchange_hot.png",
                              width: 35,
                              height: 20,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        width: 14,
                      ),
                      ClickOvalButton(
                        '取回持币',
                        _navToLevelUnStakingAction,
                        width: 120,
                        height: 32,
                        fontSize: 12,
                        btnColor: [HexColor('#107EDC')],
                      ),
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

  _myLevelRecordHeader() {
    return SliverToBoxAdapter(
      child: Container(
        color: HexColor('#F8F8F8'),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 20,
            left: 18,
            bottom: 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                '量级记录',
                style: TextStyle(
                  color: HexColor("#333333"),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _myLevelRecordList() {
    if (_dataList?.isEmpty ?? true) {
      return SliverToBoxAdapter(
        child: Container(
          color: HexColor('#F8F8F8'),
          child: Padding(
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, top: 16.0, bottom: 160),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: emptyListWidget(
                  title: S.of(context).rp_empty_staking_record,
                  isAdapter: false),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return _levelRecordItem(index);
        },
        childCount: _dataList.length,
      ),
    );
  }

  Widget _levelRecordItem(index) {

    var model = _dataList[index];
    bool isUpgrade = true;
    var txHash = model.txHash;

    var levelFrom = '${model.from}';
    var levelTo = '${model.to}';


    //主动降级、被动降级、升级、补偿升级、增持升级
    var recordType = model.type;
    var detailStr = '';
    var isShowStatus = false;
    if (recordType == 0) {
      detailStr = '燃烧 ${model.holdingStr} RP，增持 ${model.burningStr} RP';
      isShowStatus = true;
    } else if (recordType == 1) {
      detailStr = '取回持币 ${model.withdrawStr} RP';
      isShowStatus = true;
    } else if (recordType == 2) {
      detailStr = '全网发行增长调整';
      isShowStatus = false;
    } else if (recordType == 3) {
      detailStr = '增持${model.holdingStr}RP';
      isShowStatus = true;
    }

    var recordStatus = model?.state??0;
    var statusHint = '进行中';
    var statusColor = HexColor('#FFE4B300');
    if (recordStatus == 0) {
      statusHint = '进行中';
      statusColor = HexColor('#FFE4B300');
    } else if (recordStatus == 1) {
      statusHint = '成功';
      statusColor = HexColor('#FF999999');
    } else if (recordStatus == 2) {
      statusHint = '失败';
      statusColor = HexColor('#FFEB3737');
    }
    var recordTime = model.createdAt;

    var statusIcon = isShowStatus
        ? Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: HexColor('#FFF2F2F2'),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
                child: Text(
                  statusHint,
                  style: TextStyle(fontSize: 9, color: statusColor),
                ),
              ),
            ),
          )
        : Container();

    return InkWell(
      onTap: () {
        _navToTxDetail(txHash);
      },
      child: Stack(
        children: [
          Container(
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 10,
                          ),
                          child: Image.asset(
                            "res/drawable/red_pocket_level_${isUpgrade ? 'up' : 'down'}.png",
                            width: 22,
                            height: 22,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text(
                                  '$levelTo 级',
                                  style: TextStyle(
                                    color: HexColor("#333333"),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              '$levelFrom级 -> $levelTo级',
                              style: TextStyle(
                                fontSize: 12,
                                color: HexColor('#999999'),
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  detailStr,
                                  style: TextStyle(
                                    color: HexColor("#333333"),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              statusIcon,
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            '${recordTime ?? '--'}',
                            //DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(model?.createdAt)),
                            style: TextStyle(
                              fontSize: 12,
                              color: HexColor('#999999'),
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (index == 0)
            Positioned(
              right: 26,
              top: 4,
              child: Container(
                decoration: BoxDecoration(
                    color: HexColor("#FF4C3B"),
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 1, 8, 3),
                  child: Center(
                    child: Text(
                      'new',
                      style: TextStyle(
                          fontSize: 10,
                          color: HexColor("#FFFFFF"),
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void getNetworkData() async {
    _currentPage = 1;

    try {

      // todo:   "msg": "Unknown error",
      _myLevelInfo = await _rpApi.getRPMyLevelInfo(_address);

      var netData = await _rpApi.getRpHoldingHistory(
        _address,
        page: _currentPage,
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
      var netData =
          await _rpApi.getRpHoldingHistory(_address, page: _currentPage);

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

  _navToTxDetail(String txHash) {}

  _navToLevelUnStakingAction() {

    if (_currentLevel == 0) {
      Fluttertoast.showToast(
        msg: '当前量级为0，可取回持币金额为0！',
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RpLevelRetrievePage(_myLevelInfo),
      ),
    );
  }

  _navToLevelUpgradeAction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RedPocketLevelPage(_myLevelInfo),
      ),
    );
    return;
  }
}
