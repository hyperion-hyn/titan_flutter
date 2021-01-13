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

  RpShareEntity _shareEntity;

  @override
  void onCreated() {
    super.onCreated();

    _getNewBeeInfo();
  }

  void _getNewBeeInfo() async {
    RpShareSendEntity shareSendEntity = await _rpApi.getNewBeeInfo(
      widget.address,
      id: widget.id,
    );
    print("[$runtimeType] shareSendEntity:${shareSendEntity.toJson()}");

    _shareEntity = await _rpApi.getNewBeeDetail(
      widget.address,
      id: widget.id,
    );
    setState(() {});
    print("[$runtimeType] shareEntity:${_shareEntity.info.toJson()}");
  }

  @override
  Widget build(BuildContext context) {
    var greeting = _shareEntity?.info?.greeting ?? '恭喜发财，大吉大利';
    var isNormal = (_shareEntity?.info?.rpType ?? 'normal') == RpShareType.location;

    var language = SettingInheritedModel.of(context).languageCode;
    var suffix = language == 'zh' ? 'zh' : 'en';
    var typeName = isNormal ? RpShareType.normal : RpShareType.location;
    typeName = RpShareType.location;
    suffix = 'zh';
    var state = _shareEntity?.info?.state??'onGoging';
    var imageName = 'rp_share_${typeName}_${suffix}_${state}';

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
                    var id = _shareEntity?.info?.id ?? widget.id;
                    RpShareReqEntity reqEntity = RpShareReqEntity.only(id);
                    print("[$runtimeType] open rp, 1, reqEntity:${reqEntity.toJson()}");

                    var result = await _rpApi.postOpenShareRp(
                      reqEntity: reqEntity,
                      address: widget.address,
                    );
                    print("[$runtimeType] open rp, 2, result:$result");
                  } catch(e) {
                    LogUtil.toastException(e);
                  }
                },
                child: Container(
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: <Widget>[
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
                      Container(
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
                                  text: "${_shareEntity?.info?.owner ?? '--'} 发的${isNormal ? '新人' : '位置'}红包",
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
                      Positioned(
                        bottom: 20,
                        child: InkWell(
                          onTap: () {
                            // todo:
                          },
                          child: Row(
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

Future<bool> showShareRpOpenDialog({
  BuildContext context,
  String walletName,
  String address,
  String id,
}) {
  return showDialog<bool>(
    barrierDismissible: true,
    context: context,
    builder: (context) {
      return RpShareOpenPage(
        walletName: walletName,
        id: id,
        address: address,
      );
    },
  );
}
