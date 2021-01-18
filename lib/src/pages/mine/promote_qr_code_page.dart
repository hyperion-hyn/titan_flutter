import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/pages/red_pocket/api/rp_api.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';
import 'dart:typed_data';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/widget_shot.dart';

class PromoteQrCodePage extends StatefulWidget {
  static String downloadDomain = "https://h.hyn.space/download";
  // static String downloadDomain = 'https://10.10.1.134:8090/download';

  PromoteQrCodePage();

  @override
  State<StatefulWidget> createState() {
    return _PromoteQrCodePageState();
  }
}

class _PromoteQrCodePageState extends BaseState<PromoteQrCodePage> {
  final ShotController _shotController = new ShotController();
  List<String> imagesList = [];
  var shareAppImage = "";
  ScrollController scrollController = ScrollController();
  WalletVo walletVo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    walletVo = WalletInheritedModel.of(context).activatedWallet;
  }

  @override
  Widget build(BuildContext context) {
    if (shareAppImage.isEmpty) {
      shareAppImage = "res/drawable/bg_invitation_bg_image_1.png";
      imagesList.add("res/drawable/bg_invitation_bg_image_1.png");
      imagesList.add("res/drawable/bg_invitation_bg_image_2.png");
      imagesList.add("res/drawable/bg_invitation_bg_image_3.png");
      imagesList.add("res/drawable/bg_invitation_bg_image_4.png");
    }

    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: S.of(context).invite_friends,
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    var hynAddress = WalletUtil.ethAddressToBech32Address(walletVo.wallet.getAtlasAccount().address);
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.only(top: 26, bottom: 21, left: 48, right: 48),
              child: SizedBox(
                height: 400,
                child: WidgetShot(
                  controller: _shotController,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(shareAppImage),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: 28,
                            ),
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                  color: Colors.white,
//                                    gradient: LinearGradient(colors: [
//                                      HexColor("#ffd985"),
//                                      HexColor("#ffa73f"),
//                                    ]),
                                  shape: BoxShape.circle,
                                  border: Border.all(width: 2, color: Colors.transparent),
                                  image: DecorationImage(
                                    image: AssetImage("res/drawable/app_invite_default_icon.png"),
                                    fit: BoxFit.cover,
                                  )),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 3, bottom: 5.0, left: 15, right: 15),
                              child: RichText(
                                text: TextSpan(
                                    text: "${walletVo.wallet.keystore.name}  ",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    children: [
                                      TextSpan(
                                          text: "${shortBlockChainAddress(hynAddress)}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                          ))
                                    ]),
                              ),
                            ),
                            Text(
                              S.of(context).invite_join_titan,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            Spacer(),
                            SizedBox(
                              width: 58,
                              height: 58,
                              child: QrImage(
                                data: "${PromoteQrCodePage.downloadDomain}?from=$hynAddress"
                                    "&name=${walletVo.wallet.keystore.name}",
                                padding: EdgeInsets.all(2),
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                version: QrVersions.auto,
                                size: 89,
                              ),
                            ),
                            SizedBox(
                              height: 118,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        _bottomImageList(),
        ClickOvalButton(
          S.of(context).invite_friends,
          () async {
            scrollController.jumpTo(scrollController.position.maxScrollExtent);
            await _shareQr(context);
          },
          btnColor: [HexColor("#FF4D4D"), HexColor("#FF0527")],
          fontSize: 16,
          width: 200,
          height: 38,
        ),
        SizedBox(
          height: 40,
        )
      ],
    );
  }

  Future _shareQr(BuildContext context) async {
//    print('_shareQr --> action, _shotController: ${_shotController.hashCode}');
//    print('_shareQr --> action, globalKey:${_shotController.globalKey.currentContext}, context:${context}');

    Uint8List imageByte = await _shotController.makeImageUint8List();
    await Share.file(
        S.of(context).nav_share_app, '${DateTime.now().millisecondsSinceEpoch}.png', imageByte, 'image/png');
  }

  Widget _bottomImageList() {
    return Padding(
      padding: EdgeInsets.only(left: 16.0, bottom: 23, right: 16),
      child: Container(
        height: 85,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              String imagePath = imagesList[index];
              return Padding(
                padding: const EdgeInsets.only(left: 13, right: 13.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      shareAppImage = imagesList[index];
                    });
                  },
                  child: Container(
                    width: 60,
                    decoration: (shareAppImage == imagePath)
                        ? BoxDecoration(
                            border: Border.all(color: HexColor('#FF0527'), width: 2),
                            borderRadius: BorderRadius.circular(5.0),
                          )
                        : null,
                    child: Image.asset(
                      imagesList[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
            itemCount: imagesList.length),
      ),
    );
  }
}

void showTitanInviteDialog(BuildContext context, String inviterAddress, String walletName, String code,
    {Function callback}) {
  UiUtil.showAlertView(
    context,
    title: S.of(context).invite_join,
    actions: [
      ClickOvalButton(
        S.of(context).cancel,
        () {
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
          Navigator.pop(context);

          try {
            RPApi _rpApi = RPApi();
            var walletVo = WalletInheritedModel.of(context).activatedWallet;
            String inviteResult = await _rpApi.postRpInviter(inviterAddress, walletVo.wallet);
            if (inviteResult != null) {
              Fluttertoast.showToast(msg: S.of(context).invitation_success);
              if (callback != null) callback();
            }
          } catch (error) {
            LogUtil.toastException(error);
          }
        },
        width: 120,
        height: 38,
        fontSize: 16,
      ),
    ],
    content: "$walletName ${shortBlockChainAddress(inviterAddress)} 邀请你加入泰坦，为你激活账号并成为他的好友，是否接受邀请？",
  );
}
