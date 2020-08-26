import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/mine/about_me_page.dart';
import 'package:titan/src/pages/mine/me_setting_page.dart';
import 'package:titan/src/pages/mine/my_nodes_page.dart';
import 'package:titan/src/pages/node/map3page/my_map3_contracts_page.dart';
import 'package:titan/src/plugins/wallet/account.dart';
import 'package:titan/src/plugins/wallet/keystore.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/route_util.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/wallet_widget.dart';

import 'map3_contract_control.dart';
import 'package:characters/characters.dart';

class MyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyPageState();
  }
}

class _MyPageState extends State<MyPage> {
  Wallet _wallet;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future loadData() async {
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _wallet = WalletInheritedModel.of(context).activatedWallet?.wallet;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              height: 200.0 + MediaQuery.of(context).padding.top,
              child: Container(
                color: Theme.of(context).primaryColor,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Stack(
                    children: <Widget>[
                      /*Positioned(
                        top: 37 + padding,
                        right: 12,
                        child: _buildScanQrCodeRow(),
                      ),*/
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        width: 216,
                        //color: HexColor("#D8D8D8").withOpacity(0.1),
                        decoration: BoxDecoration(
                          color: HexColor("#D8D8D8").withOpacity(0.1),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(216),
                              bottomRight: Radius.circular(216)), // 也可控件一边圆角大小
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        width: 289.39,
                        //color: HexColor("#D8D8D8").withOpacity(0.1),
                        decoration: BoxDecoration(
                          color: HexColor("#D8D8D8").withOpacity(0.1),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(289.39)), // 也可控件一边圆角大小
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: 16),
                            _wallet == null
                                ? _buildWalletCreateRow()
                                : _buildWalletDetailRow(_wallet),
                            SizedBox(height: 16),
                            _buildSloganRow(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
//              padding: EdgeInsets.symmetric(horizontal: 16),
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  Container(
                    height: 10,
                    color: HexColor('#F1EFF2'),
                  ),
                  _buildMenuBar('我的节点', Icons.menu, () {
                    if (_wallet != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyNodesPage(),
                        ),
                      );
                    } else {
                      var tips = FluroConvertUtils.fluroCnParamsEncode(
                          S.of(context).create_wallet_account_check_contract);
                      Application.router.navigateTo(
                          context, Routes.wallet_manager + '?tips=$tips');
                    }
                  },
                      imageName: "ic_my_nodes",
                      subText: _wallet == null
                          ? S.of(context).create_or_import_wallet_first
                          : null),
                  Container(
                    height: 10,
                    color: HexColor('#F1EFF2'),
                  ),
                  _buildMenuBar(
                      S.of(context).share_app, Icons.share, () => shareApp()),
                  Padding(
                    padding: const EdgeInsets.only(left: 56.0),
                    child: Divider(height: 0),
                  ),
                  _buildMenuBar(
                      S.of(context).about_us,
                      Icons.info,
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AboutMePage()))),
                  Padding(
                    padding: const EdgeInsets.only(left: 56.0),
                    child: Divider(height: 0),
                  ),
                  _buildMenuBar(
                      S.of(context).setting,
                      Icons.settings,
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MeSettingPage()))),
                  Divider(
                    height: 0,
                  ),
                  if ([
                    '0x74Fa941242af2F76af1E5293Add5919f6881753a'.toLowerCase(),
                    '0xeeaa0ecc68bf39f87ae52486bfef983f7badda82'.toLowerCase()
                  ].contains(_wallet?.getEthAccount()?.address?.toLowerCase()))
                    _buildMenuBar(
                        S.of(context).map_smart_contract_management,
                        Icons.account_balance_wallet,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Map3ContractControlPage()))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuBar(String title, IconData iconData, Function onTap,
      {String imageName = "", String subText}) {
    Widget iconWidget;
    if (imageName.length <= 0) {
      iconWidget = Icon(
        iconData,
        color: Color(0xffb4b4b4),
      );
    } else {
      iconWidget = Image.asset(
        "res/drawable/$imageName.png",
        width: 25,
        height: 25,
      );
    }

    return Material(
      child: InkWell(
        onTap: onTap,
        child: Ink(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: <Widget>[
              iconWidget,
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  title,
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
              ),
              Spacer(),
              if (subText != null)
                Text(
                  subText,
                  style: TextStyle(color: Colors.black38),
                ),
              Icon(
                Icons.chevron_right,
                color: Colors.black54,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletCreateRow() {
    return Row(
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          width: 52,
          height: 52,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: Theme.of(context).primaryColor),
          child: InkWell(
            onTap: () {},
            child: Stack(
              children: <Widget>[
                Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      "res/drawable/ic_logo.png",
                      width: 80,
                      height: 80,
                    )),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 12,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
              onTap: () {
//                BlocProvider.of<AppTabBarBloc>(context).add(ChangeTabBarItemEvent(index: 1));
                Application.router.navigateTo(context, Routes.wallet_manager);
              },
              child: Text(S.of(context).create_import_wallet_account,
                  style: TextStyle(color: Colors.white70, fontSize: 20))),
        ),
        Spacer(),
      ],
    );
  }

  Widget _buildWalletDetailRow(Wallet wallet) {
    KeyStore walletKeyStore = wallet.keystore;
    Account ethAccount = wallet.getEthAccount();
    String walletName =
        walletKeyStore.name[0].toUpperCase() + walletKeyStore.name.substring(1);

    return Row(
      children: <Widget>[
        Container(
          alignment: Alignment.center,
//          width: 52,
//          height: 52,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: Theme.of(context).primaryColor),
          child: InkWell(
            onTap: () {
              goSetWallet(wallet);
            },
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child: walletHeaderWidget(
                    walletName.characters.first,
                    size: 60,
                    fontSize: 20,
                    address: ethAccount.address,
                    isShowShape: false,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 12,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              goSetWallet(wallet);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  walletName,
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(
                  height: 4,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    shortBlockChainAddress(ethAccount.address,
                        limitCharsLength: 13),
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
        Spacer(),
      ],
    );
  }

  void goSetWallet(Wallet wallet) {
    var walletStr = FluroConvertUtils.object2string(wallet.toJson());
    var currentRouteName = RouteUtil.encodeRouteNameWithoutParams(context);
//    print(currentRouteName);
    Application.router.navigateTo(
        context,
        Routes.wallet_setting +
            '?entryRouteName=$currentRouteName&walletStr=$walletStr');
  }

  Widget _buildSloganRow() {
    return Opacity(
      opacity: 0.8,
      child: Row(
        children: <Widget>[
          //Image.asset('res/drawable/ic_logo.png', width: 40.0),
          Image.asset(
            'res/drawable/logo_title.png',
            width: 72.0,
            height: 36,
          ),
          SizedBox(width: 16),
          Text(S.of(context).titan_encrypted_map_ecology,
              style: TextStyle(color: Colors.white70))
        ],
      ),
    );
  }

  void shareApp() async {
    var languageCode = Localizations.localeOf(context).languageCode;
    var shareAppImage = "";

    if (languageCode == "zh") {
      shareAppImage = "res/drawable/share_app_zh_android.jpeg";
    } else {
      shareAppImage = "res/drawable/share_app_en_android.jpeg";
    }

    final ByteData imageByte = await rootBundle.load(shareAppImage);
    await Share.file(S.of(context).nav_share_app, 'app.png',
        imageByte.buffer.asUint8List(), 'image/jpeg');
  }
}
