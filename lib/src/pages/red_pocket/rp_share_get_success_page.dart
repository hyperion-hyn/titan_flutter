import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_share_req_entity.dart';
import 'package:titan/src/pages/red_pocket/rp_share_send_success_page.dart';
import 'package:titan/src/pages/wallet/wallet_show_account_info_page.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'api/rp_api.dart';
import 'entity/rp_share_entity.dart';
import 'entity/rp_util.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart' as allPage;

class RpShareGetSuccessPage extends StatefulWidget {
  final String id;

  RpShareGetSuccessPage(this.id);

  @override
  State<StatefulWidget> createState() {
    return _RpShareGetSuccessPageState();
  }
}

class _RpShareGetSuccessPageState extends BaseState<RpShareGetSuccessPage> {
  final RPApi _rpApi = RPApi();
  RpShareEntity _shareEntity;
  RpShareOpenEntity myRpOpenEntity;
  TapGestureRecognizer _rpRecognizer;
  TapGestureRecognizer _hynRecognizer;
  LoadDataBloc _loadDataBloc = LoadDataBloc();

  @override
  void initState() {
    super.initState();

    _rpRecognizer = TapGestureRecognizer()..onTap = _rpHandlePress;
    _hynRecognizer = TapGestureRecognizer()..onTap = _hynHandlePress;
  }

  void _rpHandlePress() {
    if ((myRpOpenEntity?.rpHash ?? "") == "") {
      return;
    }
    WalletShowAccountInfoPage.jumpToAccountInfoPage(context,
        myRpOpenEntity?.rpHash ?? '', SupportedTokens.HYN_RP_HRC30.symbol);
  }

  void _hynHandlePress() {
    if ((myRpOpenEntity?.hynHash ?? "") == "") {
      return;
    }
    WalletShowAccountInfoPage.jumpToAccountInfoPage(context,
        myRpOpenEntity?.hynHash ?? '', SupportedTokens.HYN_Atlas.symbol);
  }

  @override
  void dispose() {
    _rpRecognizer.dispose();
    _hynRecognizer.dispose();
    _loadDataBloc.close();
    super.dispose();
  }

  @override
  void onCreated() async {
    super.onCreated();

    _getNewBeeInfo();
  }

  void _getNewBeeInfo() async {
    try {
      var activeWallet = WalletInheritedModel.of(context)?.activatedWallet;
      var _address = activeWallet.wallet.getAtlasAccount().address;
      _shareEntity = await _rpApi.getNewBeeDetail(
        _address,
        id: widget.id,
      );
      if (_shareEntity?.info?.alreadyGot ?? false) {
        _shareEntity.details.forEach((element) {
          if (element.address.toLowerCase() == _address.toLowerCase()) {
            myRpOpenEntity = element;
          }
        });
      }
      setState(() {});
      _loadDataBloc.add(RefreshSuccessEvent());
      print("[$runtimeType] shareEntity:${_shareEntity.info.toJson()}");
    } catch (error) {
      _loadDataBloc.add(LoadFailEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pageWidget(context),
    );
  }

  Widget _pageWidget(BuildContext context) {
    return Stack(children: [
      Image.asset(
        "res/drawable/rp_receiver_detail_top.png",
        width: double.infinity,
        fit: BoxFit.cover,
      ),
      LoadDataContainer(
        bloc: _loadDataBloc,
        onLoadData: () {
          _getNewBeeInfo();
        },
        onRefresh: () {
          _getNewBeeInfo();
        },
        onLoadingMore: () {
          _getNewBeeInfo();
        },
        child: CustomScrollView(
          slivers: <Widget>[_headWidget(), _listWidget()],
        ),
      ),
      InkWell(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Padding(
          padding:
              const EdgeInsets.only(top: 34, left: 16.0, right: 16, bottom: 16),
          child: Image.asset(
            "res/drawable/rp_receiver_success_arraw_back.png",
            width: 17,
            height: 17,
          ),
        ),
      ),
      if ((_shareEntity?.info?.rpType ?? RpShareType.location) ==
          RpShareType.normal)
        Positioned(
          top: 34,
          right: 16,
          child: InkWell(
            onTap: () {
              var info = _shareEntity.info;
              RpShareReqEntity reqEntity = RpShareReqEntity.onlyId(info.id);
              reqEntity.rpType = info.rpType;
              reqEntity.greeting = info.greeting;
              reqEntity.isNewBee = info.isNewBee;
              reqEntity.count = info.total;
              reqEntity.range = info.range;
              reqEntity.location = info.location;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RpShareSendSuccessPage(
                    reqEntity: reqEntity,
                    actionType: 1,
                  ),
                ),
              );
            },
            child: Image.asset(
              "res/drawable/node_share.png",
              width: 17,
              height: 17,
              color: Colors.white,
            ),
          ),
        ),
    ]);
  }

  _headWidget() {
    if (_shareEntity == null) {
      return SliverToBoxAdapter(
        child: Container(),
      );
    }

    return SliverToBoxAdapter(
      child: Column(
        children: [
          Column(
            children: [
              Container(
                height: 134,
                color: Colors.transparent,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      margin: const EdgeInsets.only(right: 12.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage(
                                "res/drawable/ic_rp_invite_friend_head_img_no_border.png"),
                            fit: BoxFit.cover,
                          )),
                    ),
                    Text(
                      "${_shareEntity?.info?.owner ?? ""}发的${(_shareEntity?.info?.rpType ?? "") == RpShareType.location ? "位置" : "新人"}红包",
                      style: TextStyle(
                          fontSize: 18,
                          color: HexColor("#333333"),
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Text(
                _shareEntity?.info?.greeting ?? "",
                style: TextStyles.textC999S14,
              ),
              if ((_shareEntity?.info?.rpType ?? "") == RpShareType.location)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 6.0,
                    left: 32,
                    right: 32,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "res/drawable/check_in_location.png",
                        width: 10,
                        height: 14,
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      Flexible(
                        child: Text(
                          "${_shareEntity?.info?.location ?? ""}; ${_shareEntity?.info?.range ?? ""}千米内可领取",
                          style: TextStyles.textC999S12,
                        ),
                      )
                    ],
                  ),
                ),
              SizedBox(
                height: 26,
              ),
              if (_shareEntity?.info?.alreadyGot ??
                  false && myRpOpenEntity != null)
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: RichText(
                              textAlign: TextAlign.end,
                              text: TextSpan(
                                  text: getCoinAmount(myRpOpenEntity.rpAmount),
                                  style: TextStyle(
                                      fontSize: 28,
                                      color: HexColor("#D09100"),
                                      fontWeight: FontWeight.bold),
                                  recognizer: _rpRecognizer,
                                  children: [
                                    TextSpan(
                                      text: " RP",
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: HexColor("#D09100"),
                                          fontWeight: FontWeight.bold),
                                      recognizer: _rpRecognizer,
                                    ),
                                  ])),
                        ),
                        Text("  +  ",
                            style: TextStyle(
                                fontSize: 30,
                                color: HexColor("#333333"),
                                fontWeight: FontWeight.bold)),
                        Expanded(
                          child: RichText(
                              text: TextSpan(
                                  text: getCoinAmount(myRpOpenEntity.hynAmount),
                                  style: TextStyle(
                                      fontSize: 28,
                                      color: HexColor("#D09100"),
                                      fontWeight: FontWeight.bold),
                                  recognizer: _rpRecognizer,
                                  children: [
                                TextSpan(
                                  text: " HYN",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: HexColor("#D09100"),
                                      fontWeight: FontWeight.bold),
                                  recognizer: _rpRecognizer,
                                ),
                              ])),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 2.0,
                      ),
                      child: Text("已领取红包，请稍后查看钱包记录",
                          style: TextStyles.textC333S12),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 50.0),
                      height: 10,
                      color: HexColor("#F2F2F2"),
                    ),
                  ],
                ),
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 16.0, right: 16),
                child: Row(
                  children: [
                    Text(
                      "总共${_shareEntity?.info?.gotCount ?? ""}个红包；共 ${_shareEntity?.info?.rpAmount ?? ""} RP， ${_shareEntity?.info?.hynAmount ?? ""} HYN",
                      style: TextStyles.textC999S12,
                    ),
                    Spacer(),
                    Text(
                      "${FormatUtil.formatDate(_shareEntity?.info?.createdAt ?? "", isSecond: true)}",
                      style: TextStyles.textC999S12,
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _listWidget() {
    if (_shareEntity == null) {
      return SliverToBoxAdapter(
        child: Container(),
      );
    }
    return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
      var item = _shareEntity.details[index];
      return InkWell(
        onTap: () {
          AtlasApi.goToHynScanPage(context, item.address);
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 21, left: 16, right: 16, bottom: 17),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 10,
                    ),
                    child: iconWidget("", item.username, item.address,
                        isCircle: true),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: [
                            Text(
                              item.username,
                              style: TextStyle(
                                color: HexColor("#333333"),
                                fontSize: 16,
                              ),
                            ),
                            Spacer(),
                            GestureDetector(
                              onTap: () {
                                WalletShowAccountInfoPage.jumpToAccountInfoPage(
                                    context,
                                    item?.rpHash ?? '',
                                    SupportedTokens.HYN_RP_HRC30.symbol);
                              },
                              child: Text(
                                "${getCoinAmount(item.rpAmount)} RP",
                                style: TextStyle(
                                  color: HexColor("#333333"),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 3,
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                WalletShowAccountInfoPage.jumpToAccountInfoPage(
                                    context,
                                    item?.hynHash ?? '',
                                    SupportedTokens.HYN_Atlas.symbol);
                              },
                              child: Text(
                                " ,${getCoinAmount(item.hynAmount)} HYN",
                                style: TextStyle(
                                  color: HexColor("#333333"),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 3,
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              shortBlockChainAddress(
                                  WalletUtil.ethAddressToBech32Address(
                                      item.address)),
                              style: TextStyle(
                                fontSize: 14,
                                color: HexColor('#999999'),
                              ),
                            ),
                            Spacer(),
                            if (item.isBest)
                              Text(
                                "最佳",
                                style: TextStyle(
                                    fontSize: 12, color: HexColor('#E8AC13')),
                                textAlign: TextAlign.right,
                              ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 0.5,
              color: HexColor("#F2F2F2"),
              indent: 16,
              endIndent: 16,
            )
          ],
        ),
      );
    }, childCount: _shareEntity?.details?.length ?? 0));
  }

  String getCoinAmount(String coinAmount){
    if(coinAmount == null || coinAmount.isEmpty){
      return "";
    }
    return FormatUtil.truncateDecimalNum(Decimal.parse(coinAmount), 6);
  }
}
