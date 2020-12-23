import 'dart:async';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/rp/bloc/bloc.dart';
import 'package:titan/src/components/rp/redpocket_component.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/pages/red_pocket/api/rp_api.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_staking_info.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_statistics.dart';
import 'package:titan/src/pages/red_pocket/rp_transmit_records_page.dart';
import 'package:titan/src/pages/red_pocket/rp_transmit_detail_page.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

import 'entity/rp_util.dart';

class RpTransmitPage extends StatefulWidget {

  RpTransmitPage();

  @override
  State<StatefulWidget> createState() {
    return _RpTransmitPageState();
  }
}

class _RpTransmitPageState extends BaseState<RpTransmitPage> with RouteAware {
  final RPApi _rpApi = RPApi();
  final _formKey = GlobalKey<FormState>();
  final LoadDataBloc _loadDataBloc = LoadDataBloc();
  final TextEditingController _textEditController = TextEditingController();
  final StreamController<String> _inputController = StreamController.broadcast();

  String get _address => _activeWallet?.wallet?.getEthAccount()?.address ?? "";

  String get _hynPerRpStr => _rpStatistics?.rpContractInfo?.hynPerRpStr;

  String get _hynPerRp => FormatUtil.stringFormatCoinNum(_hynPerRpStr) ?? '--';

  double get _hynPerRpValue => double?.tryParse(_hynPerRpStr) ?? 0;

  WalletVo _activeWallet;
  RPStatistics _rpStatistics;
  int _currentPage = 1;
  List<RpStakingInfo> _dataList = [];


  @override
  void initState() {
    super.initState();

    _activeWallet = WalletInheritedModel.of(Keys.rootKey.currentContext)?.activatedWallet;
  }

  @override
  void onCreated() {
    _loadDataBloc.add(LoadingEvent());

    Application.routeObserver.subscribe(this, ModalRoute.of(context));

    super.onCreated();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _rpStatistics = RedPocketInheritedModel.of(context).rpStatistics;
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
    _inputController.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: S.of(context).rp_transmit_pool,
        backgroundColor: HexColor('#F8F8F8'),
        actions: <Widget>[
          FlatButton(
            onPressed: _pushRecordAction,
            child: Text(
              S.of(context).rp_transmit_detail,
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
            _poolInfo(),
            _myRPInfo(),
            _myContractHeader(),
            _myContractList(),
          ],
        ),
      ),
    );
  }

  Widget _columnWidget(String amount, String title, {bool isBold = false}) {
    return Column(
      children: <Widget>[
        Text(
          '$amount',
          style: TextStyle(
            fontSize: 12,
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
            fontSize: 10,
            color: DefaultColors.color999,
          ),
        ),
      ],
    );
  }

  Widget _lineWidget() {
    return Container(
      height: 20,
      width: 0.5,
      color: HexColor('#000000').withOpacity(0.2),
    );
  }

  _poolInfo() {
    String totalStakingHyn = FormatUtil.stringFormatCoinNum(_rpStatistics?.global?.totalStakingHynStr) ?? '--';
    String transmit = FormatUtil.stringFormatCoinNum(_rpStatistics?.global?.transmitStr) ?? '--';
    //String totalTransmit = FormatUtil.stringFormatCoinNum(_rpStatistics?.global?.totalTransmitStr) ?? '--';

    return SliverToBoxAdapter(
      child: Container(
        color: HexColor('#F8F8F8'),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 10,
            bottom: 6,
            left: 26,
            right: 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _columnWidget(
                '${_rpStatistics?.rpContractInfo?.poolPercent ?? '--'}${S.of(context).rp_million_rp}',
                S.of(context).rp_total_available_transmit,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: _lineWidget(),
              ),
              Expanded(
                child: _columnWidget(
                  '$totalStakingHyn HYN',
                  S.of(context).rp_global_hyn_staking,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: _lineWidget(),
              ),
              Expanded(
                child: _columnWidget(
                  '$transmit RP',
                  S.of(context).rp_global_transmit,
                ),
              ),
              //Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  _myRPInfo() {
    int totalAmount = _rpStatistics?.self?.totalAmount ?? 0;
    String totalStakingHyn = FormatUtil.stringFormatCoinNum(_rpStatistics?.self?.totalStakingHynStr) ?? '--';
    String totalRp = FormatUtil.stringFormatCoinNum(_rpStatistics?.self?.totalRpStr) ?? '--';
    String yesterday = FormatUtil.stringFormatCoinNum(_rpStatistics?.self?.yesterdayStr) ?? '--';

    String baseRp = _rpStatistics?.rpContractInfo?.baseRpStr ?? '--';
    var baseRpStr = _rpStatistics?.rpContractInfo?.baseRpStr??'0';
    var baseRpValue = Decimal.tryParse(baseRpStr)??Decimal.zero;
    if (baseRpValue > Decimal.one) {
      baseRp = FormatUtil.stringFormatCoinNum(baseRpStr, decimal: 4) ?? '--';
    }
    else {
      baseRp = FormatUtil.stringFormatCoinNum(baseRpStr, decimal: 8) ?? '--';
    }

    var releaseDay = (_rpStatistics?.rpContractInfo?.releaseDay ?? '0');
    var stakingDay = (_rpStatistics?.rpContractInfo?.stakingDay ?? '0');

    var htmlData = '''
    <p>
    前每份（<span>$_hynPerRp</span> HYN）总共可传导出<span>$baseRp</span> RP，分<span>$releaseDay</span> 天释放。<span>$stakingDay</span>天后可取回已抵押的HYN。
    </p>
    ''';
    htmlData = S.of(context).rp_swap_pool_transmit_func(_hynPerRp, baseRp, releaseDay, stakingDay);
    return SliverToBoxAdapter(
      child: Container(
        color: HexColor('#F8F8F8'),
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 26,
                    //bottom: 16,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 12,
                          // right: 20,
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 4,
                              ),
                              child: Text(
                                '${S.of(context).rp_already_stake}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: DefaultColors.color999,
                                ),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  '$totalAmount${S.of(context).rp_amount_unit}',
                                  style: TextStyle(
                                    color: DefaultColors.color333,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '（$totalStakingHyn HYN）',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: DefaultColors.color999,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          crossAxisAlignment: CrossAxisAlignment.start,
                        ),
                      ),
                      _columnWidget('$totalRp RP', S.of(context).rp_my_total_transmit, isBold: true),
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 8,
                          // right: 10,
                          // left: 10,
                        ),
                        child: _lineWidget(),
                      ),
                      InkWell(
                        onTap: _pushRecordAction,
                        child: Row(
                          children: <Widget>[
                            _columnWidget('$yesterday RP', S.of(context).rp_my_yesterday_transmit, isBold: true),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 8,
                                right: 8,
                                bottom: 12,
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: 15,
                                color: DefaultColors.color999,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 0,
                    top: 16,
                    left: 30,
                    right: 30,
                  ),
                  child: Row(
                    children: <Widget>[
                      /*
                      Expanded(
                        flex: 2,
                        child: RichText(
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: S.of(context).rp_transmit_desc_1(_hynPerRp),
                            style: TextStyle(
                              fontSize: 10,
                              color: HexColor("#999999"),
                              fontWeight: FontWeight.normal,
                              height: 1.5,
                            ),
                            children: [
                              TextSpan(
                                text: '$baseRp',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: HexColor("#333333"),
                                  fontWeight: FontWeight.w500,
                                  height: 1.8,
                                ),
                              ),
                              TextSpan(
                                text: ' ${S.of(context).rp_transmit_desc_2(
                                  releaseDay,
                                  stakingDay,
                                )}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: HexColor("#999999"),
                                  fontWeight: FontWeight.normal,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      */
                      Expanded(
                        //width: 230,
                        child: Html(
                          data: htmlData,
                          style: {
                            "p": Style(
                              textAlign: TextAlign.center,
                              fontSize: FontSize(10),
                              color: HexColor('#999999'),
                              lineHeight: 1.8,
                            ),
                            "span": Style(
                              fontWeight: FontWeight.bold,
                              fontSize: FontSize(10),
                              color: HexColor('#333333'),
                            )
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 6,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ClickOvalButton(
                        S.of(context).rp_retrive_hyn,
                        _showCollectAlertView,
                        width: 120,
                        height: 32,
                        fontSize: 12,
                        btnColor: [HexColor('#00B97C')],
                      ),
                      SizedBox(
                        width: 14,
                      ),
                      Stack(
                        children: <Widget>[
                          Container(
                            child: ClickOvalButton(
                              S.of(context).rp_stake_hyn,
                              _showStakingAlertView,
                              width: 120,
                              height: 32,
                              fontSize: 12,
                              btnColor: [HexColor('#107EDC')],
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

  _myContractHeader() {
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
                S.of(context).rp_my_hyn_staking,
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

  _myContractList() {
    if (_dataList?.isEmpty ?? true) {
      return SliverToBoxAdapter(
        child: Container(
          color: HexColor('#F8F8F8'),
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 160),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: emptyListWidget(title: S.of(context).rp_empty_staking_record, isAdapter: false),
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

  Widget _itemBuilder(index) {
    var model = _dataList[index];
    var status = model?.status ?? 0;
    HexColor stateColor = getStateColor(status);
    String stateDesc = getStateDesc(status);
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

    return InkWell(
      onTap: () => _pushStakingInfoAction(index),
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
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 6,
                              ),
                              child: Text(
                                '$amount ${S.of(context).rp_amount_unit}',
                                style: TextStyle(
                                  color: HexColor("#333333"),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '${S.of(context).rp_total_pretext} $hynAmount HYN',
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
                        Text(
                          '${S.of(context).rp_staking_id}：${(model?.stakingId ?? -1) == -1 ? '--' : model?.stakingId ?? 0}',
                          //DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(createAt)),
                          style: TextStyle(
                            fontSize: 12,
                            color: HexColor('#333333'),
                          ),
                          textAlign: TextAlign.left,
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
                          style: TextStyle(
                            color: stateColor,
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Text(
                          '${stakingAt ?? '--'}',
                          //DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(model?.createdAt)),
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
                if (status >= 3 && status <= 5)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 6,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          '${expectReleaseTime ?? '--'}${S.of(context).rp_hyn_can_retrieved}',
                          //DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(createAt)),
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
    );
  }

  void getNetworkData() async {
    _currentPage = 1;
    try {

      if (context != null) {
        BlocProvider.of<RedPocketBloc>(context).add(UpdateStatisticsEvent());
      }

      var netData = await _rpApi.getRPStakingInfoList(_address, page: _currentPage);

      if (mounted) {
        setState(() {
          _loadDataBloc.add(RefreshSuccessEvent());
        });
      }

      if (netData?.isNotEmpty ?? false) {
        _dataList = netData;
      }

    } catch (e) {
      if (mounted) {
        _loadDataBloc.add(LoadFailEvent());
      }
    }
  }

  void getMoreNetworkData() async {
    try {
      _currentPage = _currentPage + 1;
      var netData = await _rpApi.getRPStakingInfoList(_address, page: _currentPage);

      if (netData?.isNotEmpty ?? false) {
        if (mounted) {
          setState(() {
            _dataList.addAll(netData);
            _loadDataBloc.add(LoadingMoreSuccessEvent());
          });
        }
      } else {
        _loadDataBloc.add(LoadMoreEmptyEvent());
      }
    } catch (e) {
      if (mounted) {
        _loadDataBloc.add(LoadMoreFailEvent());
      }
    }
  }

  _showStakingAlertView() {
    var border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(
        color: HexColor('#FFF2F2F2'),
        width: 0.5,
      ),
    );

    _textEditController.text = "";

    UiUtil.showAlertView(
      context,
      title: S.of(context).rp_staking_amount,
      isInputValue: true,
      actions: [
        ClickOvalButton(
          S.of(context).confirm,
          _stakingAction,
          width: 200,
          height: 38,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ],
      detail: S.of(context).rp_hyn_locked_hint(_rpStatistics?.rpContractInfo?.stakingDay ?? 0),
      contentItem: Material(
        child: Form(
          key: _formKey,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.only(
              left: 22,
              right: 22,
              bottom: 16,
            ),
            child: Column(
              children: <Widget>[
                TextFormField(
                  autofocus: true,
                  controller: _textEditController,
                  keyboardType: TextInputType.numberWithOptions(decimal: false),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(18),
                    FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                  ],
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return S.of(context).rp_input_staking_amount;
                    }

                    if ((value?.length ?? 0) > 18) {
                      return S.of(context).rp_transmit_input_hint;
                    }

                    var hynToken = WalletInheritedModel.of(context).getCoinVoBySymbol(
                      SupportedTokens.HYN_Atlas.symbol,
                    );
                    var hynTokenBalance = Decimal.parse(hynToken.balance.toString());
                    var amount = int.tryParse(value) ?? 0;
                    if (amount <= 0) {
                      return S.of(context).rp_input_staking_amount;
                    }

                    var total = _hynPerRpValue * amount;
                    var amountBig = ConvertTokenUnit.strToBigInt(total.toString());
                    var inputValue = Decimal.parse(amountBig.toString());
                    var isOver = inputValue > hynTokenBalance;
                    // print(
                    //     "[$runtimeType] isOver:$isOver, hynTokenBalance:$hynTokenBalance, inputValue:$inputValue, amount:$amount");
                    if (isOver) {
                      return S.of(context).rp_not_enough_hyn;
                    }

                    return null;
                  },
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: HexColor('#FFF2F2F2'),
                    hintText: S.of(context).rp_input_staking_amount_with_hyn(_hynPerRp),
                    hintStyle: TextStyle(
                      color: HexColor('#FF999999'),
                      fontSize: 13,
                    ),
                    focusedBorder: border,
                    focusedErrorBorder: border,
                    enabledBorder: border,
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Colors.red,
                        width: 0.5,
                      ),
                    ),
                    //contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  style: TextStyle(fontSize: 13),
                  onSaved: (value) {
                    // print("[$runtimeType] onSaved, inputValue:$value");
                  },
                  onChanged: (String value) {
                    // print("[$runtimeType] onChanged, inputValue:$value");

                    _inputController.add(value);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    StreamBuilder<Object>(
                        stream: _inputController.stream,
                        builder: (context, snapshot) {
                          var inputText = snapshot?.data ?? '0';
                          var total = (_hynPerRpValue.toInt()) * (int.tryParse(inputText) ?? 0);

                          if (total <= 0) {
                            total = 0;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(
                              top: 4,
                              left: 4,
                            ),
                            child: Text(
                              '${S.of(context).rp_worth} $total HYN',
                              style: TextStyle(
                                color: HexColor('#333333'),
                                fontSize: 12,
                              ),
                            ),
                          );
                        }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _showCollectAlertView() async {
    int count = 0;
    String hynSum = '0';

    try {
      var response = await _rpApi.getCanRetrieve(_address);
      print("[$runtimeType] getCanRetrieve, response:$response");

      var data = response;
      if ((data != null) && (data is Map<String, dynamic>)) {
        var json = data;

        if (json.keys.contains('count')) {
          count = json['count'] as int;
        }

        if (json.keys.contains('hyn_sum')) {
          hynSum = json['hyn_sum'];
          hynSum = FormatUtil.weiToEtherStr(hynSum ?? '0');
        }
      }
    } catch (e) {
      LogUtil.toastException(e);
      return;
    }
    print("[$runtimeType] count:$count, hynSum:$hynSum");

    if (count <= 0 || hynSum == '0') {
      Fluttertoast.showToast(msg: '${S.of(context).rp_no_valid_contract}！');
      return;
    }

    UiUtil.showAlertView(
      context,
      title: S.of(context).rp_retrieve_all_staking,
      actions: [
        ClickOvalButton(
          S.of(context).cancel,
          () {
            Navigator.pop(context, false);
          },
          width: 115,
          height: 36,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          fontColor: DefaultColors.color999,
          btnColor: [Colors.transparent],
        ),
        SizedBox(
          width: 20,
        ),
        ClickOvalButton(
          S.of(context).confirm,
          _withdrawAction,
          width: 115,
          height: 36,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ],
      content: S.of(context).rp_retrieve_all_staking_confirm(count, hynSum),
    );
  }

  void _withdrawAction() async {
    Navigator.pop(context, true);

    var password = await UiUtil.showWalletPasswordDialogV2(context, _activeWallet.wallet);
    if (password == null) {
      return;
    }

    try {
      await _rpApi.postRetrieveHyn(activeWallet: _activeWallet, password: password);
      Fluttertoast.showToast(msg: S.of(context).rp_retrieve_staking_request_success);
      getNetworkData();
    } catch (e) {
      LogUtil.toastException(e);
    }
  }

  void _stakingAction() async {
    var valid = _formKey.currentState.validate();
    if (!valid) {
      return;
    }

    var inputText = _textEditController?.text ?? '';

    if (inputText.isEmpty) {
      return;
    }

    Navigator.pop(context, true);

    var password = await UiUtil.showWalletPasswordDialogV2(context, _activeWallet.wallet);
    if (password == null) {
      return;
    }

    var total = _hynPerRpValue * (int.tryParse(inputText) ?? 0);
    var amount = ConvertTokenUnit.strToBigInt(total.toString());
    try {
      await _rpApi.postStakingRp(amount: amount, activeWallet: _activeWallet, password: password);
      getNetworkData();
    } catch (e) {
      LogUtil.toastException(e);
    }
  }

  _pushRecordAction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RpTransmitRecordsPage(),
      ),
    );
  }

  _pushStakingInfoAction(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RpTransmitDetailPage(_rpStatistics, _dataList[index]),
      ),
    );
  }
}
