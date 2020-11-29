import 'dart:typed_data';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/data/cache/memory_cache.dart';
import 'package:titan/src/pages/app_tabbar/bloc/bloc.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/pages/red_pocket/red_pocket_page.dart';
import 'package:titan/src/pages/wallet/api/hyn_api.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/wallet_widget.dart';
import 'package:titan/src/widget/widget_shot.dart';

import 'api/rp_api.dart';

class RpInviteFriendPage extends StatefulWidget {
  static String shareDomain = "https://share.hyn.spage/redpocket_share.html";
  RpInviteFriendPage();

  @override
  State<StatefulWidget> createState() {
    return _RpInviteFriendPageState();
  }
}

class _RpInviteFriendPageState extends BaseState<RpInviteFriendPage> {
  WalletVo activityWallet;
  final ShotController _shotController = new ShotController();

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
    String ethWalletAddress = activityWallet.wallet.getAtlasAccount().address;
    String walletAddress = WalletUtil.ethAddressToBech32Address(ethWalletAddress);
    String walletName = activityWallet.wallet.keystore.name;

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: BaseAppBar(baseTitle: "邀请好友"),
        body: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  WidgetShot(
                    controller: _shotController,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        Image.asset(
                          "res/drawable/bg_rp_invite_friend_top.png",
                          fit:BoxFit.cover,
                          width: double.infinity,
                        ),
                        Container(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(height: 66,),
                              Container(
                                width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors:[HexColor("#ffd985"),HexColor("#ffa73f"),]),
                                      shape: BoxShape.circle,
                                      border: Border.all(width: 2,color: Colors.transparent)
                                  ),
                                  child: walletHeaderWidget(walletName,address: ethWalletAddress,isShowShape: false)),
//                              iconWidget("",walletName,walletAddress,isCircle: true,iconWidth: 60),
                              /*Image.asset(
                                "res/drawable/ic_rp_invite_friend_head_img.png",
                                width: 60,
                                height: 60,
                              ),*/
                              Padding(
                                padding: const EdgeInsets.only(top: 2, bottom: 17.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      "$walletName",
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: DefaultColors.color333,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 16,
                                    ),
                                    Text("${shortBlockChainAddress(walletAddress)}",
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
                                          data: "${RpInviteFriendPage.shareDomain}?from=$walletAddress&name=$walletName",
                                          size: 131,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ClickOvalButton(
                    "分享",
                        () async {
                      await _shareQr(context);
                    },
                    btnColor: [HexColor("#FF4D4D"), HexColor("#FF0527")],
                    fontSize: 16,
                  )
                ],
              ),
            ),
            Container(
              height: 60,
              color: Colors.green,
            )
          ],
        ));
  }

  Future _shareQr(BuildContext context) async {
    Uint8List imageByte = await _shotController.makeImageUint8List();
    await Share.file(S.of(context).nav_share_app, 'app.png', imageByte, 'image/png');
  }
}

void showInviteDialog(BuildContext context, String inviterAddress, String walletName) {
  UiUtil.showAlertViewNew(context,
      barrierDismissible: false,
      contentWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text("一起领红包邀请",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: HexColor("#333333"),
                    decoration: TextDecoration.none)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 11.0),
            child: Image.asset(
              "res/drawable/ic_rp_invite_friend_start_show.png",
              width: 62,
              height: 61,
            ),
          ),
          SizedBox(
            width: 240,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(text: walletName, style: TextStyles.textC333S14bold, children: [
                TextSpan(
                  text: " ${shortBlockChainAddress(inviterAddress)} ",
                  style: TextStyles.textC999S12,
                ),
                TextSpan(
                  text: "邀请你成为他的直友并一起领红包，是否同意?",
                  style: TextStyles.textC333S14,
                ),
              ]),
            ),
          )
        ],
      ),
      actions: [
        ClickOvalButton(
          "同意",
          () async {
            Navigator.pop(context);

            RPApi _rpApi = RPApi();
            var walletVo = WalletInheritedModel.of(context).activatedWallet;
            if (walletVo == null) {
              UiUtil.showAlertView(context, title: "一起领红包邀请", content: "现在新建一个钱包身份，创建后将自动成为$walletName的直友，现在就创建吗?", actions: [
                ClickOvalButton(
                  S.of(context).cancel,
                  () {
                    MemoryCache.rpInviteKey = inviterAddress;

                    Navigator.pop(context);
                  },
                  width: 120,
                  height: 32,
                  fontSize: 14,
                  fontColor: DefaultColors.color999,
                  btnColor: [Colors.transparent],
                ),
                SizedBox(
                  width: 8,
                ),
                ClickOvalButton(
                  S.of(context).confirm,
                  () async {
                    MemoryCache.rpInviteKey = inviterAddress;

                    Navigator.pop(context);
                    BlocProvider.of<AppTabBarBloc>(context).add(ChangeTabBarItemEvent(index: 1));
                  },
                  width: 120,
                  height: 38,
                  fontSize: 16,
                ),
              ]);
              return;
            }

            try {
              bool inviteResult = await _rpApi.postRpInviter(inviterAddress, walletVo.wallet);
              if(inviteResult) {
                Fluttertoast.showToast(msg: "邀请成功");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RedPocketPage()),
                );
              }
            }catch(error){
              LogUtil.toastException(error);
            }
          },
          btnColor: [HexColor("#FF4D4D"), HexColor("#FF0527")],
          fontSize: 16,
        )
      ]);
}
