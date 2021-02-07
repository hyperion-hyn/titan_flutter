import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/pages/wallet/wallet_new_page/wallet_create_import_account_page_v2.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_expand_info_entity.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/psw_strength/password_strength_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart' as all_page_state;

class WalletModifyPswPage extends StatefulWidget {
  final Wallet wallet;
  WalletModifyPswPage(this.wallet);

  @override
  State<StatefulWidget> createState() {
    return _WalletModifyPswPageState();
  }
}

class _WalletModifyPswPageState extends State<WalletModifyPswPage> {
  TextEditingController _walletOrignPswController = TextEditingController();
  TextEditingController _walletPswController = TextEditingController();
  TextEditingController _walletRePswController = TextEditingController();
  TextEditingController _walletPswHintController = TextEditingController();
  bool isShowOrignPsw = false;
  bool isShowNewPsw = false;
  bool isShowRemind = true;
  final _formKey = GlobalKey<FormState>();
  int _pswLevel = 0;

  @override
  void initState() {
    super.initState();

    _walletPswController.addListener(() {
      var pswStr = _walletPswController.text;
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
        appBar: BaseAppBar(baseTitle: S.of(context).change_password),
        body: _pageWidget(context));
  }

  Widget _pageWidget(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.only(top: 60, left: 16.0, right: 16),
                child: Column(
                  children: [
                    firstPswWidget(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Row(
                        children: [
                          Spacer(),
                          InkWell(
                              onTap: () {
                                Fluttertoast.showToast(msg: "密码提示：${widget.wallet.walletExpandInfoEntity.pswRemind ?? ""}");
                              },
                              child: Text(
                                "${S.of(context).forgot_password}？",
                                style: TextStyle(fontSize: 14, color: HexColor("#1F81FF")),
                              )),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: pswListWidget(
                          isShowNewPsw,
                          (value) {
                            if (value.isEmpty) {
                              setState(() {
                                isShowRemind = false;
                              });
                              return S.of(context).please_input_pwd;
                            } else if (value.length < 6) {
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
                          null,
                          pswLevelLabel(_pswLevel),
                          pswLevelImage(_pswLevel),
                          isShowRemind,
                          _walletRePswController,
                          () {
                            setState(() {
                              isShowNewPsw = !isShowNewPsw;
                            });
                          },
                          _walletPswHintController),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 36.0, top: 22),
          child: ClickOvalButton(
            S.of(context).confirm,
            () async {
              if (!_formKey.currentState.validate()) {
                return;
              }
              bool isPswRight = await WalletUtil.checkPwdValid(
                context,
                widget.wallet,
                _walletOrignPswController.text,
              );
              if(!isPswRight){
                Fluttertoast.showToast(msg: S.of(context).original_password_wrong);
                return;
              }

              var success = await WalletUtil.updateWallet(
                  wallet: widget.wallet, password: _walletOrignPswController.text, newPassword: _walletPswController.text,name: widget.wallet.keystore.name);
              if (success == true) {
                UiUtil.toast(S.of(context).update_success);

                var pswRemindStr = _walletPswHintController.text.trim();
                if(pswRemindStr != null && pswRemindStr.isNotEmpty) {
                  WalletExpandInfoEntity walletExpandInfoEntity = widget.wallet
                      .walletExpandInfoEntity;
                  walletExpandInfoEntity.pswRemind = pswRemindStr;
                  BlocProvider.of<WalletCmpBloc>(context)
                      .add(UpdateWalletExpandEvent(widget.wallet.getEthAccount().address, widget.wallet.walletExpandInfoEntity));
                  Navigator.pop(context,pswRemindStr);
                }else{
                  Navigator.pop(context);
                }
              }else{
                UiUtil.toast(S.of(context).update_failed);
              }

            },
            width: 300,
            height: 46,
          ),
        )
      ],
    );
  }

  Widget firstPswWidget() {
    return Stack(
      children: [
        Container(
          height: 50,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: DefaultColors.colorf6f6f6,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  //obscureText为false则显示
                  obscureText: !isShowOrignPsw,
                  keyboardType: TextInputType.visiblePassword,
                  validator: (value) {
                    if (value.isEmpty) {
                      return S.of(context).please_input_pwd;
                    } else if (value.length < 6) {
                      return S.of(context).password_less_than_six;
                    } else {
                      return null;
                    }
                  },
                  controller: _walletOrignPswController,
                  decoration: InputDecoration(
                    hintText: S.of(context).enter_original_password,
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
                      isShowOrignPsw = !isShowOrignPsw;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 5, bottom: 5),
                    child: Image.asset(
                      isShowOrignPsw
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
    );
  }
}
