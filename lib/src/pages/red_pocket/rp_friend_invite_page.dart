import 'dart:typed_data';
import 'dart:ui';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/app_lock/util/app_lock_util.dart';
import 'package:titan/src/components/wallet/vo/wallet_view_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/data/cache/memory_cache.dart';
import 'package:titan/src/pages/app_tabbar/bloc/bloc.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/pages/wallet/model/wallet_send_dialog_util.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/wallet_widget.dart';
import 'package:titan/src/widget/widget_shot.dart';
import 'package:flutter_html/flutter_html.dart';
import 'api/rp_api.dart';
import 'package:flutter_html/style.dart';

class RpFriendInvitePage extends StatefulWidget {
  static String shareDomain = "https://h.hyn.space/share";

  RpFriendInvitePage();

  @override
  State<StatefulWidget> createState() {
    return _RpFriendInvitePageState();
  }
}

class _RpFriendInvitePageState extends BaseState<RpFriendInvitePage> {
  WalletViewVo activityWallet;
  final ShotController _shotController = new ShotController();
  ScrollController scrollController = ScrollController();
  bool _isSharing = false;

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
        appBar: BaseAppBar(baseTitle: S.of(context).invite_friends),
        body: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  WidgetShot(
                    controller: _shotController,
                    child: Stack(
                      children: <Widget>[
                        Image.asset(
                          "res/drawable/bg_rp_invite_friend_top.png",
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: Container(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(
                                    height: 25,
                                  ),
                                  iconWalletWidget(WalletModelUtil.wallet, isCircle: true, size: 60),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 2,
                                    ),
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
                                  Container(
                                    //color: Colors.red,
                                    child: Html(
                                      data: S.of(context).invite_come_receive_red_pocket,
                                      style: {
                                        "p": Style(textAlign: TextAlign.center),
                                        "span": Style(
                                          fontWeight: FontWeight.bold,
                                          fontSize: FontSize(20),
                                        )
                                      },
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: <Widget>[
                                        Container(
                                          //color: Colors.red,
                                          child: Image.asset(
                                            "res/drawable/ic_rp_invite_friend_red_package.png",
                                            width: 238,
                                            height: 336,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                        Positioned(
                                          top: 162,
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.all(Radius.circular(5))),
                                            width: 84,
                                            height: 84,
                                            child: QrImage(
                                              padding: const EdgeInsets.all(9),
                                              data:
                                                  "${RpFriendInvitePage.shareDomain}?from=$walletAddress&name=$walletName",
                                              size: 84,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 36,
                                          left: 29,
                                          right: 29,
                                          child: Text(
                                            S.of(context).world_first_hrc30_case,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: HexColor('#FFFFFF'),
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 25,
                                  ),
                                  Visibility(
                                    visible: !_isSharing,
                                    child: ClickOvalButton(
                                      S.of(context).share,
                                      () async {
                                        if (mounted) {
                                          setState(() {
                                            scrollController.jumpTo(scrollController.position.maxScrollExtent);
                                            _isSharing = true;
                                          });
                                        }

                                        Future.delayed(Duration(milliseconds: 111)).then((_) async {
                                          await _shareQr(context);
                                        });
                                      },
                                      fontColor: Colors.white,
                                      btnColor: [HexColor("#FF4D4D"), HexColor("#FF0527")],
                                      fontSize: 16,
                                      width: 200,
                                      height: 38,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 25,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Future _shareQr(BuildContext context) async {
    AppLockUtil.ignoreAppLock(context, true);

    Uint8List imageByte = await _shotController.makeImageUint8List();
    await Share.file(S.of(context).nav_share_app, 'app.png', imageByte, 'image/png');

    if (mounted) {
      setState(() {
        _isSharing = false;
      });
    }
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
            child: Text(S.of(context).red_pocket_invitation_together,
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
                  text: S.of(context).invite_friend_receive_pocket_agree,
                  style: TextStyles.textC333S14,
                ),
              ]),
            ),
          )
        ],
      ),
      actions: [
        ClickOvalButton(
          S.of(context).key_accept,
          () async {
            Navigator.pop(context);

            RPApi _rpApi = RPApi();
            var walletVo = WalletInheritedModel.of(context).activatedWallet;
            if (walletVo == null) {
              UiUtil.showAlertView(context,
                  title: S.of(context).red_pocket_invitation_together,
                  content: S.of(context).create_wallet_auto_friend_create_now(walletName),
                  actions: [
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
              String inviteResult = await _rpApi.postRpInviter(inviterAddress, walletVo.wallet);
              if (inviteResult != null) {
                Fluttertoast.showToast(msg: S.of(context).invitation_success);

                var entryRouteName = Uri.encodeComponent(Routes.red_pocket_page);

                Application.router.navigateTo(
                    context,
                    Routes.red_pocket_page +
                        "?entryRouteName=$entryRouteName");
              }
            } catch (error) {
              LogUtil.toastException(error);
            }
          },
          fontColor: Colors.white,
          btnColor: [HexColor("#FF4D4D"), HexColor("#FF0527")],
          fontSize: 16,
        )
      ]);
}
