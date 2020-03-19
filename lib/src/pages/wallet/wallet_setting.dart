import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/wallet/service/wallet_service.dart';
import 'package:titan/src/pages/wallet/wallet_backup_notice_page.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:titan/src/plugins/wallet/keystore.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/widget/enter_wallet_password.dart';


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

  @override
  void initState() {
    super.initState();
    _walletKeyStore = widget.wallet.keystore;
    _walletNameController.text = _walletKeyStore.name;
//    _walletService = WalletService(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          S.of(context).wallet_setting,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: <Widget>[
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
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: TextFormField(
                  enabled: false,
                  controller: _walletNameController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return S.of(context).please_input_wallet_name;
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                var walletStr = FluroConvertUtils.object2string(widget.wallet.toJson());
                Application.router.navigateTo(
                    context, Routes.wallet_setting_wallet_backup_notice + '?entryRouteName=${Uri.encodeComponent(Routes.wallet_setting)}&walletStr=$walletStr');
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
//            Container(
//              margin: EdgeInsets.symmetric(vertical: 36, horizontal: 36),
//              constraints: BoxConstraints.expand(height: 48),
//              child: RaisedButton(
//                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//                disabledColor: Colors.grey[600],
//                color: Theme.of(context).primaryColor,
//                textColor: Colors.white,
//                disabledTextColor: Colors.white,
//                onPressed: () {},
//                child: Padding(
//                  padding: const EdgeInsets.all(8.0),
//                  child: Row(
//                    mainAxisAlignment: MainAxisAlignment.center,
//                    children: <Widget>[
//                      Text(
//                        "保存",
//                        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
//                      ),
//                    ],
//                  ),
//                ),
//              ),
//            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 16, horizontal: 36),
              constraints: BoxConstraints.expand(height: 48),
              child: RaisedButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                disabledColor: Colors.grey[600],
                color: Color(0xFF9B9B9B),
                textColor: Colors.white,
                disabledTextColor: Colors.white,
                onPressed: () {
                  showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (BuildContext context) {
                        return EnterWalletPasswordWidget();
                      }).then((walletPassword) async {
                    print("walletPassword:$walletPassword");
                    if (walletPassword == null) {
                      return;
                    }

                    try {
                      var result = await widget.wallet.delete(walletPassword);
                      print("del result ${widget.wallet.keystore.fileName} $result");
                      if (result) {
                        List<Wallet> walletList = await WalletUtil.scanWallets();
                        var activatedWalletVo = WalletInheritedModel.of(context, aspect: WalletAspect.activatedWallet);

                        if(activatedWalletVo.activatedWallet.wallet.keystore.fileName
                            == widget.wallet.keystore.fileName && walletList.length > 0){//delete current wallet
                          BlocProvider.of<WalletCmpBloc>(context).add(ActiveWalletEvent(wallet: walletList[0]));
                          Routes.popUntilCreateOrImportWalletEntryRoute(context);
                        }else if(walletList.length > 0){//delete other wallet
//                          BlocProvider.of<WalletCmpBloc>(context).add(ActiveWalletEvent(wallet: activatedWalletVo.activatedWallet.wallet));
                          Routes.popUntilCreateOrImportWalletEntryRoute(context);
                        }else{//no wallet
                          BlocProvider.of<WalletCmpBloc>(context).add(ActiveWalletEvent(wallet: null));
                          Routes.popUntilCreateOrImportWalletEntryRoute(context);
                        }
                        Fluttertoast.showToast(msg: S.of(context).delete_wallet_success);
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
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        S.of(context).delete,
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
    );
  }
}
