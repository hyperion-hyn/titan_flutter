import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/image_util.dart';
import 'package:titan/src/utils/psw_strength/password_strength_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart'
    as all_page_state;

class WalletCreateAccountPage2 extends StatefulWidget {
  WalletCreateAccountPage2();

  @override
  State<StatefulWidget> createState() {
    return _WalletCreateAccountPage2State();
  }
}

class _WalletCreateAccountPage2State extends State<WalletCreateAccountPage2> {
  TextEditingController _walletNameController = TextEditingController();
  TextEditingController _walletPwsController = TextEditingController();
  TextEditingController _walletRePwsController = TextEditingController();
  TextEditingController _walletPwsHintController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _pswLevel = 0;
  bool isShowPws = false;
  bool isCreateWallet = false;

  @override
  void initState() {
    super.initState();

    _walletPwsController.addListener(() {
      var pswStr = _walletPwsController.text;
      _pswLevel = PasswordStrengthUtil.getPasswordLevel(pswStr, limitLength: 8);
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: BaseAppBar(baseTitle: ""),
        body: _pageWidget(context));
  }

  Widget _pageWidget(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: BaseGestureDetector(
              context: context,
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 10.0, bottom: 10, left: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "创建身份",
                        style: TextStyles.textC333S14bold,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0, bottom: 40),
                        child: Text("你将会拥有身份下的多链钱包：HYN，ETH，\nUSDT(ERC 20)，BTC。",
                            style: TextStyles.textC999S14),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Spacer(),
                          Text(
                            "头像",
                            style: TextStyles.textC333S14,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 2, right: 20),
                            child: Text(
                              "(可选)",
                              style: TextStyles.textC999S12,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              UiUtil.showScanImagePickerSheet(context,
                                  callback: (String text) {
                                // _parseText(text);
                              });
                            },
                            child: SizedBox(
                              width: 60,
                              height: 60,
                              child: ImageUtil.getCoinImage(
                                  "res/drawable/ic_user_avatar_default.png"),
                            ),
                          )
                        ],
                      ),
                      Container(
                        height: 50,
                        margin: const EdgeInsets.only(top: 20, bottom: 12),
                        child: TextFormField(
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(8),
                          ],
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value.isEmpty) {
                              return S.of(context).input_wallet_name_hint;
                            } else {
                              return null;
                            }
                          },
                          controller: _walletNameController,
                          decoration: InputDecoration(
                            hintText: "身份名称",
                            hintStyle: TextStyles.textCaaaS14,
                            filled: true,
                            fillColor: DefaultColors.colorf6f6f6,
                            enabledBorder: getDefaultBoard(),
                            focusedBorder: getDefaultBoard(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: DefaultColors.colorf6f6f6,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                obscureText: !isShowPws,
                                //obscureText为false则显示
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return S.of(context).input_wallet_name_hint;
                                  } else {
                                    return null;
                                  }
                                },
                                controller: _walletPwsController,
                                decoration: InputDecoration(
                                  hintText: "密码",
                                  hintStyle: TextStyles.textCaaaS14,
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  enabledBorder: getDefaultBoard(),
                                  focusedBorder: getDefaultBoard(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 16, right: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    pswLevelLabel(),
                                    style: TextStyle(
                                        color: HexColor("#E7BB00"),
                                        fontSize: 14),
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Image.asset(
                                    pswLevelImage(),
                                    width: 25,
                                    height: 14,
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 10, top: 4),
                        child: Text(
                          "不少于8位字符，建议混合大小写字母、数字、符号",
                          style: TextStyle(
                              color: HexColor(
                                "#E7BB00",
                              ),
                              fontSize: 10),
                        ),
                      ),
                      Container(
                        height: 50,
                        margin: const EdgeInsets.only(top: 12, bottom: 12),
                        decoration: BoxDecoration(
                          color: DefaultColors.colorf6f6f6,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                obscureText: !isShowPws,
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return S.of(context).input_wallet_name_hint;
                                  } else {
                                    return null;
                                  }
                                },
                                controller: _walletRePwsController,
                                decoration: InputDecoration(
                                  hintText: "重复输入密码",
                                  hintStyle: TextStyles.textCaaaS14,
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  enabledBorder: getDefaultBoard(),
                                  focusedBorder: getDefaultBoard(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  isShowPws = !isShowPws;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, top: 5, bottom: 5),
                                child: Image.asset(
                                  isShowPws
                                      ? "res/drawable/ic_input_psw_show.png"
                                      : "res/drawable/ic_input_psw_hide.png",
                                  width: 20,
                                  height: 15,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: 50,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: TextFormField(
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(20),
                          ],
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value.isEmpty) {
                              return S.of(context).input_wallet_name_hint;
                            } else {
                              return null;
                            }
                          },
                          controller: _walletPwsHintController,
                          decoration: InputDecoration(
                            hintText: "密码提示(可选)",
                            hintStyle: TextStyles.textCaaaS14,
                            filled: true,
                            fillColor: DefaultColors.colorf6f6f6,
                            enabledBorder: getDefaultBoard(),
                            focusedBorder: getDefaultBoard(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 36.0, top: 22),
          child: ClickOvalButton(
            isCreateWallet ? "创建" : "恢复身份",
            () {},
            width: 300,
            height: 46,
            btnColor: [
              HexColor("#F7D33D"),
              HexColor("#E7C01A"),
            ],
            fontSize: 16,
            fontColor: DefaultColors.color333,
          ),
        )
      ],
    );
  }

  InputBorder getDefaultBoard() {
    return UnderlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(
        width: 0,
        color: Colors.white,
      ),
    );
  }

  String pswLevelLabel() {
    switch (_pswLevel) {
      case 0:
      case 1:
        return "弱";
      case 2:
        return "一般";
      case 3:
        return "强";
      case 4:
        return "很好";
      default:
        return "弱";
    }
  }

  String pswLevelImage() {
    switch (_pswLevel) {
      case 0:
        return "res/drawable/ic_input_psw_level_0.png";
      case 1:
        return "res/drawable/ic_input_psw_level_1.png";
      case 2:
        return "res/drawable/ic_input_psw_level_2.png";
      case 3:
        return "res/drawable/ic_input_psw_level_3.png";
      case 4:
        return "res/drawable/ic_input_psw_level_4.png";
      default:
        return "res/drawable/ic_input_psw_level_0.png";
    }
  }
}
