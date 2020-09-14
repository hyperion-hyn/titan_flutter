import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/http/http_exception.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/exchange/bloc/bloc.dart';
import 'package:titan/src/components/exchange/exchange_component.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/pages/market/model/asset_list.dart';
import 'package:titan/src/pages/market/model/exchange_account.dart';
import 'package:titan/src/plugins/wallet/account.dart';

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

  ExchangeApi _exchangeApi = ExchangeApi();

  var _isProcessing = false;

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
                        onPressed: _isProcessing
                            ? null
                            : () async {
                                if (_formKey.currentState.validate()) {
                                  setState(() {
                                    _isProcessing = true;
                                  });
                                  _getAssetWithApiKeyAndSecret();
                                }
                              },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                _isProcessing ? '处理中' : S.of(context).next,
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
//    _userApiKeyController.text = '092898fbcf23f2409ce394e9b5e13632';
//    _userSecretController.text = '2f459f6b0fc688fa00b75a44294f4835';
  }

  _saveApiKeyAndSecret() async {
    var _sharePref = await SharedPreferences.getInstance();
    if (_userApiKeyController.text.isNotEmpty &&
        _userSecretController.text.isNotEmpty) {
      _sharePref.setString(
        'exchange_user_api_key',
        _userApiKeyController.text,
      );
      _sharePref.setString(
        'exchange_user_api_secret',
        _userSecretController.text,
      );
    }
  }

  _getAssetWithApiKeyAndSecret() async {
    try {
      var uidRet = await _exchangeApi.getUserId(
        apiKey: _userApiKeyController.text,
        secret: _userSecretController.text,
      );

      var ret = await _exchangeApi.getAssetsList(
        apiKey: _userApiKeyController.text,
        secret: _userSecretController.text,
      );

      var _assetList = AssetList.fromJson(ret);

      ExchangeAccount _exchangeAccount = ExchangeAccount.fromJson({});
      _exchangeAccount.id = uidRet['uid'];
      _exchangeAccount.assetList = _assetList;

      ///
      BlocProvider.of<ExchangeCmpBloc>(context)
          .add(UpdateExchangeAccountEvent(_exchangeAccount));

      ///
      _saveApiKeyAndSecret();

      ///
      if (ExchangeInheritedModel.of(context).exchangeModel.isActiveAccount()) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExchangePage(),
          ),
        );
      }
      setState(() {
        _isProcessing = false;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: e.message);
      setState(() {
        _isProcessing = false;
      });
    }
  }
}
