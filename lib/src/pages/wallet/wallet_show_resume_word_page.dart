import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';

class ShowResumeWordPage extends StatefulWidget {
  String walletName;
  String password;

  ShowResumeWordPage(this.walletName, this.password);

  @override
  State<StatefulWidget> createState() {
    return _ShowResumeWordState();
  }
}

class _ShowResumeWordState extends State<ShowResumeWordPage> {
  List _resumeWords = [];
  String createWalletMnemonicTemp;

  @override
  void initState() {
    super.initState();
    getMnemonic();
  }

  Future getMnemonic() async {
    var mnemonic = await WalletUtil.makeMnemonic();

//    logger.i("mnemonic:$mnemonic");
//    logger.w('TODO');
    if (mnemonic != null && mnemonic.isNotEmpty) {
      _resumeWords = mnemonic.split(" ");
      createWalletMnemonicTemp = mnemonic;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Container(
          height: double.infinity,
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  S.of(context).your_mnemonic,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    S.of(context).save_mnemonic_notice,
                    style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 13),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 8.0),
                  child: Container(
                    child: GridView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate:
                            new SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 10.0,
                                crossAxisSpacing: 10.0,
                                childAspectRatio: 3),
                        itemCount: _resumeWords.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: HexColor("#FFB7B7B7")),
                                  borderRadius: BorderRadius.circular(12)),
                              child:
                                  Text("${index + 1} ${_resumeWords[index]}"));
                        }),
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(color: HexColor("#FFFAEAEC")),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 16.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(
                          Icons.warning,
                          color: Color(0xFFD0021B),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          S.of(context).save_mnemonic_safe_notice,
                          style: TextStyle(
                            color: Color(0xFFD0021B),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          softWrap: true,
                        ),
                      ),
                      SizedBox(
                        width: 16.0,
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 32, horizontal: 36),
                  constraints: BoxConstraints.expand(height: 48),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    disabledColor: Colors.grey[600],
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    disabledTextColor: Colors.white,
                    onPressed: () {
                      print("zhuji $createWalletMnemonicTemp");
                      Application.router.navigateTo(
                          context,
                          Routes.wallet_confirm_resume_word +
                              '?mnemonic=$createWalletMnemonicTemp&walletName=${FluroConvertUtils.fluroCnParamsEncode(widget.walletName)}&password=${widget.password}');
//                      Navigator.push(context, MaterialPageRoute(builder: (context) => ConfirmResumeWordPage("truck impact silver wall hunt orphan squeeze valid boss emotion right hazard")));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            S.of(context).continue_text,
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
        ));
  }
}
