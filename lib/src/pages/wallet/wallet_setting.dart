import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/pledge_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/user_payload_with_address_entity.dart';
import 'package:titan/src/pages/bio_auth/bio_auth_options_page.dart';
import 'package:titan/src/components/auth/auth_component.dart';
import 'package:titan/src/components/exchange/bloc/bloc.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/wallet/keystore.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/wallet_widget.dart';
import 'package:characters/characters.dart';

class WalletSettingPage extends StatefulWidget {
  final Wallet wallet;

  WalletSettingPage(this.wallet);

  @override
  State<StatefulWidget> createState() {
    return _WalletSettingState();
  }
}

class _WalletSettingState extends State<WalletSettingPage> {
  TextEditingController _walletNameController = TextEditingController();

  KeyStore _walletKeyStore;

  String _originWalletName;
  bool _hasChangeProperties = false;

  FocusNode _focusNode;
  String _imageSource = '';
  String get _address => widget.wallet.getAtlasAccount().address;

  @override
  void initState() {
    super.initState();

    _setupData();
  }

  void _setupData() async {
    _walletKeyStore = widget.wallet.keystore;
    _walletNameController.text = _walletKeyStore.name;
    _originWalletName = _walletKeyStore.name;
    _focusNode = FocusNode();

    _walletNameController.addListener(() {
      if (_hasChangeProperties != true) {
        if (_originWalletName != _walletNameController.text) {
          setState(() {
            _hasChangeProperties = true;
          });
        }
      } else {
        if (_originWalletName == _walletNameController.text) {
          setState(() {
            _hasChangeProperties = false;
          });
        }
      }
    });

    var localImageSource = await AppCache.getValue(PrefsKey.WALLET_ICON_LAST_KEY);
    if (mounted) {
      setState(() {
        _imageSource = jsonDecode(localImageSource);
      });
    }
  }

  @override
  void dispose() {
    _walletNameController.dispose();
    super.dispose();
  }

  final _walletNameKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          S.of(context).wallet_setting,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: _showDeleteDialog,
            child: Text(
              S.of(context).delete,
              style: TextStyle(color: HexColor('#FF999999')),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // hide keyboard when touch other widgets
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          height: double.infinity,
          color: Colors.white,
          child: SingleChildScrollView(
            child: Form(
              key: _walletNameKey,
              child: Column(
                children: <Widget>[
                  InkWell(
                    onTap: _editIconAction,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 36),
                      child: Stack(
                        children: <Widget>[
                          walletHeaderIconWidget(
                            widget.wallet.keystore.name.isEmpty ? "" : widget.wallet.keystore.name.characters.first,
                            size: 64,
                            fontSize: 20,
                            address: widget.wallet.getEthAccount()?.address,
                            imageSource: _imageSource,
                          ),
                          Positioned(
                              right: 6,
                              bottom: 6,
                              child: Image.asset(
                                'res/drawable/ic_edit.png',
                                height: 12,
                              )),
                        ],
                      ),
                    ),
                  ),
                  _divider(),
                  _walletInfo(),
                  _divider(),
                  _bioAuthOptions(),
                  _backUpOptions(),
                  SizedBox(
                    height: 36,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    constraints: BoxConstraints.expand(height: 44),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      disabledColor: Colors.grey[600],
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      disabledTextColor: Colors.white,
                      onPressed: _hasChangeProperties ? updateWalletV2 : null,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              S.of(context).save_update,
                              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _divider() {
    return Container(
      height: 8,
      color: HexColor('#FFF5F5F5'),
    );
  }

  _walletInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            S.of(context).wallet_name,
            style: TextStyle(
              color: HexColor('#FF333333'),
              fontSize: 16,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
            child: TextFormField(
                enabled: true,
                focusNode: _focusNode,
                controller: _walletNameController,
                validator: (value) {
                  if (value.isEmpty) {
                    return S.of(context).please_input_wallet_name;
                  } else if (value.contains(' ')) {
                    return S.of(context).wallet_name_do_not_contain_space;
                  } else {
                    return null;
                  }
                },
                inputFormatters: [
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                keyboardType: TextInputType.text),
          ),
          Divider(),
          SizedBox(
            height: 8,
          ),
          Builder(
            builder: (BuildContext context) {
              return GestureDetector(
                onTap: () {
                  if (widget.wallet.getEthAccount().address.isNotEmpty) {
                    Clipboard.setData(ClipboardData(
                        text: WalletUtil.ethAddressToBech32Address(
                      widget.wallet.getEthAccount().address,
                    )));
                    Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text(
                      S.of(context).wallet_address_copied,
                    )));
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          S.of(context).wallet_address,
                          style: TextStyle(
                            color: HexColor('#FF333333'),
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        Image.asset(
                          'res/drawable/ic_copy.png',
                          height: 18,
                          width: 18,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      WalletUtil.ethAddressToBech32Address(
                        widget.wallet.getEthAccount().address,
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: HexColor('#FF999999'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  _bioAuthOptions() {
    if (AuthInheritedModel.of(context).bioAuthAvailable) {
      return Column(
        children: <Widget>[
          Container(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => BioAuthOptionsPage(widget.wallet)));
                },
                child: Row(
                  children: <Widget>[
                    Text(S.of(context).face_fingerprint_password),
                    Spacer(),
                    Icon(
                      Icons.chevron_right,
                      color: Color(0xFFD2D2D2),
                    )
                  ],
                ),
              ),
            ),
          ),
          _divider(),
        ],
      );
    } else {
      return SizedBox();
    }
  }

  _backUpOptions() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                S.of(context).backup_option,
                style: TextStyle(
                  color: HexColor('#FF333333'),
                  fontSize: 16,
                ),
              )
            ],
          ),
          Divider(),
          InkWell(
            onTap: () {
              var walletStr = FluroConvertUtils.object2string(widget.wallet.toJson());
              Application.router.navigateTo(
                  context,
                  Routes.wallet_setting_wallet_backup_notice +
                      '?entryRouteName=${Uri.encodeComponent(Routes.wallet_setting)}&walletStr=$walletStr');
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.event_note,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Text(
                    S.of(context).show_mnemonic_label,
                    style: TextStyle(fontSize: 16),
                  ),
                  Spacer(),
                  Icon(
                    Icons.chevron_right,
                    color: Color(0xFFD2D2D2),
                  )
                ],
              ),
            ),
          ),
          Divider(),
          Text(
            S.of(context).wallet_setting_backup_notice,
            style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 13),
          ),
        ],
      ),
    );
  }

  void updateWalletV2() async {
    if (!_walletNameKey.currentState.validate()) {
      UiUtil.toast(S.of(context).please_input_wallet_name);
      return;
    }

    var newName = _walletNameController.text;

    /*if (newName.isEmpty || newName == "null" || newName == null) {
      UiUtil.toast("钱包名称不能为空");
      return;
    }
    */

    var password = await UiUtil.showWalletPasswordDialogV2(context, widget.wallet);
    if (password != null) {
      try {
        if (_focusNode.hasFocus) {
          _focusNode.unfocus();
        }
        var success = await WalletUtil.updateWallet(wallet: widget.wallet, password: password, name: newName);
        if (success == true) {
          BlocProvider.of<WalletCmpBloc>(context).add(ActiveWalletEvent(wallet: widget.wallet));

          UiUtil.toast(S.of(context).update_success);

          postUserSync();
        }
        setState(() {
          _originWalletName = newName;
          _hasChangeProperties = false;
        });
      } catch (_) {
        logger.e(_);
        if (_.code == WalletError.PASSWORD_WRONG) {
          UiUtil.toast(S.of(context).wallet_password_error);
        } else {
          UiUtil.toast(S.of(context).update_error);
        }
      }
    }
  }

  _showDeleteDialog() {
    UiUtil.showDialogWidget(context,
        title: Text(S.of(context).dialog_title_delete_wallet_confirm),
        content: Text(S.of(context).dialog_content_delete_wallet_confirm),
        actions: [
          FlatButton(
              child: Text(S.of(context).cancel),
              onPressed: () async {
                Navigator.of(context).pop();
              }),
          FlatButton(
              child: Text(S.of(context).confirm),
              onPressed: () async {
                Navigator.of(context).pop();
                deleteWallet();
              })
        ]);
  }

  Future<void> deleteWallet() async {
    var walletPassword = await UiUtil.showWalletPasswordDialogV2(
      context,
      widget.wallet,
    );
    print("walletPassword:$walletPassword");
    if (walletPassword == null) {
      return;
    }

    try {
      var result = await widget.wallet.delete(walletPassword);
      print("del result ${widget.wallet.keystore.fileName} $result");
      if (result) {
        await AppCache.remove(widget.wallet.getBitcoinAccount()?.address ?? "");
        List<Wallet> walletList = await WalletUtil.scanWallets();
        var activatedWalletVo = WalletInheritedModel.of(context, aspect: WalletAspect.activatedWallet);

        if (activatedWalletVo.activatedWallet.wallet.keystore.fileName == widget.wallet.keystore.fileName &&
            walletList.length > 0) {
          //delete current wallet

          BlocProvider.of<WalletCmpBloc>(context)
              .add(ActiveWalletEvent(wallet: walletList[0]));
          await Future.delayed(Duration(milliseconds: 500));//延时确保激活成功

          Routes.popUntilCachedEntryRouteName(context);
        } else if (walletList.length > 0) {
          //delete other wallet
          Routes.popUntilCachedEntryRouteName(context);
        } else {
          //no wallet
          BlocProvider.of<WalletCmpBloc>(context).add(ActiveWalletEvent(wallet: null));
          Routes.cachedEntryRouteName = null;
          await Future.delayed(Duration(milliseconds: 500));//延时确保激活成功
          Routes.popUntilCachedEntryRouteName(context);
        }
        Fluttertoast.showToast(msg: S.of(context).delete_wallet_success);

        ///log out exchange account
        BlocProvider.of<ExchangeCmpBloc>(context).add(ClearExchangeAccountEvent());
      } else {
        Fluttertoast.showToast(msg: S.of(context).delete_wallet_fail);
      }
    } catch (_) {
      logger.e(_);
      if (_.code == WalletError.PASSWORD_WRONG) {
        Fluttertoast.showToast(msg: S.of(context).wallet_password_error);
      } else {
        Fluttertoast.showToast(msg: S.of(context).delete_wallet_fail);
      }
    }
  }

  _editIconAction() async {
    /*
    var result =
        'https://static.hyn.space/test/explore/0xa599CFEb7a04010CaABB7Cc924d2e1004cCB71A4/9632d1f559446ae9c5c5d55c191fb53c.jpeg';
    // 2.本地保存
    await AppCache.saveValue(PrefsKey.WALLET_ICON_LAST_KEY, json.encode(result));
    return;
    */

    String address = widget?.wallet?.getEthAccount()?.address ?? "";

    UiUtil.showIconImagePickerSheet(context, callback: (String picPath) async {
      print(
        '[$runtimeType] upload  ---> picPath:$picPath, _address:$address',
      );

      if (picPath?.isEmpty??true) {
        return;
      }

      var result = await AtlasApi().postUploadImageFile(
        address,
        picPath,
        (count, total) {
          print(
            '[$runtimeType] upload  ---> count:$count, total:$total',
          );
        },
      );

      print(
        '[$runtimeType] upload  ---> result:$result',
      );

      if (result?.isNotEmpty ?? false) {
        // 0.刷新UI
        if (mounted) {
          setState(() {
            _imageSource = result;
          });
        }

        // 1.同步
        postUserSync(userPic: result);

        // 2.本地保存
        await AppCache.saveValue(PrefsKey.WALLET_ICON_LAST_KEY, json.encode(result));
      }

    });
  }

  void postUserSync({String userPic = ''}) {
    var userName = widget.wallet.keystore.name;

    Payload payload;
    if (userPic?.isNotEmpty ?? false) {
      payload = Payload(userName: userName, userPic: userPic);
    } else {
      payload = Payload(
        userName: userName,
      );
    }
    var userPayload = UserPayloadWithAddressEntity(payload, _address);

    AtlasApi.postUserSync(userPayload);
  }
}
