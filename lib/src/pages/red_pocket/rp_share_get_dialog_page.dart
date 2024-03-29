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
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
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
import 'package:titan/src/widget/round_border_textField.dart';

class RpShareGetDialogPage extends StatefulWidget {
  static String shareDomain = "https://h.hyn.space/newUsersRedPocket";
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
    var greeting;
    var language = SettingInheritedModel.of(context).languageCode;
    var suffix = language == 'zh' ? 'zh' : 'en';
    var typeName;
    var getRemindHint;
    var state;
    var isNormal = true;
    var whoSendRpText;
    if (_shareEntity == null) {
      typeName = RpShareType.location;
      state = RpShareState.allGot;
      greeting = "";
      getRemindHint = "";
      whoSendRpText = "";
    } else {
      isNormal = _shareEntity.info.rpType == RpShareType.normal;
      whoSendRpText = S.of(context).rp_share_get_list_nickname_type(_shareEntity?.info?.owner ?? '--',isNormal ? S.of(context).newbee : S.of(context).position);

      greeting = _shareEntity?.info?.greeting ?? '';
      if (_shareEntity != null && greeting.isEmpty) {
        greeting = S.of(context).good_luck_and_get_rich;
      }
      if (((_shareEntity?.info?.state ?? "") == RpShareState.waitForTX ||
          ((_shareEntity?.info?.state ?? "") == RpShareState.pending))) {
        greeting = S.of(context).rp_being_prepared;
      }
      if (((_shareEntity?.info?.state ?? "") == RpShareState.allGot)) {
        greeting = S.of(context).hand_slow_rp_finished;
      }
      if (_shareEntity?.info?.alreadyGot ?? false) {
        greeting = S.of(context).have_already_received;
      }

      if ((_shareEntity.info.rpType == RpShareType.location && (_shareEntity?.info?.isNewBee ?? false)) ||
          ((_shareEntity?.info?.rpType ?? RpShareType.normal) != RpShareType.location)) {
        typeName = RpShareType.normal;
        getRemindHint = S.of(context).receive_equal_become_friends;
      } else {
        typeName = RpShareType.location;
        getRemindHint = S.of(context).get_lucky;
      }

      state = ((_shareEntity?.info?.state ?? RpShareState.allGot) == RpShareState.ongoing)
          ? RpShareState.ongoing
          : RpShareState.allGot;
      state = (_shareEntity?.info?.alreadyGot ?? true) ? RpShareState.allGot : state;
    }
    var imageName = 'rp_share_${typeName}_${state}_${suffix}';

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topCenter,
                      child: Stack(
                        children: [
                          Container(
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
                          if (!isNormal)
                            Positioned(
                              left: 16,
                              top: 11,
                              child: Row(
                                children: [
                                  Image.asset(
                                    "res/drawable/rp_share_location_image.png",
                                    width: 12,
                                    height: 16,
                                  ),
                                  SizedBox(
                                    width: 6,
                                  ),
                                  Text(
                                    "${_shareEntity?.info?.range ?? ""}${S.of(context).rp_edit_range_unit}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                            )
                        ],
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
                            iconWidget(_shareEntity?.info?.avatar, _shareEntity?.info?.owner, _shareEntity?.info?.address, isCircle: true,size: 50),
                            /*Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(width: 2, color: Colors.transparent),
                                  image: DecorationImage(
                                    image: AssetImage("res/drawable/app_invite_default_icon.png"),
                                    fit: BoxFit.cover,
                                  )),
                            ),*/
                            Padding(
                              padding: EdgeInsets.only(
                                top: 16,
                                bottom: 6,
                              ),
                              child: RichText(
                                text: TextSpan(
                                  text: whoSendRpText,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: HexColor('#FFFFFF'),
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              getRemindHint,
                              style: TextStyle(
                                fontSize: 14,
                                color: HexColor('#333333'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 25.0),
                              child: Text(
                                greeting,
                                style: TextStyle(
                                  fontSize: greeting.length > 12 ? 12 : 18,
                                  fontWeight: FontWeight.w600,
                                  color: HexColor('#FFFFFF'),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 48,
                      child: GestureDetector(
                        onTap: () async {
                          try {
                            if (_currentState != null) {
                              return;
                            }

                            if (_shareEntity == null) {
                              return;
                            }

                            if (_shareEntity.info.state != RpShareState.ongoing) {
                              return;
                            }

                            if (_shareEntity.info.alreadyGot) {
                              return;
                            }

                            if (_shareEntity.info.rpType == RpShareType.location && latlng == null) {
                              Fluttertoast.showToast(msg: S.of(context).failed_location_locate_current);
                              return;
                            }

                            if (_shareEntity.info.isNewBee && !_shareEntity.info.userIsNewBee) {
                              Fluttertoast.showToast(msg: S.of(context).rp_only_available_new);
                              return;
                            }

                            String rpSecret;
                            if (_shareEntity.info.hasPWD) {
                              rpSecret = await _showStakingAlertView();
                              if (rpSecret == null || rpSecret.isEmpty) {
                                return;
                              }
                            }

                            setState(() {
                              _currentState = allPage.LoadingState();
                            });

                            var id = _shareEntity?.info?.id ?? widget.id;
                            RpShareReqEntity reqEntity = RpShareReqEntity.only(
                                id, widget.address, latlng?.latitude, latlng?.longitude, rpSecret);
                            print("[$runtimeType] open rp, 1, reqEntity:${reqEntity.toJson()}");

                            var result = await _rpApi.postOpenShareRp(
                              reqEntity: reqEntity,
                            );

                            setState(() {
                              _currentState = null;
                            });

                            //print("[$runtimeType] open rp, 2, result:$result");

                            if (result == null) {
                              //print("[$runtimeType] open rp, 3, result:$result");

                              _shareEntity = await _rpApi.getNewBeeDetail(
                                widget.address,
                                id: widget.id,
                              );

                              if (mounted) {
                                Navigator.pop(context);
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) => RpShareGetSuccessPage(
                                    _shareEntity.info.id,
                                    isOpenRpJump: true,
                                  ),
                                ));
                              }
                            } else if (result == -40013) {
                              _showWarningDialog();
                            } else {
                              print("[$runtimeType] result:$result");
                            }
                          } catch (e) {
                            LogUtil.toastException(e);
                            setState(() {
                              _currentState = null;
                            });
                          }
                        },
                        child: Container(
                          height: 80,
                          width: 260,
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                    if (_currentState == null && _shareEntity != null)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 10,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) => RpShareGetSuccessPage(_shareEntity.info.id),
                            ));
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5.0, bottom: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  S.of(context).look_everyone_luck,
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
                      ),
                    if (_currentState != null)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 360,
                          child: AllPageStateContainer(
                            _currentState,
                            () {},
                            loadingColor: "#ffffff",
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentState = allPage.LoadingState();
                                });
                                _getNewBeeInfo();
                              },
                              child: Center(
                                  child: Text(
                                S.of(context).click_retry,
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
                    "res/drawable/ic_dialog_close_white.png",
                    width: 28,
                    height: 28,
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
          () {
            Navigator.pop(context, _textEditController.text);
          },
          width: 200,
          height: 38,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          fontColor: Colors.white,
          btnColor: [HexColor("#FF4D4D"), HexColor("#FF0527")],
        ),
      ],
      contentWidget: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 19, bottom: 32.0),
            child: Text(S.of(context).enter_rp_password,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: HexColor("#333333"),
                  decoration: TextDecoration.none,
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24.0, bottom: 20),
            child: Material(
              child: Form(
                key: _formKey,
                child: RoundBorderTextField(
                  controller: _textEditController,
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(20),
                  ],
                  hintText: S.of(context).please_enter_password,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _showWarningDialog() {
    UiUtil.showAlertView(
      context,
      title: S.of(context).warning,
      actions: [
        ClickOvalButton(
          S.of(context).confirm,
          () {
            Navigator.pop(context);
          },
          width: 115,
          height: 36,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ],
      content: S.of(context).location_abnormal_system_record,
      // contentColor: HexColor("#FF0527"),
    );
  }
}

Future<bool> showShareRpOpenDialog(
  BuildContext context, {
  String id,
}) {
  var activeWallet = WalletInheritedModel.of(context)?.activatedWallet;
  if (activeWallet == null) {
    Fluttertoast.showToast(msg: S.of(context).import_wallet_first);
  }
  var _address = activeWallet.wallet.getAtlasAccount().address;
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
