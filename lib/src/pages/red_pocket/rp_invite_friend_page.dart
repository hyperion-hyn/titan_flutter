import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/wallet/api/hyn_api.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/widget_shot.dart';

class RpInviteFriendPage extends StatefulWidget {
  RpInviteFriendPage();

  @override
  State<StatefulWidget> createState() {
    return _RpInviteFriendPageState();
  }
}

class _RpInviteFriendPageState extends BaseState<RpInviteFriendPage> {
  WalletVo activityWallet;

  @override
  void initState() {
    super.initState();
  }

  @override
  void onCreated() {
    activityWallet = WalletInheritedModel.of(context).activatedWallet;
    super.onCreated();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: BaseAppBar(baseTitle: "邀请好友"),
        body: Column(
          children: <Widget>[
            Expanded(
              child: WidgetShot(
                child: Column(
                  children: <Widget>[
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        Image.asset(
                          "res/drawable/bg_rp_invite_friend_top.png",
                          height: 579,
                        ),
                        Container(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(
                                "res/drawable/ic_rp_invite_friend_head_img.png",
                                width: 60,
                                height: 60,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 2, bottom: 17.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      "${activityWallet.wallet.keystore.name}",
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: DefaultColors.color333,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 16,
                                    ),
                                    Text(
                                        "${shortBlockChainAddress(WalletUtil.ethAddressToBech32Address(activityWallet.wallet.getAtlasAccount().address))}",
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: DefaultColors.color333,
                                        )),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 230,
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                      text: "邀请你一起来海伯利安领",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        color: DefaultColors.color333,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "红包",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                            color: HexColor("#FF3B3B"),
                                          ),
                                        ),
                                        TextSpan(
                                          text: "啦!",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                            color: DefaultColors.color333,
                                          ),
                                        ),
                                      ]),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 14, bottom: 21.0),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    Image.asset(
                                      "res/drawable/ic_rp_invite_friend_red_package.png",
                                      width: 208,
                                      height: 267,
                                    ),
                                    Positioned(
                                      bottom: 42,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(5))),
                                        width: 84,
                                        height: 84,
                                        child: QrImage(
                                          data: "阿斯顿发射点发生范德萨打发十分大师傅大势地方啊手动阀手动阀撒旦啊手动阀手动阀手动阀",
                                          size: 131,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              ClickOvalButton(
                                "分享",
                                () {

                                },
                                btnColor: [HexColor("#FF4D4D"), HexColor("#FF0527")],
                                fontSize: 16,
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            Container(
              height: 60,
              color: Colors.green,
            )
          ],
        ));
  }
}