import 'dart:typed_data';
import 'dart:ui';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_save/image_save.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/wallet/vo/wallet_view_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_share_req_entity.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_util.dart';
import 'package:titan/src/pages/red_pocket/rp_share_get_dialog_page.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/widget_shot.dart';

class RpShareSendSuccessPage extends StatefulWidget {
  final RpShareReqEntity reqEntity;
  final int actionType;
  RpShareSendSuccessPage({
    this.reqEntity,
    this.actionType = 0,
  });

  @override
  State<StatefulWidget> createState() {
    return _RpShareSendSuccessPageState();
  }
}

class _RpShareSendSuccessPageState extends BaseState<RpShareSendSuccessPage> {
  final ScrollController _scrollController = ScrollController();
  final ShotController _shotController = new ShotController();
  // GlobalKey _qrImageBoundaryKey = GlobalKey();

  WalletViewVo _walletVo;

  bool _isSharing = false;
  String get _address => _walletVo.wallet.getAtlasAccount().address;
  String get _walletName => _walletVo.wallet.keystore.name;
  RpShareTypeEntity get _shareTypeEntity => (widget.reqEntity?.rpType ?? RpShareType.normal) == RpShareType.normal
      ? SupportedShareType.NORMAL
      : SupportedShareType.LOCATION;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void onCreated() {
    super.onCreated();

    _setupData();
  }

  _setupData() {
    _walletVo = WalletInheritedModel.of(context).activatedWallet;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return widget.actionType == 1;
      },
      child: Scaffold(
        appBar: BaseAppBar(
          baseTitle: widget.actionType == 0 ? '广播成功' : '分享',
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  if (widget.actionType == 0) {
                    Routes.popUntilCachedEntryRouteName(context, true);
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              );
            },
          ),
        ),
        body: _body(context),
      ),
    );
  }

  Widget _body(BuildContext context) {
    return Column(
      children: <Widget>[
        if (widget.actionType == 0) _titleWidget(),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Center(
              child: Column(
                children: [
                  _contentWidget(),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        _bottomWidget(),
        SizedBox(
          height: 20,
        ),
        ClickOvalButton(
          (widget.reqEntity.isNewBee) ? '分享给新人' : '分享',
          () async {
            if (mounted) {
              setState(() {
                _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                _isSharing = true;
              });
            }

            Future.delayed(Duration(milliseconds: 111)).then((_) async {
              await _shareQr(context);
            });
          },
          btnColor: [HexColor("#FF4D4D"), HexColor("#FF0527")],
          fontSize: 16,
          width: 260,
          height: 42,
        ),
        SizedBox(
          height: 40,
        ),
      ],
    );
  }

  Widget _titleWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        36,
        12,
        36,
        20,
      ),
      child: Text(
        '请等待交易确认后开始分享红包给好友吧～',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: HexColor('#333333'),
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  Widget _bottomWidget() {
    return InkWell(
      onTap: () {
        _saveQrImage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: HexColor('#F2F2F2'),
        ),
        child: Text(
          '保存到相册',
          style: TextStyle(
            color: HexColor('#333333'),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _contentWidget() {
    String walletAddress = WalletUtil.ethAddressToBech32Address(_address);
    // var qrData = "${RpFriendInvitePage.shareDomain}?from=$walletAddress&name=$_walletName";
    var greeting = (widget.reqEntity?.greeting?.isNotEmpty ?? false) ? widget.reqEntity?.greeting : '恭喜发财，大吉大利!';
    var qrData = RpShareGetDialogPage.shareDomain +
        '?rpId=${widget.reqEntity.id}&from=$walletAddress&name=$_walletName&msg=$greeting';
    return WidgetShot(
      controller: _shotController,
      child: Container(
        // color: Theme.of(context).scaffoldBackgroundColor,
        // padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30,),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  width: 315,
                  height: 452,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'res/drawable/rp_share_bg_big.png',
                      ),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 42, top: 12),
                  child: Row(
                    children: [
                      Image.asset(
                        'res/drawable/rp_share_logo.png',
                        height: 26,
                        width: 25,
                      ),
                      SizedBox(width: 12,),
                      Text(
                        S.of(context).app_name,
                        style: TextStyle(
                          color: HexColor('#333333'),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
            Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 34,
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(width: 2, color: Colors.transparent),
                        image: DecorationImage(
                          image: AssetImage("res/drawable/app_invite_default_icon.png"),
                          fit: BoxFit.cover,
                        )),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 16,
                      bottom: 16,
                    ),
                    child: RichText(
                      text: TextSpan(
                        text: "${_walletVo.wallet.keystore.name} 发的${_shareTypeEntity.fullNameZh}",
                        style: TextStyle(
                          fontSize: 14,
                          color: HexColor('#333333'),
                        ),
                      ),
                    ),
                  ),

                  Text(
                    greeting,
                    style: TextStyle(
                      fontSize: greeting.length > 12 ? 14 : 22,
                      fontWeight: FontWeight.w600,
                      color: HexColor('#333333'),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        child: Image.asset(
                          "res/drawable/ic_rp_invite_friend_red_package.png",
                          width: 180,
                          height: 250,
                          //fit: BoxFit.fill,
                        ),
                      ),
                      Positioned(
                        top: 140,
                        child: Container(
                          decoration:
                              BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(5))),
                          width: 84,
                          height: 84,
                          child: QrImage(
                            padding: const EdgeInsets.all(9),
                            data: qrData,
                            size: 200,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future _saveQrImage() async {
    String address = WalletUtil.ethAddressToBech32Address(_address);
    bool result = false;

    try {
      Uint8List pngBytes = await _shotController.makeImageUint8List();
      result = await ImageSave.saveImage(pngBytes, "png", albumName: 'rp_address_$address');
    } catch (e) {
      result = false;
    }
    Fluttertoast.showToast(
      msg: result ? S.of(context).successfully_saved_album : S.of(context).save_fail,
    );
  }

  Future _shareQr(BuildContext context) async {
    Uint8List imageByte = await _shotController.makeImageUint8List();
    await Share.file('分享${_shareTypeEntity.fullNameZh}', 'app.png', imageByte, 'image/png');

    if (mounted) {
      setState(() {
        _isSharing = false;
      });
    }
  }
}
