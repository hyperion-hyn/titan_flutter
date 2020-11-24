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
import 'package:titan/src/pages/red_pocket/entity/rp_info.dart';
import 'package:titan/src/pages/red_pocket/red_pocket_exchange_records_page.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class RedPocketExchangePage extends StatefulWidget {
  RedPocketExchangePage();

  @override
  State<StatefulWidget> createState() {
    return _RedPocketExchangePageState();
  }
}

class _RedPocketExchangePageState extends State<RedPocketExchangePage> {
  AtlasApi _atlasApi = AtlasApi();
  LoadDataBloc _loadDataBloc = LoadDataBloc();
  RPInfo _rpInfo;
  WalletVo _activeWallet;
  var _textEditController = TextEditingController();

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
        baseTitle: '传导池',
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
              _myContractHeader(),
              _myContract(),
              _myContractFooter(),
            ],
          )),
    );
  }

  _cardPadding() {
    return const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0);
  }

  _myRPInfo() {
    var level = _rpInfo?.level ?? '--';
    var rpBalance = _rpInfo?.rpBalance ?? '--';
    var rpToday = _rpInfo?.rpToday ?? '--';
    var rpYesterday = _rpInfo?.rpYesterday ?? '--';
    var rpMissed = _rpInfo?.rpMissed ?? '--';

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

    return SliverToBoxAdapter(
      child: Padding(
        padding: _cardPadding(),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 28,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 2,
                      ),
                      child: Text(
                        '已抵押',
                        style: TextStyle(
                          fontSize: 12,
                          color: DefaultColors.color999,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 2,
                      ),
                      child: Text(
                        '10份',
                        style: TextStyle(
                          color: DefaultColors.color333,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '（500000 HYN）',
                      style: TextStyle(
                        fontSize: 12,
                        color: DefaultColors.color999,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 28,
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      child: _columnWidget('2031 HYN', '全网抵押'),
                    ),
                    _lineWidget(),
                    Expanded(
                      child: _columnWidget('20 RP', '全网累计传导'),
                    ),
                    _lineWidget(),
                    Expanded(
                      child: _columnWidget('20 RP', '我累计获得'),
                    ),
                    _lineWidget(),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RedPocketExchangeRecordsPage(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        child: Row(
                          children: [
                            _columnWidget('100 RP', '我昨日获得'),
                            SizedBox(
                              width: 8,
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 15,
                              color: DefaultColors.color999,
                            )
                          ],
                        ),
                      ),
                    ),
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
                          text: '当前每份（500 HYN）总共可传导出 ',
                          style: TextStyle(
                            fontSize: 10,
                            color: HexColor("#999999"),
                            fontWeight: FontWeight.normal,
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(
                              text: '0.95',
                              style: TextStyle(
                                fontSize: 10,
                                color: HexColor("#999999"),
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                            TextSpan(
                              text: ' RP，分15天释放。90天后可取回已抵押的HYN。',
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
              )
            ],
          ),
        ),
      ),
    );
  }

  _myContractHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 32,
          left: 18,
        ),
        child: Text(
          '我的合约',
          style: TextStyle(
            color: HexColor("#333333"),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  _myContractFooter() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 30,
      ),
    );
  }

  _myContract() {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
      (context, index) {
        HexColor stateColor = HexColor('#999999');
        String stateDesc = '运行中';
        switch (index) {
          case 0:
            stateColor = HexColor('#FFC500');
            stateDesc = '抵押确认中...';
            break;

          case 1:
            stateColor = HexColor('#333333');
            stateDesc = '运行中';
            break;

          case 2:
            stateColor = HexColor('#00C081');
            stateDesc = '可取回';
            break;

          case 3:
            stateColor = HexColor('#999999');
            stateDesc = '已提取';
            break;
        }
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
            child: Row(
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
                            '2 份',
                            style: TextStyle(
                              color: HexColor("#333333"),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          '共 1000 HYN',
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
                      '抵押ID：3',
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
                      '2020/12/12 21:21:21',
                      //DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(createAt)),
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
          ),
        );
      },
      childCount: 4,
    ));
  }

  _requestData() async {
    try {
      _rpInfo = await _atlasApi.postRpInfo(
        _activeWallet?.wallet?.getAtlasAccount()?.address,
      );
      _loadDataBloc.add(RefreshSuccessEvent());
    } catch (e) {
      _loadDataBloc.add(RefreshFailEvent());
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
      title: '抵押数量',
      actions: [
        ClickOvalButton(
          S.of(context).confirm,
          () async {
            Navigator.pop(context, true);
          },
          width: 200,
          height: 38,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ],
      detail: '注：你的HYN抵押将锁定90天，满期后可自行取回',
      contentItem: Material(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.only(
            left: 22,
            right: 22,
            bottom: 16,
          ),
          child: TextFormField(
            //validator: validatePubAddress,
            autofocus: true,
            controller: _textEditController,
            decoration: InputDecoration(
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
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: TextStyle(fontSize: 13),
            onSaved: (value) {
              print("[object]  --> value:$value");
            },
          ),
        ),
      ),
    );
  }

  _showCollectAlertView() {
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
          () {
            Navigator.pop(context, true);
          },
          width: 115,
          height: 36,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ],
      content: '当前满期HYN有2笔，总共 2000 HYN，你将发起提回抵押操作，确定继续吗？',
    );
  }
}
