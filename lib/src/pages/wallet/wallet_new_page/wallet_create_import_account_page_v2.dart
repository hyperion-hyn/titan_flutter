import 'package:bitcoin_flutter/bitcoin_flutter.dart' as bitWallet;
import 'package:ethereum_address/ethereum_address.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_pickers/UIConfig.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:r_scan/r_scan.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/app_lock/util/app_lock_util.dart';
import 'package:titan/src/components/exchange/bloc/bloc.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/config/extends_icon_font.dart';
import 'package:titan/src/data/cache/memory_cache.dart';
import 'package:titan/src/pages/atlas_map/entity/pledge_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/user_payload_with_address_entity.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/pages/red_pocket/api/rp_api.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_expand_info_entity.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/image_util.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/psw_strength/password_strength_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart' as all_page_state;
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:bip39/bip39.dart' as bip39;
import "package:convert/convert.dart" show hex;

class WalletCreateAccountPageV2 extends StatefulWidget {
  final bool isCreateWallet;

  WalletCreateAccountPageV2(this.isCreateWallet);

  @override
  State<StatefulWidget> createState() {
    return _WalletCreateAccountPageV2State();
  }
}

class _WalletCreateAccountPageV2State extends BaseState<WalletCreateAccountPageV2> {
  TextEditingController _walletNameController = TextEditingController();
  TextEditingController _walletPswController = TextEditingController();
  TextEditingController _walletRePswController = TextEditingController();
  TextEditingController _walletPswHintController = TextEditingController();
  TextEditingController _mnemonicController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  int _pswLevel = 0;
  bool isShowPsw = false;
  bool showErrorHint = false;
  bool isShowRemind = true;
  BuildContext dialogContext;
  String userImagePath;
  String userImageLocalPath;
  AtlasApi _atlasApi = AtlasApi();
  FocusNode _focusNode = FocusNode();
  bool isSubmitLoading = false;

  @override
  void initState() {
    super.initState();

    _walletPswController.addListener(() {
      var pswStr = _walletPswController.text;
      _pswLevel = PasswordStrengthUtil.getPasswordLevel(pswStr, limitLength: 8);
      setState(() {});
    });

    userImagePath = WalletUtil.getRandomAvatarUrl();
  }

  @override
  void onCreated() {
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        showErrorHint = true;
        UiUtil.showErrorTopHint(context, S.of(context).password_stored_phone_forget_not_retrieve,
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
        appBar: BaseAppBar(
          baseTitle: "",
          actions: widget.isCreateWallet
              ? null
              : [
                  InkWell(
                    onTap: () async {
                      UiUtil.showScanImagePickerSheet(context, callback: (String text) {
                        if (text.isEmpty || (text.isNotEmpty && !bip39.validateMnemonic(text))) {
                          Fluttertoast.showToast(msg: S.of(context).illegal_mnemonic);
                        } else {
                          _mnemonicController.text = text;
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8, left: 15, right: 15),
                      child: Icon(
                        ExtendsIconFont.qrcode_scan,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
        ),
        body: _pageWidget(context));
  }

  Widget _pageWidget(BuildContext context) {
    return SingleChildScrollView(
      child: BaseGestureDetector(
        context: context,
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 10, left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isCreateWallet
                      ? S.of(context).create_identity
                      : S.of(context).restore_identity,
                  style: TextStyles.textC333S14bold,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6.0, bottom: 20),
                  child: Text(
                      widget.isCreateWallet
                          ? S.of(context).will_have_wallet_under
                          : S.of(context).modify_password_importing_mnemonic,
                      style: TextStyles.textC999S14),
                ),
                if (!widget.isCreateWallet)
                  Container(
                    constraints: BoxConstraints.expand(height: 120),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    decoration: BoxDecoration(
                      color: DefaultColors.colorf6f6f6,
                      borderRadius: BorderRadius.circular(6),
                    ),
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
                      decoration: InputDecoration(
                        hintText: S.of(context).enter_mnemonic_by_spaces,
                        hintStyle: TextStyles.textCaaaS14,
                        filled: true,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Spacer(),
                      Text(
                        S.of(context).avatar,
                        style: TextStyles.textC333S14,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2, right: 20),
                        child: Text(
                          "(${S.of(context).optional})",
                          style: TextStyles.textC999S12,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          ///Ignore AppLock
                          await AppLockUtil.ignoreAppLock(context, true);

                          editIconSheet(context, (tempListImagePath) async {
                            if (tempListImagePath != null) {
                              ///turn off app-lock
                              AppLockUtil.appLockSwitch(context, false);

                              if (tempListImagePath != null) {
                                UiUtil.showLoadingDialog(context, S.of(context).avatar_uploading,
                                    (context) {
                                  dialogContext = context;
                                });

                                var netImagePath = await _atlasApi.postUploadImageFile(
                                  "0x",
                                  tempListImagePath,
                                  (count, total) {},
                                );
                                if (netImagePath != null && netImagePath.isNotEmpty) {
                                  userImageLocalPath = tempListImagePath;
                                  userImagePath = netImagePath;
                                  setState(() {});
                                } else {
                                  Fluttertoast.showToast(msg: S.of(context).scan_upload_error);
                                }
                                if (dialogContext != null) {
                                  Navigator.pop(dialogContext);
                                }
                              }
                            }
                          });
                        },
                        child: iconWidget(userImagePath, null, null, isCircle: true, size: 60),
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
                          hintText: S.of(context).identity_name,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: pswListWidget(
                      isShowPsw,
                      (value) {
                        if (value.isEmpty) {
                          setState(() {
                            isShowRemind = false;
                          });
                          return S.of(context).please_input_pwd;
                        } else if (value.length < 8) {
                          setState(() {
                            isShowRemind = false;
                          });
                          return S.of(context).password_less_than_eight;
                        } else {
                          setState(() {
                            isShowRemind = true;
                          });
                          return null;
                        }
                      },
                      _walletPswController,
                      _focusNode,
                      pswLevelLabel(_pswLevel),
                      pswLevelImage(_pswLevel),
                      isShowRemind,
                      _walletRePswController,
                      () {
                        setState(() {
                          isShowPsw = !isShowPsw;
                        });
                      },
                      _walletPswHintController),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 36.0, top: 22),
                    child: ClickOvalButton(
                      widget.isCreateWallet ? S.of(context).create : S.of(context).restore_identity,
                      () async {
                        if (isSubmitLoading) {
                          return;
                        }
                        await submitAction();
                        setState(() {
                          isSubmitLoading = false;
                        });
                      },
                      width: 300,
                      height: 46,
                      btnColor: [
                        HexColor("#F7D33D"),
                        HexColor("#E7C01A"),
                      ],
                      fontSize: 16,
                      fontColor: DefaultColors.color333,
                      isDisable: isSubmitLoading,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
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

  Future submitAction() async {
    try {
      isSubmitLoading = true;
      if (!_formKey.currentState.validate()) {
        // setState(() {
        //   isSubmitLoading = false;
        // });
        return;
      }

      Wallet wallet;
      String mnemonic;
      if (widget.isCreateWallet) {
        mnemonic = await WalletUtil.makeMnemonic();
        if (mnemonic != null && mnemonic.isNotEmpty) {
          wallet = await WalletUtil.storeByMnemonic(
              name: _walletNameController.text,
              password: _walletPswController.text,
              mnemonic: mnemonic);
        } else {
          Fluttertoast.showToast(msg: S.of(context).wallet_identity_creation_failed);
        }
      } else {
        mnemonic = _mnemonicController.text.trim();

        ///
        List<String> words = mnemonic.split(' ');
        String trimStr = '';
        List<String> trimWords = List();

        words.forEach((element) {
          if (element.isNotEmpty) {
            var trimWord = element.trim();

            trimWords.add(trimWord);
            trimStr = trimStr + ' ' + trimWord;
          }
        });
        if (trimWords.length < 12) {
          Fluttertoast.showToast(msg: '助记词数量小于12');
          return;
        }

        mnemonic = trimStr.trim();

        if (!bip39.validateMnemonic(mnemonic)) {
          Fluttertoast.showToast(msg: S.of(context).illegal_mnemonic);
          return;
        }

        var seed = bip39.mnemonicToSeed(mnemonic);
        var hdWallet = bitWallet.HDWallet.fromSeed(seed, network: bitWallet.bitcoin);
        var ethWallet = hdWallet.derivePath("m/44'/60'/0'/0/0");
        var address = ethereumAddressFromPublicKey(hex.decode(ethWallet.pubKey));
        var walletList = await WalletUtil.scanWallets();
        bool hasSame = false;
        walletList.forEach((element) {
          if (element.getEthAccount().address == address) {
            Fluttertoast.showToast(msg: S.of(context).wallet_already_exists);
            hasSame = true;
          }
        });
        if (hasSame) {
          return;
        }

        wallet = await WalletUtil.storeByMnemonic(
            name: _walletNameController.text,
            password: _walletPswController.text,
            mnemonic: mnemonic);
      }

      ///save expand info
      WalletExpandInfoEntity walletExpandInfoEntity = WalletExpandInfoEntity(userImageLocalPath,
          userImagePath, _walletPswHintController.text.trim(), !widget.isCreateWallet);
      wallet.walletExpandInfoEntity = walletExpandInfoEntity;
      BlocProvider.of<WalletCmpBloc>(context).add(ActiveWalletEvent(wallet: wallet));

      ///Clear exchange account when switch wallet
      BlocProvider.of<ExchangeCmpBloc>(context).add(ClearExchangeAccountEvent());
      await Future.delayed(Duration(milliseconds: 500)); //延时确保激活成功

      BlocProvider.of<WalletCmpBloc>(context)
          .add(UpdateWalletExpandEvent(wallet.getEthAccount().address, walletExpandInfoEntity));

      if (MemoryCache.rpInviteKey != null && widget.isCreateWallet) {
        RPApi _rpApi = RPApi();
        String inviteResult = await _rpApi.postRpInviter(MemoryCache.rpInviteKey, wallet);
        if (inviteResult != null) {
          Fluttertoast.showToast(msg: S.of(context).invitation_success);
          MemoryCache.rpInviteKey = null;
        }
      }

      await Future.delayed(Duration(milliseconds: 100), () {});
      BlocProvider.of<WalletCmpBloc>(context).add(UpdateActivatedWalletBalanceEvent());
      await Future.delayed(Duration(milliseconds: 100), () {});
      BlocProvider.of<WalletCmpBloc>(context).add(UpdateQuotesEvent());

      var userPayload = UserPayloadWithAddressEntity(
        Payload(userName: wallet.keystore.name, userPic: userImagePath),
        wallet.getAtlasAccount().address,
      );
      AtlasApi.postUserSync(userPayload);

      await Future.delayed(Duration(milliseconds: 3000), () {
        // setState(() {
        //   isSubmitLoading = false;
        // });
        Fluttertoast.showToast(
            msg: widget.isCreateWallet
                ? S.of(context).create_success
                : S.of(context).import_success);
        Routes.popUntilCachedEntryRouteName(context, wallet);
        if (widget.isCreateWallet) {
          var walletStr = FluroConvertUtils.object2string(wallet.toJson());
          Application.router.navigateTo(context,
              Routes.wallet_setting_wallet_backup_notice + '?walletStr=$walletStr&hasLater=1');
        }
      }); //延时确保激活成功
    } catch (error, stack) {
      // setState(() {
      //   isSubmitLoading = false;
      // });
      print("!!!! $error $stack");
      LogUtil.toastException("$error");
    }
  }
}

List<Widget> pswListWidget(
    bool isShowPsw,
    Function pswValiCall,
    TextEditingController _walletPswController,
    FocusNode _focusNode,
    String pswLevelLabel,
    String pswLevelImage,
    bool isShowRemind,
    TextEditingController _walletRePswController,
    Function showPswCall,
    TextEditingController _walletPswHintController) {
  return [
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
                obscureText: !isShowPsw,
                keyboardType: TextInputType.visiblePassword,
                validator: (value) {
                  return pswValiCall(value);
                  /*if (value.isEmpty) {
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
                  }*/
                },
                controller: _walletPswController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: S.of(Keys.rootKey.currentContext).password,
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
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      pswLevelLabel,
                      style: TextStyle(color: HexColor("#E7BB00"), fontSize: 14),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Image.asset(
                      pswLevelImage,
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
    if (isShowRemind)
      Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10, top: 4),
        child: Text(
          S.of(Keys.rootKey.currentContext).no_less_eight_recommend_mix,
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
                  obscureText: !isShowPsw,
                  keyboardType: TextInputType.visiblePassword,
                  validator: (value) {
                    if (value.isEmpty) {
                      return S.of(Keys.rootKey.currentContext).please_input_pwd;
                    } else if (value.length < 8) {
                      return S.of(Keys.rootKey.currentContext).password_less_than_eight;
                    } else if (_walletPswController.text != _walletRePswController.text) {
                      return S.of(Keys.rootKey.currentContext).password_not_equal_hint;
                    } else {
                      return null;
                    }
                  },
                  controller: _walletRePswController,
                  decoration: InputDecoration(
                    hintText: S.of(Keys.rootKey.currentContext).repeat_password,
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
                    showPswCall();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 5, bottom: 5),
                    child: Image.asset(
                      isShowPsw
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
            controller: _walletPswHintController,
            decoration: InputDecoration(
              hintText: S.of(Keys.rootKey.currentContext).password_reminder_optional,
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
  ];
}

String pswLevelLabel(int _pswLevel) {
  switch (_pswLevel) {
    case 0:
    case 1:
      return S.of(Keys.rootKey.currentContext).weak;
    case 2:
      return S.of(Keys.rootKey.currentContext).wallet_setting_normal;
    case 3:
      return S.of(Keys.rootKey.currentContext).strong;
    case 4:
      return S.of(Keys.rootKey.currentContext).well;
    default:
      return S.of(Keys.rootKey.currentContext).weak;
  }
}

String pswLevelImage(int _pswLevel) {
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
