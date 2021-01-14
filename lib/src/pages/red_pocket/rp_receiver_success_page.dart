import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
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

class RpReceiverSuccessPage extends StatefulWidget {
  final String id;

  RpReceiverSuccessPage(this.id);

  @override
  State<StatefulWidget> createState() {
    return _RpReceiverSuccessPageState();
  }
}

class _RpReceiverSuccessPageState extends BaseState<RpReceiverSuccessPage> {

  final RPApi _rpApi = RPApi();
  allPage.AllPageState _currentState = allPage.LoadingState();
  RpShareEntity _shareEntity;

  @override
  void initState() {
    super.initState();
  }

  @override
  void onCreated() async {
    super.onCreated();

    _getNewBeeInfo();
  }

  void _getNewBeeInfo() async {
    try {
      var activeWallet = WalletInheritedModel.of(context)?.activatedWallet;
      var _address  = activeWallet.wallet.getAtlasAccount().address;
      _shareEntity = await _rpApi.getNewBeeDetail(
        _address,
        id: widget.id,
      );
      setState(() {
        _currentState = null;
      });
      print("[$runtimeType] shareEntity:${_shareEntity.info.toJson()}");
    } catch (error) {
      setState(() {
        _currentState = allPage.LoadCustomState();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: _pageWidget(context));
  }

  Widget _pageWidget(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        _headBarWidget(),
        if(_currentState != null || _shareEntity == null)
          ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top:200.0),
                child: AllPageStateContainer(_currentState, () {
                  setState(() {
                    _currentState = LoadingState();
                  });
                  _getNewBeeInfo();
            }),
              ),
          ),
        ]
        else
          ...[
          _headWidget(),
          _listWidget(),
        ]
      ],
    );
  }

  _headBarWidget(){
    return SliverToBoxAdapter(
      child: Stack(
        children: [
          Image.asset(
            "res/drawable/rp_receiver_detail_top.png",
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 34, left: 16.0, right: 16, bottom: 16),
              child: Image.asset(
                "res/drawable/rp_receiver_success_arraw_back.png",
                width: 17,
                height: 17,
              ),
            ),
          )
        ],
      ),
    );
  }

  _headWidget() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 28.0, bottom: 6),
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
                  padding: const EdgeInsets.only(top: 6.0),
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
                      Text("${_shareEntity?.info?.location ?? ""}; ${_shareEntity?.info?.range ?? ""}千米内可领取",style: TextStyles.textC999S12,)
                    ],
                  ),
                ),
              SizedBox(
                height: 26,
              ),
              if(_shareEntity?.info?.alreadyGot ?? false)
                Column(
                  children: [
                    RichText(
                      text: TextSpan(
                          text: _shareEntity.info.rpAmount,
                          style: TextStyle(
                              fontSize: 32,
                              color: HexColor("#D09100"),
                              fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: " RP",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: HexColor("#D09100"),
                                  fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: "  +  ",
                              style: TextStyle(
                                  fontSize: 30,
                                  color: HexColor("#333333"),
                                  fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: _shareEntity.info.hynAmount,
                              style: TextStyle(
                                  fontSize: 32,
                                  color: HexColor("#D09100"),
                                  fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: " HYN",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: HexColor("#D09100"),
                                  fontWeight: FontWeight.bold),
                            ),
                          ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 2.0,
                      ),
                      child: Text("已领取红包，请稍后查看钱包记录", style: TextStyles.textC333S12),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 50.0),
                      height: 10,
                      color: HexColor("#F2F2F2"),
                    ),
                  ],
                ),
              Padding(
                padding: const EdgeInsets.only(top:16,left:16.0,right: 16),
                child: Row(
                  children: [
                    Text("总共${_shareEntity?.info?.gotCount ?? ""}个红包；共 ${_shareEntity?.info?.rpAmount ?? ""} RP， ${_shareEntity?.info?.hynAmount ?? ""} HYN",style: TextStyles.textC999S12,),
                    Spacer(),
                    Text("${FormatUtil.formatDate(_shareEntity?.info?.createdAt ?? "",isSecond: true)}",style: TextStyles.textC999S12,)
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
              padding: const EdgeInsets.only(top: 21, left: 16, right: 16, bottom: 17),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 10,
                    ),
                    child: iconWidget("", item.username, item.address, isCircle: true),
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
                            Text(
                              "${item.rpAmount} RP, ${item.hynAmount} HYN",
                              style: TextStyle(
                                color: HexColor("#333333"),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 3,
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        Row(children: [
                          Text(
                            shortBlockChainAddress(WalletUtil.ethAddressToBech32Address(item.address)),
                            style: TextStyle(
                              fontSize: 14,
                              color: HexColor('#999999'),
                            ),
                          ),
                          Spacer(),
                          if(item.isBest)
                            Text(
                              "最佳",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: HexColor('#E8AC13')
                              ),
                              textAlign: TextAlign.right,
                            ),
                        ],)
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 0.5,color: HexColor("#F2F2F2"),indent: 16,endIndent: 16,)
          ],
        ),
      );
    }, childCount: _shareEntity?.details?.length ?? 0));
  }
}
