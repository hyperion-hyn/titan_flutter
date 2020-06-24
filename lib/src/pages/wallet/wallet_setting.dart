import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_pickers/UIConfig.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/wallet/keystore.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/click_oval_button.dart';
import 'package:titan/src/widget/click_rectangle_button.dart';
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
  String localImagePath;

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
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          S.of(context).wallet_setting,
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: deleteWallet,
            child: Text(
              S.of(context).delete,
              style: TextStyle(color: HexColor("#ccffffff")),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: localImagePath != null ? ClipOval(child: Image.asset(localImagePath,width: 88,height: 88,fit: BoxFit.cover,)) : walletHeaderWidget(widget.wallet.keystore.name,
                        size: 88, fontSize: 26, address: widget.wallet.getEthAccount()?.address),
                  ),
                  InkWell(
                    onTap: (){
                      _openModalBottomSheet();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 29,top: 13),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Image.asset("res/drawable/ic_wallet_edit_head_img.png",width: 18,height: 18,),
                          SizedBox(width: 4,),
                          Text("修改头像",style: TextStyle(color: HexColor("#1F81FF"),fontSize: 16),)
                        ],
                      ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
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
                    constraints: BoxConstraints.expand(height: 46,width: 300),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
                      clipBehavior: Clip.hardEdge,
                      textColor: _hasChangeProperties ? Colors.white : DefaultColors.color999,
                      onPressed: _hasChangeProperties ? updateWallet : null,
                      padding: const EdgeInsets.all(0.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: getGradient(),
                        ),
                        child: Container(
                            alignment: Alignment.center,
                            child: Text('保存更新')),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient getGradient(){
    if(_hasChangeProperties){
      return LinearGradient(
        colors: <Color>[
          Color(0xff15B2D2),
          Color(0xff1097B4)
        ],
      );
    }else{
      return LinearGradient(
        colors: <Color>[
          Color(0xffDEDEDE),
          Color(0xffDEDEDE)
        ],
      );
    }
  }

  void updateWallet() async {
    var password = await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return EnterWalletPasswordWidget();
        });
    if (password != null) {
      try {
        var newName = _walletNameController.text;
        if (_focusNode.hasFocus) {
          _focusNode.unfocus();
        }
        var success = await WalletUtil.updateWallet(wallet: widget.wallet, password: password, name: newName);
        if (success == true) {
          BlocProvider.of<WalletCmpBloc>(context).add(ActiveWalletEvent(wallet: widget.wallet));
          UiUtil.toast('更新成功');
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

  Future _openModalBottomSheet() async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      builder: (BuildContext dialogContext) {
        return Container(
          height: 199,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 54,
                child: ListTile(
                  title: Text("拍照",textAlign: TextAlign.center,style: TextStyles.textC333S18,),
                  onTap: () async {
                    Future.delayed(Duration(milliseconds: 500),(){
                      Navigator.pop(dialogContext);
                    });

                    var tempListImagePaths = await ImagePickers.openCamera(
                      compressSize: 500,
                    );
                    if(tempListImagePaths != null){
                      setState(() {
                        localImagePath = tempListImagePaths.path;
                      });
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left:10.0,right: 10),
                child: Divider(height:1,color: DefaultColors.colorf2f2f2),
              ),
              SizedBox(
                height: 54,
                child: ListTile(
                  title: Text("从相册选择",textAlign: TextAlign.center,style: TextStyles.textC333S18),
                  onTap: () async {
                    Future.delayed(Duration(milliseconds: 500),(){
                      Navigator.pop(dialogContext);
                    });

                    var tempListImagePaths = await ImagePickers.pickerPaths(
                      galleryMode: GalleryMode.image,
                      selectCount: 1,
                      showCamera: true,
                      cropConfig: null,
                      compressSize: 500,
                      uiConfig: UIConfig(uiThemeColor: Color(0xff0f95b0)),
                    );
                    if(tempListImagePaths != null && tempListImagePaths.length == 1){
                      setState(() {
                        localImagePath = tempListImagePaths[0].path;
                      });
                    }
                  },
                ),
              ),
              Container(height: 10,color:DefaultColors.colorf4f4f4,),
//                Divider(color:DefaultColors.colorf4f4f4,height: 10,),
              ListTile(
                title: Text(S.of(context).cancel,textAlign: TextAlign.center,style: TextStyles.textC333S18),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              Expanded(child: Container(color:DefaultColors.colorf4f4f4,)),
            ],
          ),
        );
      },
    );
  }

  void deleteWallet() {
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
          AppCache.remove(widget.wallet.getBitcoinAccount().address);
          List<Wallet> walletList = await WalletUtil.scanWallets();
          var activatedWalletVo = WalletInheritedModel.of(context, aspect: WalletAspect.activatedWallet);

          if (activatedWalletVo.activatedWallet.wallet.keystore.fileName == widget.wallet.keystore.fileName &&
              walletList.length > 0) {
            //delete current wallet
            BlocProvider.of<WalletCmpBloc>(context).add(ActiveWalletEvent(wallet: walletList[0]));
            Routes.popUntilCachedEntryRouteName(context);
          } else if (walletList.length > 0) {
            //delete other wallet
//                          BlocProvider.of<WalletCmpBloc>(context).add(ActiveWalletEvent(wallet: activatedWalletVo.activatedWallet.wallet));
            Routes.popUntilCachedEntryRouteName(context);
          } else {
            //no wallet
            BlocProvider.of<WalletCmpBloc>(context).add(ActiveWalletEvent(wallet: null));
            Routes.popUntilCachedEntryRouteName(context);
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
  }
}
