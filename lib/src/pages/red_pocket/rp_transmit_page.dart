import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/red_pocket/api/rp_api.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_staking_info.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_statistics.dart';
import 'package:titan/src/pages/red_pocket/rp_release_records_page.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class RpTransmitPage extends StatefulWidget {
  final RPStatistics rpStatistics;

  RpTransmitPage(this.rpStatistics);

  @override
  State<StatefulWidget> createState() {
    return _RpTransmitPageState();
  }
}

class _RpTransmitPageState extends State<RpTransmitPage> {
  final RPApi _rpApi = RPApi();
  final _formKey = GlobalKey<FormState>();
  final LoadDataBloc _loadDataBloc = LoadDataBloc();
  final TextEditingController _textEditController = TextEditingController();

  String get _address => _activeWallet?.wallet?.getEthAccount()?.address ?? "";

  WalletVo _activeWallet;
  RPStatistics _rpStatistics;
  int _currentPage = 1;
  List<RpStakingInfo> _dataList = [];

  @override
  void initState() {
    super.initState();

    _rpStatistics = widget.rpStatistics;

    _activeWallet = WalletInheritedModel.of(Keys.rootKey.currentContext)?.activatedWallet;

    _loadDataBloc.add(LoadingEvent());
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
        baseTitle: '传导池',
        backgroundColor: Colors.grey[50],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            _poolInfo(),
            _myRPInfo(),
            _myContractHeader(),
            _myContract(),
          ],
        ),
      ),
    );
  }

  Widget _columnWidget(String amount, String title) {
    return Column(
      children: <Widget>[
        Text(
          '$amount',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black,
            fontWeight: FontWeight.w500,
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
    String totalTransmit = FormatUtil.stringFormatCoinNum(_rpStatistics?.global?.totalTransmitStr) ?? '--';

    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        bottom: 6,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16,
              ),
              child: _columnWidget('12万 RP', '总可传导'),
              // child: _columnWidget('$totalTransmit RP', '总可传导'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _lineWidget(),
          ),
          Expanded(
            child: _columnWidget('$totalStakingHyn HYN', '全网抵押'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _lineWidget(),
          ),
          Expanded(
            child: _columnWidget('$transmit RP', '全网累计传导'),
          ),
          Spacer(),
        ],
      ),
    );
  }

  _myRPInfo() {
    String totalAmount = FormatUtil.stringFormatCoinNum(_rpStatistics?.self?.totalAmountStr) ?? '--';
    String totalStakingHyn = FormatUtil.stringFormatCoinNum(_rpStatistics?.self?.totalStakingHynStr) ?? '--';
    String totalRp = FormatUtil.stringFormatCoinNum(_rpStatistics?.self?.totalRpStr) ?? '--';
    String yesterday = FormatUtil.stringFormatCoinNum(_rpStatistics?.self?.yesterdayStr) ?? '--';

    String hynPerRp = FormatUtil.stringFormatCoinNum(_rpStatistics?.rpContractInfo?.hynPerRpStr) ?? '--';
    String ratio = FormatUtil.stringFormatCoinNum(_rpStatistics?.rpContractInfo?.ratioStr) ?? '--';

    var releaseDay = (_rpStatistics?.rpContractInfo?.releaseDay ?? '0');
    var stakingDay = (_rpStatistics?.rpContractInfo?.stakingDay ?? '0');

    return Padding(
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
                bottom: 26,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 12,
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 4,
                          ),
                          child: Text(
                            '已抵押',
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
                              '$totalAmount份',
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
                  _columnWidget('$totalRp RP', '我累计获得'),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 8,
                      right: 10,
                      left: 10,
                    ),
                    child: _lineWidget(),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RpReleaseRecordsPage(),
                        ),
                      );
                    },
                    child: _columnWidget('$yesterday RP', '我昨日获得'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 15,
                      color: DefaultColors.color999,
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 16,
                left: 30,
                right: 30,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: RichText(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: '当前每份（$hynPerRp HYN）总共可传导出 ',
                        style: TextStyle(
                          fontSize: 10,
                          color: HexColor("#999999"),
                          fontWeight: FontWeight.normal,
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(
                            text: '$ratio',
                            style: TextStyle(
                              fontSize: 10,
                              color: HexColor("#333333"),
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                          ),
                          TextSpan(
                            text: ' RP，分$releaseDay天释放。$stakingDay天后可取回已抵押的HYN。',
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
                    '一键取回',
                    _showCollectAlertView,
                    width: 120,
                    height: 32,
                    fontSize: 12,
                    btnColor: HexColor('#00B97C'),
                  ),
                  SizedBox(
                    width: 14,
                  ),
                  Stack(
                    children: <Widget>[
                      Container(
                        child: ClickOvalButton(
                          '抵押HYN',
                          _showExchangeAlertView,
                          width: 120,
                          height: 32,
                          fontSize: 12,
                          btnColor: HexColor('#107EDC'),
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
    );
  }

  _myContractHeader() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 32,
        left: 18,
        bottom: 18,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            '我的抵押',
            style: TextStyle(
              color: HexColor("#333333"),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  _myContract() {
    var isEmpty = _dataList?.isEmpty ?? true;
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: isEmpty ? Colors.white : null,
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
        ),
        margin: isEmpty ? const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16) : null,
        //color: Colors.white,
        child: LoadDataContainer(
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
          child: ListView.builder(
            itemBuilder: (context, index) {
              HexColor stateColor = HexColor('#999999');
              String stateDesc = '运行中';
              var model = _dataList[index];

              //1:确认中 2:失败 3:成功 4:释放中 5:释放结束 6:可取回 7:取回中 8: 已提取
              var status = model?.status;
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
              var amountBig = (hynAmountBig/hynPerRpBig);
              var amount = amountBig.toInt();
              if (amount.isNaN) {
                amount = 1;
              }

              var stakingAt = FormatUtil.newFormatUTCDateStr(model?.stakingAt ?? '0', isSecond: true);
              var expectReleaseTime = FormatUtil.newFormatUTCDateStr(model?.expectReleaseTime ?? '0', isSecond: true);

              return Padding(
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
                                      '$amount 份',
                                      style: TextStyle(
                                        color: HexColor("#333333"),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '共 $hynAmount HYN',
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
                                '抵押ID：${model?.id ?? 0}',
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
                      if (status >= 3 && status <= 7)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 6,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                '${expectReleaseTime ?? '--'}可提回',
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
              );
            },
            itemCount: _dataList?.length ?? 0,
          ),
        ),
      ),
    );
  }

  void getNetworkData() async {
    try {
      var netData = await _rpApi.getRPStakingInfoList(_address, page: _currentPage);

      // _rpStatistics = await _rpApi.getRPStatistics(_address);

      if (netData?.isNotEmpty ?? false) {
        _dataList = netData;
        if (mounted) {
          setState(() {
            _loadDataBloc.add(RefreshSuccessEvent());
          });
        }
      } else {
        _loadDataBloc.add(LoadEmptyEvent());
      }
    } catch (e) {
      _loadDataBloc.add(LoadFailEvent());
    }
  }

  void getMoreNetworkData() async {
    try {
      _currentPage = _currentPage + 1;
      var netData = await _rpApi.getRPStakingInfoList(_address, page: _currentPage);

      if (netData?.isNotEmpty ?? false) {
        _dataList = netData;
        _loadDataBloc.add(LoadingMoreSuccessEvent());
      } else {
        _loadDataBloc.add(LoadMoreEmptyEvent());
      }
    } catch (e) {
      _loadDataBloc.add(LoadMoreFailEvent());
    }
  }

  _showExchangeAlertView() {
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
      title: '抵押份数',
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
      detail: '注：你的HYN抵押将锁定${_rpStatistics?.rpContractInfo?.stakingDay ?? 0}天，满期后可自行取回',
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
            child: TextFormField(
              autofocus: true,
              controller: _textEditController,
              keyboardType: TextInputType.numberWithOptions(decimal: false),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return '请输入抵押份数';
                }

                var hynToken = WalletInheritedModel.of(context).getCoinVoBySymbol(
                  SupportedTokens.HYN_Atlas.symbol,
                );
                var hynTokenBalance = Decimal.parse(hynToken.balance.toString());
                var amount = int.tryParse(value) ?? 0;
                var total = 500 * amount;
                var amountBig = ConvertTokenUnit.strToBigInt(total.toString());
                var inputValue = Decimal.parse(amountBig.toString());
                var isOver = inputValue > hynTokenBalance;
                print(
                    "[$runtimeType] isOver:$isOver, hynTokenBalance:$hynTokenBalance, inputValue:$inputValue, amount:$amount");
                if (isOver) {
                  return '钱包的HYN余额不足购买当前份数';
                }

                return null;
              },
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: HexColor('#FFF2F2F2'),
                hintText: '输入抵押份数，每份500HYN',
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
                print("[$runtimeType] textField, inputValue:$value");
              },
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

      if (response.data != null) {
        var json = response.data as Map<String, dynamic>;

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
      Fluttertoast.showToast(msg: '当前没有到期的抵押合约！');
      return;
    }

    UiUtil.showAlertView(
      context,
      title: '取回所有满期抵押',
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
          btnColor: Colors.transparent,
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
      content: '当前满期HYN有$count 笔，总共 $hynSum HYN，你将发起提回抵押操作，确定继续吗？',
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
      Fluttertoast.showToast(msg: '取回请求已发送成功，请稍后查看钱包HYN余额！');
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

    var total = 500 * (int.tryParse(inputText) ?? 0);
    var amount = ConvertTokenUnit.strToBigInt(total.toString());
    try {
      await _rpApi.postStakingRp(amount: amount, activeWallet: _activeWallet, password: password);
      _loadDataBloc.add(LoadingEvent());

    } catch (e) {
      LogUtil.toastException(e);
    }
  }
}
