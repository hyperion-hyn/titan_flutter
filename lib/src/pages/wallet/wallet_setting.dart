import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/components/auth/auth_component.dart';
import 'package:titan/src/components/auth/bloc/auth_bloc.dart';
import 'package:titan/src/components/auth/bloc/auth_event.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/pages/mine/auth_setting_page.dart';
import 'package:titan/src/plugins/wallet/keystore.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/auth_dialog/SetBioAuthDialog.dart';
import 'package:titan/src/widget/auth_dialog/bio_auth_dialog.dart';
import 'package:titan/src/widget/enter_wallet_password.dart';
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

//  WalletService _walletService;

  String _originWalletName;
  bool _hasChangeProperties = false;

  FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _walletKeyStore = widget.wallet.keystore;
    _walletNameController.text = _walletKeyStore.name;
    _originWalletName = _walletKeyStore.name;
//    _walletService = WalletService(context: context);

    _focusNode = FocusNode();
//    _focusNode.addListener(() {
//      if (_focusNode.hasFocus) _textFieldController.clear();
//    });

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
  }

  @override
  void dispose() {
    _walletNameController.dispose();
    super.dispose();
  }

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
            onPressed: deleteWallet,
            child: Text(
              S.of(context).delete,
              style: TextStyle(color: Colors.black),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 24),
                    child: Stack(
                      children: <Widget>[
                        walletHeaderWidget(
                            widget.wallet.keystore.name.characters.first,
                            size: 64,
                            fontSize: 20,
                            address: widget.wallet.getEthAccount()?.address),
//                      Positioned(
//                          right: 6,
//                          bottom: 6,
//                          child: Image.asset(
//                            'res/drawable/ic_edit.png',
//                            height: 12,
//                          )),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        S.of(context).wallet_name,
                        style: TextStyle(
                          color: Color(0xFF6D6D6D),
                          fontSize: 16,
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                    child: TextFormField(
                        enabled: true,
                        focusNode: _focusNode,
                        controller: _walletNameController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return S.of(context).please_input_wallet_name;
                          } else {
                            return null;
                          }
                        },
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(6),
                        ],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30)),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                        keyboardType: TextInputType.text),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        S.of(context).backup_option,
                        style: TextStyle(
                          color: Color(0xFF6D6D6D),
                          fontSize: 16,
                        ),
                      )
                    ],
                  ),
                  Divider(),
                  InkWell(
                    onTap: () {
                      var walletStr = FluroConvertUtils.object2string(
                          widget.wallet.toJson());
                      Application.router.navigateTo(
                          context,
                          Routes.wallet_setting_wallet_backup_notice +
                              '?entryRouteName=${Uri.encodeComponent(Routes.wallet_setting)}&walletStr=$walletStr');
//                Navigator.push(
//                    context, MaterialPageRoute(builder: (context) => WalletBackupNoticePage(widget.wallet)));
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
                  SizedBox(
                    height: 36,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    constraints: BoxConstraints.expand(height: 44),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
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
                              '保存更新',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal, fontSize: 16),
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

  void updateWalletV2() async {
    String password = await UiUtil.showWalletPasswordDialogV2(
      context,
      widget.wallet.getEthAccount().address,
    );
    if (password != null) {
      try {
        var newName = _walletNameController.text;
        if (_focusNode.hasFocus) {
          _focusNode.unfocus();
        }
        var success = await WalletUtil.updateWallet(
            wallet: widget.wallet, password: password, name: newName);
        if (success == true) {
          BlocProvider.of<WalletCmpBloc>(context)
              .add(ActiveWalletEvent(wallet: widget.wallet));
          UiUtil.toast('更新成功');
          if (AuthInheritedModel.of(context).showSetBioAuthDialog) {
            UiUtil.showSetBioAuthDialog(
              context,
              '更新成功',
              widget.wallet.getEthAccount().address,
              password,
            );
          }
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
          UiUtil.toast('更新出错');
        }
      }
    }
  }

  Future<void> deleteWallet() async {
    var walletPassword = await UiUtil.showWalletPasswordDialogV2(
      context,
      widget.wallet.getEthAccount().address,
    );
    print("walletPassword:$walletPassword");
    if (walletPassword == null) {
      return;
    }

    try {
      var result = await widget.wallet.delete(walletPassword);
      print("del result ${widget.wallet.keystore.fileName} $result");
      if (result) {
        AppCache.remove(widget.wallet.getBitcoinAccount().address);
        List<Wallet> walletList = await WalletUtil.scanWallets();
        var activatedWalletVo = WalletInheritedModel.of(context,
            aspect: WalletAspect.activatedWallet);

        if (activatedWalletVo.activatedWallet.wallet.keystore.fileName ==
                widget.wallet.keystore.fileName &&
            walletList.length > 0) {
          //delete current wallet
          BlocProvider.of<WalletCmpBloc>(context)
              .add(ActiveWalletEvent(wallet: walletList[0]));
          Routes.popUntilCachedEntryRouteName(context);
        } else if (walletList.length > 0) {
          //delete other wallet
//                          BlocProvider.of<WalletCmpBloc>(context).add(ActiveWalletEvent(wallet: activatedWalletVo.activatedWallet.wallet));
          Routes.popUntilCachedEntryRouteName(context);
        } else {
          //no wallet
          BlocProvider.of<WalletCmpBloc>(context)
              .add(ActiveWalletEvent(wallet: null));
          Routes.popUntilCachedEntryRouteName(context);
        }
        Fluttertoast.showToast(msg: S.of(context).delete_wallet_success);
        if (AuthInheritedModel.of(context).showSetBioAuthDialog) {
          UiUtil.showSetBioAuthDialog(
            context,
            S.of(context).delete_wallet_success,
            widget.wallet.getEthAccount().address,
            walletPassword,
          );
        }
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
}
