import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/pages/red_pocket/api/rp_api.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_share_entity.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_share_req_entity.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_util.dart';
import 'package:titan/src/pages/red_pocket/rp_record_detail_page.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart' as allPage;
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';

class RpShareOpenPage extends StatefulWidget {
  final String walletName;
  final String address;
  final String id;
  final RedPocketShareType shareType;

  RpShareOpenPage({
    this.walletName = '',
    this.address = '',
    this.id = '',
    this.shareType = RedPocketShareType.NORMAL,
  });

  @override
  State<StatefulWidget> createState() {
    return _RpShareSendState();
  }
}

class _RpShareSendState extends BaseState<RpShareOpenPage> {
  final RPApi _rpApi = RPApi();
  allPage.AllPageState _currentState = allPage.LoadingState();

  RpShareEntity _shareEntity;

  @override
  void onCreated() {
    super.onCreated();

    _getNewBeeInfo();
  }

  void _getNewBeeInfo() async {
    try {
      RpShareSendEntity shareSendEntity = await _rpApi.getNewBeeInfo(
        widget.address,
        id: widget.id,
      );
      print("[$runtimeType] shareSendEntity:${shareSendEntity.toJson()}");

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

    var abc = 'res/drawable/$imageName.png';
    print("!!!!3333 $abc");
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

                    var id = _shareEntity?.info?.id ?? widget.id;
                    RpShareReqEntity reqEntity = RpShareReqEntity.only(id);
                    print(
                        "[$runtimeType] open rp, 1, reqEntity:${reqEntity.toJson()}");

                    var result = await _rpApi.postOpenShareRp(
                      reqEntity: reqEntity,
                      address: widget.address,
                    );
                    print("[$runtimeType] open rp, 2, result:$result");
                  } catch (e) {
                    LogUtil.toastException(e);
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
                      if (_currentState == null)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 20,
                          child: InkWell(
                            onTap: () {
                              // todo:
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
                              child: InkWell(
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
}

Future<bool> showShareRpOpenDialog(
  BuildContext context, {
  String walletName,
  String address,
  String id,
}) {
  return showDialog<bool>(
    barrierDismissible: true,
    context: context,
    builder: (context) {
      return Builder(
        builder: (BuildContext buildContext) {
          return RpShareOpenPage(
            walletName: walletName,
            id: id,
            address: address,
          );
        },
      );
    },
  );
}
