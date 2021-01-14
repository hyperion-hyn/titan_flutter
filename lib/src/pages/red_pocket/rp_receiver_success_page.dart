import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utils.dart';
import 'entity/rp_share_entity.dart';
import 'entity/rp_util.dart';

class RpReceiverSuccessPage extends StatefulWidget {
  final RpShareEntity _shareEntity;

  RpReceiverSuccessPage(this._shareEntity);

  @override
  State<StatefulWidget> createState() {
    return _RpReceiverSuccessPageState();
  }
}

class _RpReceiverSuccessPageState extends State<RpReceiverSuccessPage> {
  @override
  void initState() {
    super.initState();
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
        _headWidget(),
        _listWidget(),
      ],
    );
  }

  _headWidget() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Stack(
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
                      "${widget._shareEntity.info.owner}发的${widget._shareEntity.info.rpType == RpShareType.location ? "位置" : "新人"}红包",
                      style: TextStyle(
                          fontSize: 18,
                          color: HexColor("#333333"),
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Text(
                "恭喜发财，大吉大利",
                style: TextStyles.textC999S14,
              ),
              if (widget._shareEntity.info.rpType == RpShareType.location)
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
                      Text("广州。。。。; ${widget._shareEntity.info.range}千米内可领取",style: TextStyles.textC999S12,)
                    ],
                  ),
                ),
              SizedBox(
                height: 26,
              ),
              if(widget._shareEntity.info.alreadyGot)
                Column(
                  children: [
                    RichText(
                      text: TextSpan(
                          text: "0.3",
                          style: TextStyle(
                              fontSize: 46,
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
                              text: "0.2",
                              style: TextStyle(
                                  fontSize: 46,
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
                      child: Text("红包转入中，请稍后查看钱包记录", style: TextStyles.textC333S12),
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
                    Text("总共个红包；共RP，HYN",style: TextStyles.textC999S12,),
                    Spacer(),
                    Text("${FormatUtil.formatDate(widget._shareEntity.info.createdAt)}",style: TextStyles.textC999S12,)
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
      var item = widget._shareEntity.details[index];
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
    }, childCount: widget._shareEntity?.details?.length ?? 0));
  }
}
