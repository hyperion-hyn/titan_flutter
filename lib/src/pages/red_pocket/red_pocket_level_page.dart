import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
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
import 'package:titan/src/pages/red_pocket/entity/rp_staking_info.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_statistics.dart';
import 'package:titan/src/pages/red_pocket/rp_level_upgrade_page.dart';
import 'package:titan/src/pages/red_pocket/rp_transmit_records_page.dart';
import 'package:titan/src/pages/red_pocket/rp_staking_detail_page.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class RedPocketLevelPage extends StatefulWidget {
  final RPStatistics rpStatistics;

  RedPocketLevelPage(this.rpStatistics);

  @override
  State<StatefulWidget> createState() {
    return _RedPocketLevelPageState();
  }
}

class _RedPocketLevelPageState extends BaseState<RedPocketLevelPage> with RouteAware {
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
    _inputController.close();
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
            _notificationWidget(),
            _myRPInfo(),
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

  _myRPInfo() {
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
                Padding(
                  padding: const EdgeInsets.only(
                    top: 30,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[HexColor(('#E6ECFF')), HexColor(('#62A3FF'))],
                          ),
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[HexColor(('#FFC8C8')), HexColor(('#FF1616'))],
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            '3',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                      Icon(
                        Icons.info,
                        color: HexColor('#FF5041'),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 8,
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
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                        ),
                        child: _columnWidget(
                          '30RP',
                          '当前燃烧',
                        ),
                        // child: _columnWidget('$totalTransmit RP', '总可传导'),
                      ),
                      Spacer(),
                      _columnWidget(
                        '200 RP',
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
                              '升级量级',
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
                        _showCollectAlertView,
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

    bool isUp = index % 2 == 0;

    return InkWell(
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
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 10,
                          ),
                          child: Image.asset(
                            "res/drawable/red_pocket_level_${isUp ? 'up' : 'down'}.png",
                            width: 22,
                            height: 22,
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
                                    '$amount 级',
                                    style: TextStyle(
                                      color: HexColor("#333333"),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              '0 级-2 级',
                              style: TextStyle(
                                fontSize: 12,
                                color: HexColor('#999999'),
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
                              '燃烧 60RP，抵押63RP',
                              style: TextStyle(
                                color: HexColor("#333333"),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
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
          if (index == 0) Positioned(
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
      var netData = await _rpApi.getRPStakingInfoList(_address, page: _currentPage);

      _rpStatistics = await _rpApi.getRPStatistics(_address);

      if (mounted) {
        setState(() {
          _loadDataBloc.add(RefreshSuccessEvent());
        });
      }

      if (netData?.isNotEmpty ?? false) {
        _dataList = netData;
      }
      // } else {
      //   _loadDataBloc.add(LoadEmptyEvent());
      // }
    } catch (e) {
      _loadDataBloc.add(LoadFailEvent());
    }
  }

  void getMoreNetworkData() async {
    try {
      _currentPage = _currentPage + 1;
      var netData = await _rpApi.getRPStakingInfoList(_address, page: _currentPage);

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

  _navToLevelUpgradeAction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RpLevelUpgradePage(),
      ),
    );
    return;
    
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
          _retrieveAction,
          width: 115,
          height: 36,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ],
      content: S.of(context).rp_retrieve_all_staking_confirm(count, hynSum),
    );
  }

  void _retrieveAction() async {
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

}

