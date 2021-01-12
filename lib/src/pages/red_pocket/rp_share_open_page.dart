import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/pages/red_pocket/rp_record_detail_page.dart';


class RpShareOpenPage extends StatelessWidget {
  final String walletName;
  final String address;
  final RedPocketShareType shareType;

  RpShareOpenPage({
    this.walletName = '',
    this.address = '',
    this.shareType = RedPocketShareType.NEWER,
  });

  @override
  Widget build(BuildContext context) {
    var greeting = '恭喜发财，大吉大利,恭喜发财，大吉大利xxxx';
    greeting = '恭喜发财，大吉大利!xx';

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
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Container(
                      width: 260,
                      height: 360,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            'res/drawable/rp_share_open_bg.png',
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
                                text: "${this.walletName} 发的${shareType.index == 0 ? '新人' : '位置'}红包",
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
                      bottom: 12,
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



Future<bool> showShareRpOpenDialog(BuildContext context, String inviterAddress, String walletName) {
  return showDialog<bool>(
    barrierDismissible: true,
    context: context,
    builder: (context) {
      return RpShareOpenPage(
        walletName: inviterAddress,
        address: walletName,
      );
    },
  );
}

// showShareRpOpenDialog(context, 'inviterAddress', 'walletName');
