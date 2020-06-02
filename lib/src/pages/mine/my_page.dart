import 'package:barcode_scan/barcode_scan.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/extends_icon_font.dart';
import 'package:titan/src/pages/mine/about_me_page.dart';
import 'package:titan/src/pages/mine/me_setting_page.dart';
import 'package:titan/src/pages/mine/my_encrypted_addr_page.dart';
import 'package:titan/src/pages/node/map3page/my_map3_contracts_page.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:titan/src/plugins/wallet/account.dart';
import 'package:titan/src/plugins/wallet/keystore.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/route_util.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/click_oval_button.dart';
import 'package:titan/src/widget/click_rectangle_button.dart';
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
  String _pubKey = "";
  Wallet _wallet;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future loadData() async {
    _pubKey = await TitanPlugin.getPublicKey();
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _wallet = WalletInheritedModel.of(context).activatedWallet?.wallet;
  }

  @override
  Widget build(BuildContext context) {
    double padding = UiUtil.isIPhoneX(context) ? 20 : 0;
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
                      Positioned(
                        top: 37 + padding,
                        right: 12,
                        child: _buildScanQrCodeRow(),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        width: 216,
                        //color: HexColor("#D8D8D8").withOpacity(0.1),
                        decoration: BoxDecoration(
                          color: HexColor("#D8D8D8").withOpacity(0.1),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(216), bottomRight: Radius.circular(216)), // 也可控件一边圆角大小
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        width: 289.39,
                        //color: HexColor("#D8D8D8").withOpacity(0.1),
                        decoration: BoxDecoration(
                          color: HexColor("#D8D8D8").withOpacity(0.1),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.only(topRight: Radius.circular(289.39)), // 也可控件一边圆角大小
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: 16),
                            _wallet == null ? _buildWalletCreateRow() : _buildWalletDetailRow(_wallet),
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
                  /*_buildMenuBar(S.of(context).my_initiated_map_contract, Icons.menu, () {
                    if (_wallet != null) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MyMap3ContractPage(S.of(context).my_initiated_map_contract)));
                    } else {
                      Application.router.navigateTo(context, Routes.wallet_manager);
                      //Fluttertoast.showToast(msg: S.of(context).please_create_import_wallet, gravity: ToastGravity.CENTER);
                    }
                  }, imageName: "my_contract_create"),
                  Padding(
                    padding: const EdgeInsets.only(left: 56.0),
                    child: Divider(height: 0),
                  ),
                  _buildMenuBar(S.of(context).my_join_map_contract, Icons.menu, () {
                    if (_wallet != null) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MyMap3ContractPage(S.of(context).my_join_map_contract)));
                    } else {
                      Application.router.navigateTo(context, Routes.wallet_manager);
                      //Fluttertoast.showToast(msg: S.of(context).please_create_import_wallet, gravity: ToastGravity.CENTER);
                    }
                  }, imageName: "my_contract_join"),
                  Container(
                    height: 10,
                    color: HexColor('#F1EFF2'),
                  ),*/
                  _buildMenuBar(S.of(context).my_contract, Icons.menu, () {
                    if (_wallet != null) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MyContractsPage()));
                    } else {
                      var tips =
                          FluroConvertUtils.fluroCnParamsEncode(S.of(context).create_wallet_account_check_contract);
                      Application.router.navigateTo(context, Routes.wallet_manager + '?tips=$tips');
                    }
                  },
                      imageName: "ic_map3_node_item_contract",
                      subText: _wallet == null ? S.of(context).create_or_import_wallet_first : null),
                  Container(
                    height: 10,
                    color: HexColor('#F1EFF2'),
                  ),
                  _buildMenuBar(S.of(context).share_app, Icons.share, () => shareApp()),
                  Padding(
                    padding: const EdgeInsets.only(left: 56.0),
                    child: Divider(height: 0),
                  ),
                  _buildMenuBar(S.of(context).about_us, Icons.info,
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => AboutMePage()))),
                  Padding(
                    padding: const EdgeInsets.only(left: 56.0),
                    child: Divider(height: 0),
                  ),
                  _buildMenuBar(S.of(context).setting, Icons.settings,
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => MeSettingPage()))),
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
                            context, MaterialPageRoute(builder: (context) => Map3ContractControlPage()))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16, left: 16),
              child: Row(
                children: <Widget>[
                  Text(
                    S.of(context).dapp_setting,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Divider(height: 0),
                _buildDMapItem(Icons.location_on, S.of(context).private_share,
                    S.of(context).private_share_receive_address(shortBlockChainAddress(_pubKey)), () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MyEncryptedAddrPage()));
                }),
                Divider(height: 0),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMenuBar(String title, IconData iconData, Function onTap, {String imageName = "", String subText}) {
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

  Widget _buildDMapItem(IconData iconData, String title, String description, Function ontap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: ontap,
        child: Ink(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(iconData, color: Color(0xffb4b4b4), size: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              Spacer(),
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

  Widget _buildScanQrCodeRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        InkWell(
            onTap: _scanAction,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Icon(
                    ExtendsIconFont.qrcode_scan,
                    color: Colors.white,
                    size: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      S.of(context).scan,
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  )
                ],
              ),
            )),
      ],
    );
  }

  void showAlertView1(String title, List<Widget> actions, [String content, String detail, String boldContent, String suffixContent]) {

    showDialog(
      // 传入 context
      context: context,
      // 构建 Dialog 的视图
      builder: (_) => Padding(
        padding: EdgeInsets.all(36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              //alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    right: 10,
                    top: 10,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(_),
                      child: Image.asset(
                        "res/drawable/map3_node_close.png",
                        width: 18,
                        height: 18,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(title,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: HexColor("#333333"),
                                decoration: TextDecoration.none)),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 24, left: 24, right: 24),
                        child: RichText(
                            text: TextSpan(
                                text: content,
                                style: TextStyle(fontSize: 15, color: HexColor("#333333"), height: 1.8),
                                children: [
                              TextSpan(
                                text: boldContent,
                                style: TextStyle(fontSize: 15, color: HexColor("#FF4C3B"), height: 1.8),
                              ),
                              TextSpan(
                                text: suffixContent,
                                style: TextStyle(fontSize: 15, color: HexColor("#333333"), height: 1.8),
                              ),
                            ])),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 15, bottom: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            FlatButton(
                              onPressed: () {
                                // 关闭 Dialog
                                Navigator.pop(_);
                              },
                              child: Text(
                                '确定撤销',
                                style: TextStyle(color: HexColor("#999999"), fontSize: 16),
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            ClickOvalButton(
                              "再想想",
                              () {
                                Navigator.pop(_);
                              },
                              width: 120,
                              height: 38,
                              fontSize: 16,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void showAlertView({String title, List<Widget> actions, String content, String detail="", String boldContent="", String suffixContent=""}) {

    showDialog(
      // 传入 context
      context: context,
      // 构建 Dialog 的视图
      builder: (_) => Padding(
        padding: EdgeInsets.all(36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              //alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    right: 10,
                    top: 10,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(_),
                      child: Image.asset(
                        "res/drawable/map3_node_close.png",
                        width: 18,
                        height: 18,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(title,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: HexColor("#333333"),
                                decoration: TextDecoration.none)),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 24, left: 24, right: 24),
                        child: RichText(
                            text: TextSpan(
                                text: content,
                                style: TextStyle(fontSize: 15, color: HexColor("#333333"), height: 1.8),
                                children: [
                                  TextSpan(
                                    text: boldContent,
                                    style: TextStyle(fontSize: 15, color: HexColor("#FF4C3B"), height: 1.8),
                                  ),
                                  TextSpan(
                                    text: suffixContent,
                                    style: TextStyle(fontSize: 15, color: HexColor("#333333"), height: 1.8),
                                  ),
                                ])),
                      ),
                      if (detail.isNotEmpty) Padding(
                        padding: EdgeInsets.only(top: 6, left: 24, right: 24),
                        child: Text(detail,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                color: HexColor("#999999"),
                                height: 1.8,
                                decoration: TextDecoration.none)),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 15, bottom: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: actions,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future _scanAction() async {
    showAlertView(title:"重要提示", actions:[
      FlatButton(
        onPressed: () {
          print("[Alert] --> 确定撤销");
                    Navigator.pop(context);
         },
        child: Text(
          '确定撤销',
          style: TextStyle(color: HexColor("#999999"), fontSize: 16),
        ),
      ),
      SizedBox(
        width: 20,
      ),
      ClickOvalButton(
        "再想想",
            () {
              print("[Alert] --> 再想想");
              Navigator.pop(context);
            },
        width: 120,
        height: 38,
        fontSize: 16,
      ),
    ], content:"你将撤销全部抵押(20,000HYN) 到原来钱包，且当前节点", boldContent:"将被取消", suffixContent:"，是否继续操作?");

    /*showAlertView(title:"重要提示", actions:[
      FlatButton(
        onPressed: () {
          print("[Alert] --> 确定撤销");
          Navigator.pop(context);
        },
        child: Text(
          '确定撤销',
          style: TextStyle(color: HexColor("#999999"), fontSize: 16),
        ),
      ),
      SizedBox(
        width: 20,
      ),
      ClickOvalButton(
        "再想想",
            () {
          print("[Alert] --> 再想想");
          Navigator.pop(context);
        },
        width: 120,
        height: 38,
        fontSize: 16,
      ),
    ], content:"您的抵押金额为300,000 撤销100,000剩余200,000 距离节点启动所需还差400,000！");
*/

    /* showAlertView(title:"操作错误", actions:[
      ClickOvalButton(
        "重新输入",
            () {
          print("[Alert] --> 再想想");
          Navigator.pop(context);
        },
        width: 200,
        height: 38,
        fontSize: 16,
      ),
    ], content:"撤销200,000后剩余抵押不足节点启动所需的20%!", detail:"你必须保证剩余额度不少于启动所需的20%来保证节点继续有效，或者撤销全部抵押以取消节点。");
*/
    return;

    // todo: test_jison_0429
    String scanStr = await BarcodeScanner.scan();
    print("[scan] indexInt= $scanStr");
    if (scanStr == null) {
      return;
    } else if (scanStr.contains("share?id=")) {
      int indexInt = scanStr.indexOf("=");
      String contractId = scanStr.substring(indexInt + 1, indexInt + 2);
      Application.router.navigateTo(context, Routes.map3node_contract_detail_page + "?contractId=$contractId");
    } else if (scanStr.contains("http") || scanStr.contains("https")) {
      scanStr = FluroConvertUtils.fluroCnParamsEncode(scanStr);
      Application.router.navigateTo(context, Routes.toolspage_webview_page + "?initUrl=$scanStr");
    } else {
      Application.router.navigateTo(context, Routes.toolspage_qrcode_page + "?qrCodeStr=$scanStr");
    }
  }

  Widget _buildWalletCreateRow() {
    return Row(
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          width: 52,
          height: 52,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
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
    String walletName = walletKeyStore.name[0].toUpperCase() + walletKeyStore.name.substring(1);

    return Row(
      children: <Widget>[
        Container(
          alignment: Alignment.center,
//          width: 52,
//          height: 52,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
          child: InkWell(
            onTap: () {
              goSetWallet(wallet);
            },
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child: walletHeaderWidget(
                    walletName,
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
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(
                  height: 4,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    shortBlockChainAddress(ethAccount.address, limitCharsLength: 13),
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
    Application.router
        .navigateTo(context, Routes.wallet_setting + '?entryRouteName=$currentRouteName&walletStr=$walletStr');
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
          Text(S.of(context).titan_encrypted_map_ecology, style: TextStyle(color: Colors.white70))
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
    await Share.file(S.of(context).nav_share_app, 'app.png', imageByte.buffer.asUint8List(), 'image/jpeg');
  }
}
