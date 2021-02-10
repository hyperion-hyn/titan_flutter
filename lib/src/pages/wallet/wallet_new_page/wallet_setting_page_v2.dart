import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/components/exchange/bloc/bloc.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/components/wallet/wallet_repository.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_option_edit_page.dart';
import 'package:titan/src/pages/atlas_map/entity/pledge_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/user_payload_with_address_entity.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/pages/bio_auth/bio_auth_options_page.dart';
import 'package:titan/src/pages/wallet/wallet_new_page/wallet_modify_psw_page.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/auth_util.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/keyboard/wallet_password_dialog.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

typedef TextChangeCallback = void Function(String text);

class WalletSettingPageV2 extends StatefulWidget {
  final Wallet wallet;

  WalletSettingPageV2(this.wallet);

  @override
  State<StatefulWidget> createState() {
    return _WalletSettingPageV2State();
  }
}

class _WalletSettingPageV2State extends State<WalletSettingPageV2> with RouteAware {
  bool isBackup = false;
  BuildContext dialogContext;
  AtlasApi _atlasApi = AtlasApi();
  WalletRepository _walletRepository = WalletRepository();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didPush() {
    isBackup = widget.wallet.walletExpandInfoEntity?.isBackup ?? false;
  }

  @override
  void didPopNext() async {
    var walletExpandInfoEntity = await WalletUtil.getWalletExpandInfo(widget.wallet.getEthAccount().address);
    widget.wallet.walletExpandInfoEntity?.isBackup = walletExpandInfoEntity?.isBackup;
    isBackup = walletExpandInfoEntity?.isBackup ?? false;
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Application.routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    Application.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        backgroundColor: Colors.white,
        baseTitle: S.of(context).my_wallet_id,
      ),
      body: Container(
        color: DefaultColors.colorf2f2f2,
        child: CustomScrollView(
          slivers: [
            _basicInfoOptions(),
            // _addressList(),
            _securityOptions(),
            SliverToBoxAdapter(
              child: Container(
                color: HexColor("#F6F6F6"),
                height: 10,
              ),
            ),
            _confirmAction()
          ],
        ),
      ),
    );
  }

  _basicInfoOptions() {
    return _section(
        S.of(context).identity_information,
        Column(
          children: [
            InkWell(
              onTap: () {

                editIconSheet(context, (path) async {
                  if (path != null) {
                    UiUtil.showLoadingDialog(context, S.of(context).avatar_uploading, (context) {
                      dialogContext = context;
                    });

                    var netImagePath = await _atlasApi.postUploadImageFile(
                      "0x",
                      path,
                      (count, total) {},
                    );
                    if (netImagePath != null && netImagePath.isNotEmpty) {
                      widget.wallet.walletExpandInfoEntity.localHeadImg = path;
                      widget.wallet.walletExpandInfoEntity.netHeadImg = netImagePath;
                      BlocProvider.of<WalletCmpBloc>(context).add(UpdateWalletExpandEvent(
                          widget.wallet.getEthAccount().address,
                          widget.wallet.walletExpandInfoEntity));
                      postUserSync();
                      setState(() {});
                    } else {
                      Fluttertoast.showToast(msg: S.of(context).scan_upload_error);
                    }
                    if (dialogContext != null) {
                      Navigator.pop(dialogContext);
                    }
                    return;
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 16.0),
                child: Row(
                  children: [
                    Text(
                      S.of(context).avatar,
                      style: TextStyles.textC333S14,
                    ),
                    Spacer(),
                    iconWalletWidget(widget.wallet, isCircle: true),
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Icon(
                        Icons.chevron_right,
                        color: DefaultColors.color999,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              height: 0.5,
            ),
            InkWell(
              onTap: () async {
                var password = await UiUtil.showWalletPasswordDialogV2(context, widget.wallet);
                if (password == null) {
                  return;
                }
                String text = await Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => OptionEditPage(
                          title: S.of(context).name,
                          content: widget.wallet?.keystore?.name,
                          maxLength: 8,
                        )));
                if (text != null && text.isNotEmpty) {
                  widget.wallet?.keystore?.name = text;
                  var success = await WalletUtil.updateWallet(
                      wallet: widget.wallet, password: password, name: text);
                  if (success == true) {
                    var wallet = WalletInheritedModel.of(context).activatedWallet.wallet;
                    if(wallet.getEthAccount().address == widget.wallet.getEthAccount().address){
                      BlocProvider.of<WalletCmpBloc>(context).add(ActiveWalletEvent(wallet: widget.wallet));
                    }
                    UiUtil.toast(S.of(context).update_success);
                    postUserSync();
                  }

                  setState(() {});
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 16.0),
                child: Row(
                  children: [
                    Text(
                      S.of(context).name,
                      style: TextStyles.textC333S14,
                    ),
                    Spacer(),
                    Text(
                      widget.wallet.keystore.name,
                      style: TextStyles.textC999S14,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Icon(
                        Icons.chevron_right,
                        color: DefaultColors.color999,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ));
  }

  _addressList() {
    var addressItem = (String chain, String address, List<Color> bgColors) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          gradient: LinearGradient(
            colors: bgColors,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chain,
                style: TextStyle(
                    fontSize: 16, color: DefaultColors.color333, fontWeight: FontWeight.w500),
              ),
              Text(
                address,
                style: TextStyle(fontSize: 10, color: DefaultColors.color333.withOpacity(0.6)),
              ),
            ],
          ),
        ),
      );
    };

    return _section(
        S.of(context).wallet_main_chain,
        Column(
          children: [
            addressItem(
              'HYN',
              'sdfsdf',
              [HexColor('#F7D33D'), HexColor('#EDC313')],
            ),
            SizedBox(height: 12),
            addressItem(
              'BTC',
              'sdfsdfassdf',
              [HexColor('#F7A43F'), HexColor('#F7A43F')],
            ),
            SizedBox(height: 12),
            addressItem(
              'ETH',
              'sdfsdf',
              [HexColor('#65AAD0'), HexColor('#65AAD0')],
            )
          ],
        ));
  }

  _securityOptions() {
    return _section(
        S.of(context).safety,
        Column(
          children: [
            _optionItem(
                imagePath: "res/drawable/ic_wallet_setting_show_mnemonic.png",
                title: S.of(context).show_mnemonic_label,
                editFunc: () {
                  var walletStr = FluroConvertUtils.object2string(widget.wallet.toJson());
                  Application.router.navigateTo(
                      context,
                      Routes.wallet_setting_wallet_backup_notice +
                          '?entryRouteName=${Uri.encodeComponent(Routes.wallet_setting)}&walletStr=$walletStr');
                },
                subContent: S.of(context).private_data_stored_device_not_retrieved,
                warning: !isBackup ? S.of(context).not_backup : ""),
            Divider(
              height: 0.5,
            ),
            FutureBuilder(
                future: BioAuthUtil.checkBioAuthAvailable(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    bool isBioAuthAvailable = snapshot.data;
                    if (isBioAuthAvailable) {
                      return _optionItem(
                        imagePath: "res/drawable/ic_wallet_setting_bio_auth.png",
                        title: S.of(context).biometric_verification,
                        editFunc: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BioAuthOptionsPage(widget.wallet)));
                        },
                      );
                    }
                  }
                  return SizedBox();
                }),
            Divider(
              height: 0.5,
            ),
            _optionItem(
                imagePath: "res/drawable/ic_wallet_setting_modify_pws.png",
                title: S.of(context).change_password,
                editCallback: (text) {},
                editFunc: () async {
                  String pswRemind = await Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => WalletModifyPswPage(widget.wallet)));
                  if (pswRemind != null && pswRemind.isNotEmpty) {
                    setState(() {
                      widget.wallet.walletExpandInfoEntity.pswRemind = pswRemind;
                    });
                  }
                }),
            Divider(
              height: 0.5,
            ),
            _optionItem(
              imagePath: "res/drawable/ic_wallet_setting_psw_remind.png",
              title: S.of(context).pwd_hint,
              editFunc: () async {
                var password = await UiUtil.showWalletPasswordDialogV2(context, widget.wallet);
                if (password == null) {
                  return;
                }

                String text = await Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => OptionEditPage(
                      title: S.of(context).pwd_hint,
                      content: widget.wallet.walletExpandInfoEntity?.pswRemind,
                      hint: widget.wallet?.walletExpandInfoEntity?.pswRemind == null ? S.of(context).not_set : "",
                      keyboardType: TextInputType.text,
                      maxLength: 8,
                    )));
                if (text != null && text.isNotEmpty) {
                  widget.wallet.walletExpandInfoEntity.pswRemind = text;
                  BlocProvider.of<WalletCmpBloc>(context).add(UpdateWalletExpandEvent(
                  widget.wallet.getEthAccount().address, widget.wallet.walletExpandInfoEntity));
                  setState(() {
                  });
                }
                return;

              },
            ),
          ],
        ));
  }

  _confirmAction() {
    return _section(
        '',
        InkWell(
          onTap: () {
            UiUtil.showBottomDialogView(context,
                imagePath: "res/drawable/ic_wallet_setting_delete_account.png",
                dialogTitle: S.of(context).exit_identity,
                dialogSubTitle: S.of(context).wallet_deleted_after_out_backup,
                imageHeight: 66,
                showCloseBtn: isBackup,
                actions: [
                  if (isBackup)
                    ClickOvalButton(
                      S.of(context).confirm_exit,
                      () async {
                        Navigator.pop(context);
                        deleteWallet();
                      },
                      width: 300,
                      height: 44,
                      btnColor: [HexColor("#FF4B4B")],
                      fontSize: 16,
                    ),
                  if (!isBackup)
                    ClickOvalButton(
                      S.of(context).cancel,
                      () async {
                        Navigator.pop(context);
                      },
                      width: 140,
                      height: 40,
                      fontColor: DefaultColors.color999,
                      btnColor: [HexColor("#F2F2F2")],
                      fontSize: 16,
                    ),
                  if (!isBackup)
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: ClickOvalButton(
                        //S.of(context).go_to_backup,
                        // todo: jison
                        S.of(context).confirm_exit,
                      () async {
                          Navigator.pop(context);

                          deleteWallet();

                          // var walletStr = FluroConvertUtils.object2string(widget.wallet.toJson());
                          // Application.router.navigateTo(
                          //     context,
                          //     Routes.wallet_setting_wallet_backup_notice +
                          //         '?entryRouteName=${Uri.encodeComponent(Routes.wallet_setting)}&walletStr=$walletStr');
                        },
                        width: 140,
                        height: 40,
                        fontColor: DefaultColors.color333,
                        btnColor: [
                          HexColor("#F7D33D"),
                          HexColor("#E7C01A"),
                        ],
                        fontSize: 16,
                      ),
                    ),
                ]);
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 15, bottom: 15),
            child: Center(
              child: Text(
                S.of(context).exit,
                style: TextStyle(
                  color: HexColor('#FF001B'),
                ),
              ),
            ),
          ),
        ));
  }

  Future<void> deleteWallet() async {
    CheckPwdValid onCheckPwdValid = (walletPwd) async{
      // todo: jison
      return true;

      return WalletUtil.checkPwdValid(
        context,
        widget.wallet,
        walletPwd,
      );
    };
    var walletPassword = await UiUtil.showPasswordDialog(context, widget.wallet,
        isShowBioAuthIcon: false,
        onCheckPwdValid: onCheckPwdValid,
        remindStr: S.of(context).warning_no_backup_cannot_retrieved);
    if (walletPassword == null) {
      return;
    }

    try {
      var result = await widget.wallet.delete(walletPassword);
      print("del result ${widget.wallet.keystore.fileName} $result");
      if (result) {
        await AppCache.remove(widget.wallet.getBitcoinAccount()?.address ?? "");
        await WalletUtil.setWalletExpandInfo(widget.wallet.getEthAccount()?.address, null);
        List<Wallet> walletList = await WalletUtil.scanWallets();
        var activatedWalletVo =
            WalletInheritedModel.of(context, aspect: WalletAspect.activatedWallet);

        if (activatedWalletVo.activatedWallet.wallet.keystore.fileName ==
                widget.wallet.keystore.fileName &&
            walletList.length > 0) {
          //delete current wallet

          _walletRepository.saveActivatedWalletFileName(walletList[0].keystore.fileName);
          BlocProvider.of<WalletCmpBloc>(context).add(ActiveWalletEvent(wallet: walletList[0]));
          await Future.delayed(Duration(milliseconds: 500)); //延时确保激活成功
          Routes.popUntilCachedEntryRouteName(context);
        } else if (walletList.length > 0) {
          //delete other wallet

          Routes.popUntilCachedEntryRouteName(context);
        } else {
          //no wallet

          Routes.cachedEntryRouteName = null;
          _walletRepository.saveActivatedWalletFileName(null);
          BlocProvider.of<WalletCmpBloc>(context).add(ActiveWalletEvent(wallet: null));
          await Future.delayed(Duration(milliseconds: 500)); //延时确保激活成功
          Routes.popUntilCachedEntryRouteName(context);
        }
        Fluttertoast.showToast(msg: S.of(context).delete_wallet_success);

        ///log out exchange account
        BlocProvider.of<ExchangeCmpBloc>(context).add(ClearExchangeAccountEvent());
      } else {
        Fluttertoast.showToast(msg: S.of(context).delete_wallet_fail);
      }
    } catch (_) {
      LogUtil.toastException(_);
    }
  }

  _section(String title, Widget child) {
    return SliverToBoxAdapter(
      child: Container(
        child: Column(
          children: [
            title.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.only(
                      top: 20,
                      bottom: 10,
                      left: 16,
                      right: 16,
                    ),
                    child: Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            color: DefaultColors.color999,
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox(),
            Container(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16),
                child: child,
              ),
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  _optionItem({
    String imagePath,
    String title,
    String editHint = '',
    String content,
    bool isCanEdit = false,
    Function editFunc,
    TextChangeCallback editCallback,
    TextInputType keyboardType = TextInputType.text,
    String subContent = '',
    String warning = '',
  }) {
    return InkWell(
      onTap: () async {
        if (isCanEdit) {
          String text = await Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => OptionEditPage(
                    title: title,
                    content: content,
                    hint: editHint,
                    keyboardType: keyboardType,
                    maxLength: 8,
                  )));
          if (text != null && text.isNotEmpty) {
            setState(() {
              editCallback(text);
            });
          }
          return;
        }
        if (editFunc != null) {
          editFunc();
          return;
        }
      },
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  imagePath,
                  width: 20,
                  height: 20,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: HexColor("#333333"),
                    fontSize: 14,
                  ),
                ),
                Spacer(),
                if (warning.isNotEmpty)
                  Row(
                    children: [
                      Image.asset(
                        'res/drawable/ic_warning_triangle_v2.png',
                        width: 15,
                        height: 15,
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          warning,
                          style: TextStyle(color: HexColor('#E7BB00'), fontSize: 14),
                        ),
                      )
                    ],
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Icon(
                    Icons.chevron_right,
                    color: DefaultColors.color999,
                  ),
                ),
              ],
            ),
            if (subContent.isNotEmpty)
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 27.0),
                    child: Text(
                      subContent,
                      style: TextStyle(color: HexColor("#999999"), fontSize: 12),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void postUserSync() {
    var userPayload = UserPayloadWithAddressEntity(
      Payload(
        userName: widget.wallet.keystore.name,
        userPic: widget.wallet.walletExpandInfoEntity.netHeadImg,
      ),
      widget.wallet.getAtlasAccount().address,
    );
    AtlasApi.postUserSync(userPayload);
  }
}
