import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';

import '../../widget/loading_button/click_oval_button.dart';
import 'exchange/exchange_page.dart';
import 'exchange_detail/exchange_detail_page.dart';

class PartnerExchangeLoginPage extends StatefulWidget {
  PartnerExchangeLoginPage();

  @override
  State<StatefulWidget> createState() {
    return _PartnerExchangeLoginPageState();
  }
}

class _PartnerExchangeLoginPageState extends State<PartnerExchangeLoginPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _userSecretController = TextEditingController();
  TextEditingController _userApiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getPreviousApiKeyAndSecret();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          title: Text(
            '登录交易所',
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          actions: [],
        ),
        body: SingleChildScrollView(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              // hide keyboard when touch other widgets
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Form(
              key: _formKey,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
                alignment: Alignment.center,
                child: Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      width: 64,
                      height: 64,
                      child: Image.asset("res/drawable/ic_hyn_logo_new.png"),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 50),
                      child: Text(
                        '使用API方式登录',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'API Key',
                          style: TextStyle(
                              color: HexColor('#333333'),
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 10),
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value.isEmpty) {
                            return '不可为空';
                          } else {
                            return null;
                          }
                        },
                        controller: _userApiKeyController,
                        decoration: InputDecoration(
                          hintText: '请输入API Key',
                          hintStyle: TextStyle(
                            color: HexColor('#AAAAAA'),
                            fontSize: 13,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: HexColor('#FFD0D0D0'),
                              width: 0.5,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: HexColor('#FFD0D0D0'),
                              width: 0.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: HexColor('#FFD0D0D0'),
                              width: 0.5,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: Colors.red,
                              width: 0.5,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    Row(
                      children: [
                        Text(
                          'API Secret',
                          style: TextStyle(
                              color: HexColor('#333333'),
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 10),
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value.isEmpty) {
                            return '不可为空';
                          } else {
                            return null;
                          }
                        },
                        controller: _userSecretController,
                        decoration: InputDecoration(
                          hintText: '请输入Secret',
                          hintStyle: TextStyle(
                            color: HexColor('#AAAAAA'),
                            fontSize: 13,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: HexColor('#FFD0D0D0'),
                              width: 0.5,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: HexColor('#FFD0D0D0'),
                              width: 0.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: HexColor('#FFD0D0D0'),
                              width: 0.5,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: Colors.red,
                              width: 0.5,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 24, 0, 48),
                      constraints: BoxConstraints.expand(height: 48),
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        disabledColor: Colors.grey[600],
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        disabledTextColor: Colors.white,
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ExchangePage()));
//                            _getAssetsWithApiKeyAndSecret();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                S.of(context).next,
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16,
                                ),
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
        ));
  }

  Future<void> _getPreviousApiKeyAndSecret() async {
    var _sharePref = await SharedPreferences.getInstance();
    var _previousApiKey = _sharePref.getString('exchange_user_api_key');
    var _previousApiSecret = _sharePref.getString('exchange_user_api_secret');
    if (_previousApiKey != null && _previousApiSecret != null) {
      _userApiKeyController.text = _previousApiKey;
      _userSecretController.text = _previousApiSecret;
    }
//    _userApiKeyController.text = '085a079afac86bcf25418a508810d847';
//    _userSecretController.text = 'bb376aa6b4d2b82367414fc510c1615c';
  }

  _getAssetsWithApiKeyAndSecret() {

  }

  _saveApiKeyAndSecret() async {
    var _sharePref = await SharedPreferences.getInstance();
    if (_userApiKeyController.text.isNotEmpty) {
      _sharePref.setString('exchange_user_api_key', _userApiKeyController.text);
    }
    if (_userSecretController.text.isNotEmpty) {
      _sharePref.setString(
          'exchange_user_api_secret', _userSecretController.text);
    }
  }

  _getAsset() {}
}
