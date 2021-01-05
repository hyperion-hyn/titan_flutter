import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_pickers/UIConfig.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:r_scan/r_scan.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/image_util.dart';
import 'package:titan/src/utils/psw_strength/password_strength_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart'
    as all_page_state;
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';

class WalletCreateAccountPageV2 extends StatefulWidget {
  final bool isCreateWallet;
  WalletCreateAccountPageV2(this.isCreateWallet);

  @override
  State<StatefulWidget> createState() {
    return _WalletCreateAccountPageV2State();
  }
}

class _WalletCreateAccountPageV2State
    extends BaseState<WalletCreateAccountPageV2> {
  TextEditingController _walletNameController = TextEditingController();
  TextEditingController _walletPwsController = TextEditingController();
  TextEditingController _walletRePwsController = TextEditingController();
  TextEditingController _walletPwsHintController = TextEditingController();
  TextEditingController _mnemonicController = TextEditingController(text: "");

  final _formKey = GlobalKey<FormState>();
  int _pswLevel = 0;
  bool isShowPws = false;
  bool showErrorHint = false;
  bool isShowRemind = true;
  BuildContext dialogContext;
  String usetImagePath;
  AtlasApi _atlasApi = AtlasApi();
  FocusNode _focusNode = FocusNode();

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
  void onCreated() {
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        showErrorHint = true;
        UiUtil.showErrorTopHint(context,
            "该密码作为身份下多链钱包的交易密码。钱包密码只存于手机设备山，永远不离开设备，如果忘记将无法找回，请务必妥善保管密码。",
            errorHintType: ErrorHintType.REMIND);
      } else {
        if (showErrorHint) {
          showErrorHint = false;
          Navigator.pop(context);
        }
      }
    });
    super.onCreated();
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
                        widget.isCreateWallet ? "创建身份" : "恢复身份",
                        style: TextStyles.textC333S14bold,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0, bottom: 20),
                        child: Text(widget.isCreateWallet ? "你将会拥有身份下的多链钱包：HYN，ETH，\nUSDT(ERC 20)，BTC。" : "使用助记词导入的同时可以修改钱包密码",
                            style: TextStyles.textC999S14),
                      ),
                      if(!widget.isCreateWallet)
                        Container(
                          constraints: BoxConstraints.expand(height: 120),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.only(left: 8.0, right: 8),
                          decoration: BoxDecoration(
                              color: DefaultColors.colorf6f6f6,
                              borderRadius: BorderRadius.circular(6),),
                          child: TextFormField(
                            validator: (value) {
                              if (value.isEmpty) {
                                return S.of(context).please_input_mnemonic;
                              } else {
                                return null;
                              }
                            },
                            controller: _mnemonicController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: InputDecoration(hintText: "输入助记词，并使用空格分隔",
                                hintStyle: TextStyles.textCaaaS14,
                                filled: true,
                                fillColor: Colors.transparent,
                                border: InputBorder.none,),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top:20.0),
                        child: Row(
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
                              onTap: () async {
                                var tempListImagePaths =
                                    await ImagePickers.pickerPaths(
                                  galleryMode: GalleryMode.image,
                                  selectCount: 1,
                                  showCamera: true,
                                  cropConfig: null,
                                  compressSize: 500,
                                  uiConfig:
                                      UIConfig(uiThemeColor: Color(0xff0f95b0)),
                                );
                                if (tempListImagePaths != null &&
                                    tempListImagePaths.length == 1) {
                                  UiUtil.showLoadingDialog(context, "头像上传中...",
                                      (context) {
                                    dialogContext = context;
                                  });

                                  var netImagePath =
                                      await _atlasApi.postUploadImageFile(
                                    "0x",
                                    tempListImagePaths[0].path,
                                    (count, total) {},
                                  );
                                  if (netImagePath != null &&
                                      netImagePath.isNotEmpty) {
                                    usetImagePath = netImagePath;
                                    setState(() {});
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: S.of(context).scan_upload_error);
                                  }
                                  if (dialogContext != null) {
                                    Navigator.pop(dialogContext);
                                  }
                                }
                              },
                              child: SizedBox(
                                width: 60,
                                height: 60,
                                child: ImageUtil.getCoinImage(
                                    usetImagePath != null
                                        ? usetImagePath
                                        : "res/drawable/ic_user_avatar_default.png",
                                    placeholder:
                                        "res/drawable/ic_user_avatar_default.png"),
                              ),
                            )
                          ],
                        ),
                      ),
                      Stack(
                        children: [
                          Container(
                            height: 50,
                            margin: const EdgeInsets.only(top: 20, bottom: 12),
                            decoration: BoxDecoration(
                              color: DefaultColors.colorf6f6f6,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          Container(
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
                                fillColor: Colors.transparent,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Stack(
                        children: [
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: DefaultColors.colorf6f6f6,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  //obscureText为false则显示
                                  obscureText: !isShowPws,
                                  keyboardType: TextInputType.visiblePassword,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      setState(() {
                                        isShowRemind = false;
                                      });
                                      return "请输入密码";
                                    } else if (value.length < 8) {
                                      setState(() {
                                        isShowRemind = false;
                                      });
                                      return "密码小于8位";
                                    } else {
                                      setState(() {
                                        isShowRemind = true;
                                      });
                                      return null;
                                    }
                                  },
                                  controller: _walletPwsController,
                                  focusNode: _focusNode,
                                  decoration: InputDecoration(
                                    hintText: "密码",
                                    hintStyle: TextStyles.textCaaaS14,
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 50,
                                child: Padding(
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
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      if(isShowRemind)
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
                      Stack(
                        children: [
                          Container(
                            height: 50,
                            margin: const EdgeInsets.only(top: 12, bottom: 12),
                            decoration: BoxDecoration(
                              color: DefaultColors.colorf6f6f6,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 12, bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    //obscureText为false则显示
                                    obscureText: !isShowPws,
                                    keyboardType: TextInputType.visiblePassword,
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return "请输入密码";
                                      } else if (value.length < 8) {
                                        return "密码小于8位";
                                      } else if (_walletPwsController.text != _walletRePwsController.text) {
                                        return "密码不一致";
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
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 50,
                                  child: InkWell(
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
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Stack(
                        children: [
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: DefaultColors.colorf6f6f6,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          Container(
                            child: TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(8),
                              ],
                              keyboardType: TextInputType.text,
                              controller: _walletPwsHintController,
                              decoration: InputDecoration(
                                hintText: "密码提示(可选)",
                                hintStyle: TextStyles.textCaaaS14,
                                filled: true,
                                fillColor: Colors.transparent,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
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
            widget.isCreateWallet ? "创建" : "恢复身份",
            () {
              if(!_formKey.currentState.validate()){
                return;
              }
            },
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
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(
        width: 0,
        color: DefaultColors.colorf6f6f6,
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
