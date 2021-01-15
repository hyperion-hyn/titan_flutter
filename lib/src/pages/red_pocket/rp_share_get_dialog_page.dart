import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/scaffold_map/map.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/red_pocket/api/rp_api.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_share_entity.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_share_req_entity.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_util.dart';
import 'package:titan/src/pages/red_pocket/rp_share_get_success_page.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart' as allPage;
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/round_border_textfield.dart';

class RpShareGetDialogPage extends StatefulWidget {
  static String shareDomain = "http://10.10.1.138:8090/newUsersRedPocket";
  final String walletName;
  final String address;
  final String id;
  final RedPocketShareType shareType;

  RpShareGetDialogPage({
    this.walletName = '',
    this.address = '',
    this.id = '',
    this.shareType = RedPocketShareType.NORMAL,
  });

  @override
  State<StatefulWidget> createState() {
    return _RpShareGetDialogState();
  }
}

class _RpShareGetDialogState extends BaseState<RpShareGetDialogPage> {
  final RPApi _rpApi = RPApi();
  allPage.AllPageState _currentState = allPage.LoadingState();
  RpShareEntity _shareEntity;
  final TextEditingController _textEditController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var activeWallet;
  LatLng latlng;

  @override
  void onCreated() async {
    super.onCreated();
    latlng = await (Keys.mapContainerKey.currentState as MapContainerState)?.mapboxMapController?.lastKnownLocation();

    _getNewBeeInfo();
  }

  void _getNewBeeInfo() async {
    try {
      _shareEntity = await _rpApi.getNewBeeDetail(
        widget.address,
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
  Widget build(BuildContext context) {
    var greeting = _shareEntity?.info?.greeting ?? '';
    var isNormal =
        (_shareEntity?.info?.rpType ?? 'normal') == RpShareType.location;

    var language = SettingInheritedModel.of(context).languageCode;
    var suffix = language == 'zh' ? 'zh' : 'en';
    var typeName = isNormal ? RpShareType.normal : RpShareType.location;
    typeName = RpShareType.location;
    suffix = 'zh';
    var state = ((_shareEntity?.info?.state ?? RpShareState.allGot) ==
            RpShareState.ongoing)
        ? RpShareState.ongoing
        : RpShareState.allGot;
    state = (_shareEntity?.info?.alreadyGot ?? true)
        ? RpShareState.allGot
        : state;
    var imageName = 'rp_share_${typeName}_${state}_${suffix}';

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () async {
                  try {
                    if (_currentState != null) {
                      return;
                    }

                    if(_shareEntity == null){
                      return;
                    }

                    if (_shareEntity.info.state != RpShareState.ongoing) {
                      return;
                    }

                    if (_shareEntity.info.alreadyGot) {
                      return;
                    }

                    if (_shareEntity.info.isNewBee && !_shareEntity.info.userIsNewBee) {
                      Fluttertoast.showToast(msg: "该红包只有新用户可领取");
                      return;
                    }

                    String rpSecret;
                    if(_shareEntity.info.hasPWD){
                      rpSecret = await _showStakingAlertView();
                      if(rpSecret == null || rpSecret.isEmpty){
                        return;
                      }
                    }

                    setState(() {
                      _currentState = allPage.LoadingState();
                    });

                    var id = _shareEntity?.info?.id ?? widget.id;
                    RpShareReqEntity reqEntity = RpShareReqEntity.only(id,widget.address,latlng.latitude,latlng.longitude,rpSecret);
                    print(
                        "[$runtimeType] open rp, 1, reqEntity:${reqEntity.toJson()}");

                    var result = await _rpApi.postOpenShareRp(
                      reqEntity: reqEntity,
                    );
                    print("[$runtimeType] open rp, 2, result:$result");

                    _shareEntity = await _rpApi.getNewBeeDetail(
                      widget.address,
                      id: widget.id,
                    );

                    if(mounted){
                      Navigator.pop(context);
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => RpShareGetSuccessPage(
                            _shareEntity.info.id
                        ),
                      ));
                    }

                  } catch (e) {
                    LogUtil.toastException(e);
                    setState(() {
                      _currentState = null;
                    });
                  }
                },
                child: Container(
                  child: Stack(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: 260,
                          height: 360,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                'res/drawable/$imageName.png',
                              ),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                height: 36,
                              ),
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        width: 2, color: Colors.transparent),
                                    image: DecorationImage(
                                      image: AssetImage(
                                          "res/drawable/app_invite_default_icon.png"),
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
                                    text:
                                        "${_shareEntity?.info?.owner ?? '--'} 发的${isNormal ? '新人' : '位置'}红包",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: HexColor('#FFFFFF'),
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                greeting,
                                style: TextStyle(
                                  fontSize: greeting.length > 12 ? 12 : 18,
                                  fontWeight: FontWeight.w600,
                                  color: HexColor('#FFFFFF'),
                                ),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_currentState == null && _shareEntity != null)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 20,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) => RpShareGetSuccessPage(
                                  _shareEntity.info.id
                                ),
                              ));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '看看大家的手气',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    color: HexColor('#FBE945'),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8,
                                  ),
                                  child: Image.asset(
                                    'res/drawable/rp_share_open_arrow.png',
                                    height: 11,
                                    width: 6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (_currentState != null)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: 360,
                            child: AllPageStateContainer(
                              _currentState,
                              () {},
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _currentState = allPage.LoadingState();
                                  });
                                  _getNewBeeInfo();
                                },
                                child: Center(
                                    child: Text(
                                  "点击重试",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                )),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(
                  40,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.asset(
                    "res/drawable/ic_dialog_close.png",
                    width: 40,
                    height: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> _showStakingAlertView() async {
    _textEditController.text = "";

    return await UiUtil.showAlertViewNew<String>(
      context,
      actions: [
        ClickOvalButton(
          S.of(context).confirm,
              (){
            Navigator.pop(context,_textEditController.text);
          },
          width: 200,
          height: 38,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          btnColor: [HexColor("#FF4D4D"), HexColor("#FF0527")],
        ),
      ],
      contentWidget: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top:19,bottom:32.0),
            child: Text("输入红包口令",style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: HexColor("#333333"),
                decoration: TextDecoration.none)),
          ),
          Padding(
            padding: const EdgeInsets.only(left:24,right:24.0,bottom: 20),
            child: Material(
              child: Form(
                key: _formKey,
                child: RoundBorderTextField(
                  controller: _textEditController,
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                        20),
                  ],
                  hintText: "请输入口令",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool> showShareRpOpenDialog(
  BuildContext context, {
  String id,
}) {
  var activeWallet = WalletInheritedModel.of(context)?.activatedWallet;
  if(activeWallet == null){
    Fluttertoast.showToast(msg: "请先导入钱包");
  }
  var _address  = activeWallet.wallet.getAtlasAccount().address;
  var _walletName = activeWallet.wallet.keystore.name;

  return showDialog<bool>(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return Builder(
        builder: (BuildContext buildContext) {
          return RpShareGetDialogPage(
            walletName: _walletName,
            id: id,
            address: _address,
          );
        },
      );
    },
  );
}
