import 'dart:ui';

import 'package:decimal/decimal.dart';
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
import 'package:titan/src/pages/red_pocket/entity/rp_my_rp_record_entity.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_util.dart';
import 'package:titan/src/pages/wallet/wallet_show_trasaction_simple_info_page.dart';
import 'package:titan/src/plugins/wallet/config/tokens.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/wallet_widget.dart';

class RpRecordDetailPage extends StatefulWidget {
  final RpOpenRecordEntity rpOpenRecordEntity;

  RpRecordDetailPage({this.rpOpenRecordEntity});

  @override
  State<StatefulWidget> createState() {
    return _RpRecordDetailState();
  }
}

class _RpRecordDetailState extends BaseState<RpRecordDetailPage> {
  final LoadDataBloc _loadDataBloc = LoadDataBloc();
  final RPApi _rpApi = RPApi();

  var _address = "";

  List<RpOpenRecordEntity> _dataList = List();

  List<RpOpenRecordEntity> get _filterDataList => _dataList.where((element) => element.role == 3).toList();

  List<RpOpenRecordEntity> get _manageDataList => _dataList.where((element) => element.role != 3).toList();

  RpOpenRecordEntity _detailEntity;

  RedPocketType get _rpType => RedPocketType.values[_detailEntity?.type ?? 0];

  Map<String, dynamic> _currentPageKey;

  bool get _txHashIsEmpty => (_detailEntity?.txHash ?? '').isEmpty;

  @override
  void initState() {
    super.initState();

    _detailEntity = widget.rpOpenRecordEntity;

    var activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext)?.activatedWallet;
    _address = activatedWallet?.wallet?.getEthAccount()?.address ?? "";
  }

  @override
  void onCreated() {
    //_loadDataBloc.add(LoadingEvent());
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
        baseTitle: S.of(context).rp_redpocket_detail,
        backgroundColor: HexColor('#F8F8F8'),
        actions: <Widget>[
          FlatButton(
            onPressed: _txHashIsEmpty ? null : _navToDetailAction,
            child: Text(
              _txHashIsEmpty ? '' : S.of(context).check_tx,
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
                _infoDetailWidget(),
                _rpListHeaderWidget(),
              ],
            ),
          ),
          _rpRecordListWidget(),
        ],
      ),
    );
  }

  GlobalKey _toolTipKey = GlobalKey();

  Widget _infoDetailWidget() {
    var title = '';
    var subTitle = '';

    var name = _detailEntity?.username ?? '';
    if (name.isEmpty) {
      name = S.of(context).user;
    }
    //print("[$runtimeType] _infoDetailBuilder, rpType:$_rpType");

    var amount = '-- RP';

    var amountStr = FormatUtil.stringFormatCoinNum(
      _detailEntity?.amountStr ?? '0',
      decimal: 4,
    );
    amountStr = '$amountStr RP';
    var zeroAmountStr = '0 RP';
    var luckState = RpLuckState.values[(_detailEntity?.luck ?? 0)];

    var from = levelValueToLevelName(_detailEntity?.from ?? 0);
    var to = levelValueToLevelName(_detailEntity?.to ?? 0);
    var level = levelValueToLevelName(_detailEntity?.level ?? 0);

    switch (_rpType) {
      case RedPocketType.LUCKY:
        title = S.of(context).rp_lucky_pocket;

        amount = luckState == RpLuckState.MISS ? zeroAmountStr : amountStr;
        break;

      case RedPocketType.LEVEL:
        title = S.of(context).level_rp;
        subTitle = '（${S.of(context).rp_level}$level）';

        amount = amountStr;
        break;

      case RedPocketType.PROMOTION:
        title = S.of(context).promotion_rp;

        amount = luckState == RpLuckState.MISS ? zeroAmountStr : amountStr;
        break;

      default:
        title = '';
        amount = '-- RP';
        break;
    }

    var beach32Address = WalletUtil.ethAddressToBech32Address(
      _detailEntity?.address ?? '',
    );
    var address = shortBlockChainAddress(beach32Address);

    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 12, right: 12, bottom: 6),
      child: Container(
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
            if (_rpType == RedPocketType.PROMOTION)
              Padding(
                padding: const EdgeInsets.only(
                  top: 6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /*
                    Text(
                      name,
                      style: TextStyle(
                        color: HexColor("#333333"),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    */
                    Text(
                      address,
                      style: TextStyle(
                        color: HexColor("#999999"),
                        fontSize: 10,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            if (_rpType == RedPocketType.PROMOTION)
              Padding(
                padding: const EdgeInsets.only(
                  top: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${S.of(context).rp_level} $from -> ${S.of(context).rp_level} $to',
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
                  Flexible(
                    child: Text(
                      amount,
                      style: TextStyle(
                        color: HexColor("#E3A900"),
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                      ),
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
            if (_detailEntity.luck == 0)
              InkWell(
                onTap: () {
                  final dynamic tooltip = _toolTipKey.currentState;
                  tooltip.ensureTooltipVisible();
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        S.of(context).you_missed_rp,
                        style: TextStyle(
                          color: HexColor("#999999"),
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      Tooltip(
                        key: _toolTipKey,
                        verticalOffset: 20,
                        message: S.of(context).rp_detail_ignore_func(amountStr),
                        child: Image.asset(
                          'res/drawable/ic_tooltip.png',
                          width: 10,
                          height: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }

  _rpListHeaderWidget() {
    var createdAt = _detailEntity?.createdAt ?? 0;
    var createdAtDate = DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);
    var createdAtStr = Const.DATE_FORMAT.format(createdAtDate);
    String totalAmountStr = FormatUtil.stringFormatCoinNum(_detailEntity?.totalAmountStr ?? "0", decimal: 4,) ?? '--';

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
            S.of(context).rp_detail_total_func(totalAmountStr),
            style: TextStyle(
              color: Color(0xff333333),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          Spacer(),
          Text(
            createdAtStr ?? '--',
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
                S.of(context).no_data,
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
      var childCount = 0;
      switch (_rpType) {
        case RedPocketType.LEVEL:
          childCount = _filterDataList.length + 2;

          break;

        case RedPocketType.PROMOTION:
        case RedPocketType.LUCKY:
          childCount = _filterDataList.length + 1;
          break;
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return _itemBuilder(index);
          },
          childCount: childCount,
        ),
      );
    }
  }

  Widget _itemBuilder(int index) {
    switch (_rpType) {
      case RedPocketType.LEVEL:
        if (index == _filterDataList.length) {
          return _levelWidget();
        } else if (index == (_filterDataList.length + 1)) {
          return _manageWidget();
        }

        break;

      case RedPocketType.PROMOTION:
      case RedPocketType.LUCKY:
        if (index == _filterDataList.length) {
          //return _manageWidget();
          return _promotionWidget();
        }

        break;
    }

    var model = _filterDataList[index];

    var role = '';
    switch (RpAddressRoleType.values[model.role]) {
      case RpAddressRoleType.BURN:
        role = S.of(context).rp_burn;
        break;

      case RpAddressRoleType.MANAGE_FEE:
        role = S.of(context).manage_fee;
        break;

      case RpAddressRoleType.NORMAL:
      default:
        role = '';
        break;
    }

    var name = model?.username ?? '';
    if (name.isEmpty) {
      name = S.of(context).user;
    }
    name += role;

    var level = levelValueToLevelName(model?.level ?? 0);
    var beach32Address = WalletUtil.ethAddressToBech32Address(
      model?.address ?? '',
    );
    var address = shortBlockChainAddress(beach32Address);

    var luckState = RpLuckState.values[(model?.luck ?? 0)];
    var rpInfoModel = getRpLuckStateInfo(model);
    var desc = rpInfoModel.desc;
    var amount = rpInfoModel.amount;

    var userAddress = model?.address ?? '';
    bool isMe = _address.isNotEmpty && userAddress.isNotEmpty && (userAddress.toLowerCase() == _address.toLowerCase());

    return InkWell(
      onTap: _txHashIsEmpty ? null : _navToDetailAction,
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
                    address: model?.address ?? '',
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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        /*
                        Padding(
                          padding: EdgeInsets.only(
                            right: isMe ? 2 : 6,
                          ),
                          child: name.isNotEmpty
                              ? Text(
                                  name,
                                  style: TextStyle(
                                    color: HexColor("#333333"),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              : SizedBox(),
                        ),

                        */
                        Text(
                          '${UiUtil.shortEthAddress(address)}',
                          //DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(createAt)),
                          style: TextStyle(
                            fontSize: 12,
                            color: HexColor('#333333'),
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        if (isMe)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 6,
                            ),
                            child: Text(
                              '(${S.of(context).me})',
                              style: TextStyle(
                                color: HexColor("#999999"),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '${S.of(context).rp_detail_current_level} $level ',
                    style: TextStyle(
                      color: HexColor("#999999"),
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                    ),
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
                      Text(
                        desc,
                        style: TextStyle(
                          fontSize: 10,
                          color: ([RpLuckState.BEST, RpLuckState.LUCKY_BEST].contains(luckState))
                              ? HexColor('#F0BE00')
                              : HexColor('#999999'),
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

  Widget _levelWidget() {

    var otherEntity = _dataList.isNotEmpty?_dataList[0]:null;
    return Padding(
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
                          S.of(context).other_same_level_users,
                          style: TextStyle(
                            color: HexColor("#333333"),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      ' ${otherEntity?.otherUserCount ?? 0} ${S.of(context).rp_unit}',
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
                      '+ ${FormatUtil.stringFormatCoinNum(otherEntity.otherUserAmountStr ?? '0', decimal: 4,)} RP',
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
    );
  }

  Widget _promotionWidget() {
    var _manageFeeAmount = Decimal.fromInt(0);
    var _burnAmount = Decimal.fromInt(0);

    _manageDataList.forEach((item) {
      var bigIntValue = BigInt.tryParse(item.amount) ?? BigInt.from(0);
      Decimal valueByDecimal = ConvertTokenUnit.weiToEther(
        weiBigInt: bigIntValue,
      );
      if (item.role == 1) {
        _burnAmount = valueByDecimal;
      } else if (item.role == 2) {
        _manageFeeAmount = valueByDecimal;
      }
    });
    var _manageFeeAmountStr = FormatUtil.stringFormatCoinNum(
          _manageFeeAmount.toString(),
          decimal: 4,
        ) +
        ' RP';
    var _burnAmountStr = FormatUtil.stringFormatCoinNum(
          _burnAmount.toString(),
          decimal: 4,
        ) +
        ' RP';

    Widget rowText(String imageName, String title, String amount,
        {bool isRebuild = false, MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start}) {
      return Expanded(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: mainAxisAlignment,
          children: <Widget>[
            Image.asset(
              'res/drawable/$imageName.png',
              width: 16,
              height: 16,
              color: isRebuild ? HexColor('#FFFF5151') : null,
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 4,
              ),
              child: Text(
                title,
                style: TextStyle(
                  color: HexColor("#999999"),
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 4,
                ),
                child: Text(
                  amount,
                  style: TextStyle(
                    color: HexColor("#333333"),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 12, right: 12, bottom: 6),
      child: Container(
        padding: const EdgeInsets.only(
          top: 16,
          bottom: 16,
          left: 16,
          right: 16,
        ),
        decoration: BoxDecoration(
          color: HexColor('#FFFFFF'),
          borderRadius: BorderRadius.all(
            Radius.circular(6.0),
          ), //设置四周圆角 角度
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            rowText('rp_manage_fee', S.of(context).manage_fee, _manageFeeAmountStr),
            SizedBox(
              width: 12,
            ),
            rowText(
              'ic_burn',
              S.of(context).rp_burn,
              _burnAmountStr,
              isRebuild: true,
              mainAxisAlignment: MainAxisAlignment.end,
            ),
          ],
        ),
      ),
    );
  }

  Widget _manageWidget() {
    var _manageFeeAmount = Decimal.fromInt(0);

    _manageDataList.forEach((item) {
      var bigIntValue = BigInt.tryParse(item.amount) ?? BigInt.from(0);
      Decimal valueByDecimal = ConvertTokenUnit.weiToEther(
        weiBigInt: bigIntValue,
      );
      if (item.role == 2) {
        _manageFeeAmount = valueByDecimal;
      }
    });
    var _manageFeeAmountStr = '${S.of(context).manage_fee} ' + FormatUtil.stringFormatCoinNum(_manageFeeAmount.toString(), decimal: 4,) + ' RP';

    return Padding(
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
                left: 6,
              ),
              child: Image.asset(
                'res/drawable/rp_manage_fee.png',
                width: 24,
                height: 24,
                //color: HexColor('#FFFF5151'),
              ),
            ),
            Spacer(),
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
                          _manageFeeAmountStr,
                          style: TextStyle(
                            color: HexColor("#333333"),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _navToDetailAction() {
    if (_txHashIsEmpty) return;

    WalletShowTransactionSimpleInfoPage.jumpToAccountInfoPage(
      context,
      _detailEntity?.txHash,
      DefaultTokenDefine.HYN_RP_HRC30.symbol,
    );
  }

  void getNetworkData() async {

    _currentPageKey = null;

    try {
      _detailEntity = await _rpApi.getMyRpOpenInfo(
        _address,
        _detailEntity?.redPocketId ?? 0,
        _detailEntity?.type ?? 0,
      );

      var netData = await _rpApi.getMySlitRpRecordList(
        _address,
        pagingKey: _currentPageKey,
        redPocketId: _detailEntity?.redPocketId ?? 0,
        redPocketType: _detailEntity?.type ?? 0,
      );
      if (netData?.data?.isNotEmpty ?? false) {
        _currentPageKey = netData.pagingKey;

        _dataList = filterRpOpenDataList(netData.data);
      }

      if (mounted) {
        setState(() {
          _loadDataBloc.add(RefreshSuccessEvent());
        });
      }
    } catch (e) {
      _loadDataBloc.add(LoadFailEvent());
    }
  }

  void getMoreNetworkData() async {
    if (_currentPageKey?.isEmpty ?? true) {
      _loadDataBloc.add(LoadMoreEmptyEvent());
      return;
    }

    try {
      var netData = await _rpApi.getMySlitRpRecordList(
        _address,
        pagingKey: _currentPageKey,
        redPocketId: _detailEntity?.redPocketId ?? 0,
        redPocketType: _detailEntity?.type ?? 0,
      );

      if (netData?.data?.isNotEmpty ?? false) {
        _currentPageKey = netData.pagingKey;

        _dataList.addAll(filterRpOpenDataList(netData.data));
      }

      // _loadDataBloc.add(LoadingMoreSuccessEvent());

      if (mounted) {
        setState(() {
          _loadDataBloc.add(LoadingMoreSuccessEvent());
        });
      }
    } catch (e) {
      _loadDataBloc.add(LoadMoreFailEvent());
    }
  }
}
