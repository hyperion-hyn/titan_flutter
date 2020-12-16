import 'dart:io';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info/package_info.dart';
import 'package:titan/env.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/inject/injector.dart';
import 'package:titan/src/components/updater/bloc/bloc.dart';
import 'package:titan/src/components/updater/bloc/update_event.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/data/entity/update.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/mine/about_me_page.dart';
import 'package:titan/src/pages/mine/dex_wallet_m_page.dart';
import 'package:titan/src/pages/mine/me_setting_page.dart';
import 'package:titan/src/pages/mine/promote_qr_code_page.dart';
import 'package:titan/src/pages/policy/policy_select_apge.dart';
import 'package:titan/src/plugins/wallet/account.dart';
import 'package:titan/src/plugins/wallet/keystore.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/route_util.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/wallet_widget.dart';
import '../../global.dart';
import 'map3_contract_control.dart';
import 'package:characters/characters.dart';

class MyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyPageState();
  }
}

class _MyPageState extends BaseState<MyPage> {
  Wallet _wallet;
  String _version = "";
  bool _haveNewVersion = false;
  UpdateEntity _updateEntity;

  @override
  void initState() {
    super.initState();
  }

  Future _loadData() async {
    try {
      var injector = Injector.of(context);
      var channel = "";
      if (env.channel == BuildChannel.OFFICIAL) {
        channel = "official";
      } else if (env.channel == BuildChannel.STORE) {
        channel = "store";
      }

      var platform = "";
      if (Platform.isAndroid) {
        platform = "android";
      } else if (Platform.isIOS) {
        platform = "ios";
      }
      var lang = Localizations.localeOf(context).languageCode;
      var versionModel = await injector.repository.checkNewVersion(channel, lang, platform);

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      var newBuildNumber = versionModel?.build ?? 0;
      if (int.parse(packageInfo.buildNumber) < newBuildNumber) {
        _version = '${versionModel.versionName}.${versionModel.build}';
        _haveNewVersion = true;
        _updateEntity = versionModel;
      } else {
        print('[updater] 已经是最新版本');
      }
      if (mounted) {
        setState(() {});
      }
    } catch (err) {
      logger.e(err);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _wallet = WalletInheritedModel.of(context).activatedWallet?.wallet;

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      if (mounted) {
        setState(() {
          _version = packageInfo.version;
          if (env.buildType != BuildType.PROD) {
            _version += '(Test1.3)';
          }
        });
      }
    });
  }

  @override
  void onCreated() {
    super.onCreated();

    _loadData();
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
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: InkWell(
                          onTap: shareApp,
                          child: Row(
                            children: [
                              Text(
                                S.of(context).share_app,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 6,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(
                                    4,
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    //color: Colors.greenAccent,
                                    color: Theme.of(context).primaryColor,
                                    // border: Border.all(width: 0.5, color: Colors.white,),
                                  ),
                                  child: Icon(
                                    Icons.share,
                                    color: Color(0xffffffff),
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                  _lineWidget(),
                  _buildMenuBar('钱包管理', Icons.account_balance_wallet,
                      () => Application.router.navigateTo(context, Routes.wallet_manager),
                  color: Colors.cyan[300],
                  ),
                  _lineWidget(),
                  _buildMenuBar('使用设置', Icons.settings,
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => MeSettingPage())),
                    color: Colors.cyan[400],
                  ),

                  _lineWidget(),
                  _buildMenuBar(S.of(context).user_policy, Icons.assignment, () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PolicySelectPage(),
                        ));
                  },
                    color: Colors.cyan[300],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 56.0),
                    child: Divider(height: 0),
                  ),
                  _buildMenuBar(S.of(context).help, Icons.help, () => AtlasApi.goToAtlasMap3HelpPage(context),
                    color: Colors.cyan[400],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 56.0),
                    child: Divider(height: 0),
                  ),
                  _buildMenuBar(S.of(context).about_us, Icons.info,
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => AboutMePage())),
                    color: Colors.cyan[300],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 56.0),
                    child: Divider(height: 0),
                  ),
                  _buildMenuBar(
                    '版本更新',
                    Icons.batch_prediction,
                    () {
                      if (_haveNewVersion) {
                        _showUpdateDialog(_updateEntity);
                      } else {
                        BlocProvider.of<UpdateBloc>(context)
                            .add(CheckUpdate(lang: Localizations.localeOf(context).languageCode, isManual: true));
                      }
                    },
                    subText: _version,
                    haveCircle: _haveNewVersion,
                    color: Colors.cyan[400],
                  ),
                  if ([
                    '0x74Fa941242af2F76af1E5293Add5919f6881753a'.toLowerCase(),
                    '0xeeaa0ecc68bf39f87ae52486bfef983f7badda82'.toLowerCase(),
                    '0x5AD1e746E6610401f598486d8747d9907Cf114b2'.toLowerCase(),
                  ].contains(_wallet?.getEthAccount()?.address?.toLowerCase()))
                    _buildMenuBar(
                        S.of(context).map_smart_contract_management,
                        Icons.book,
                        () => Navigator.push(
                            context, MaterialPageRoute(builder: (context) => Map3ContractControlPage()))),
                  Divider(
                    height: 0,
                  ),
                  if ([
                    '0x70247395aFFd13C2347aA8c748225f1bFeD2C32A'.toLowerCase(),
                    '0x9D05DDfC30bc83e7215EB3C5C3C7A443e7Ee1dB6'.toLowerCase(),
                    '0x5AD1e746E6610401f598486d8747d9907Cf114b2'.toLowerCase(),
                  ].contains(_wallet?.getEthAccount()?.address?.toLowerCase()))
                    _buildMenuBar('链上子钱包', Icons.account_balance_wallet,
                        () => Navigator.push(context, MaterialPageRoute(builder: (context) => DexWalletManagerPage()))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lineWidget() {
    return Container(
      height: 5,
      color: HexColor('#F1EFF2'),
    );
  }

  Widget _buildMenuBar(
    String title,
    IconData iconData,
    Function onTap, {
    String imageName = "",
    String subText,
    bool haveCircle = false,
    Color color,
  }) {
    Widget iconWidget;
    if (imageName.length <= 0) {
      iconWidget = Icon(
        iconData,
        color: color??Color(0xffb4b4b4),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
              if (haveCircle)
                Padding(
                  padding: const EdgeInsets.only(left: 6.0),
                  child: Container(
                    height: 8,
                    width: 8,
                    decoration: BoxDecoration(
                        color: HexColor("#DA3B2A"),
                        shape: BoxShape.circle,
                        border: Border.all(color: HexColor("#DA3B2A"))),
                  ),
                ),
              Icon(
                Icons.chevron_right,
                color: Colors.black54,
              ),
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
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(
                  height: 4,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    shortBlockChainAddress(
                        WalletUtil.ethAddressToBech32Address(
                          ethAccount.address,
                        ),
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
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PromoteQrCodePage()));
    /*
    return;

    var languageCode = Localizations.localeOf(context).languageCode;
    var shareAppImage = "";

    if (languageCode == "zh") {
      shareAppImage = "res/drawable/share_app_zh_android.jpeg";
    } else {
      shareAppImage = "res/drawable/share_app_en_android.jpeg";
    }

    final ByteData imageByte = await rootBundle.load(shareAppImage);
    await Share.file(S.of(context).nav_share_app, 'app.png', imageByte.buffer.asUint8List(), 'image/jpeg');
    */
  }

  void _showUpdateDialog(UpdateEntity updateEntity) async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = S.of(context).new_update_available;
        String message = updateEntity.content;
        String btnLabelCancel = S.of(context).later;
        return Material(
          color: Colors.transparent,
          child: WillPopScope(
            onWillPop: () {
              return;
            },
            child: Container(
              child: Padding(
                padding: const EdgeInsets.only(top: 80.0),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          width: 300,
                          height: 336,
                          margin: const EdgeInsets.only(top: 56.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          child: Column(
                            children: <Widget>[
                              Image.asset(
                                "res/drawable/ic_update_dialog_top_bg.png",
                                width: 300,
                                height: 88,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 15.0, bottom: 15),
                                child: Text(
                                  title,
                                  style: TextStyles.textC333S18,
                                ),
                              ),
                              Container(
                                height: 104,
                                width: double.infinity,
                                padding: const EdgeInsets.only(left: 24.0, right: 24),
                                child: SingleChildScrollView(
                                  child: Text(
                                    message,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: DefaultColors.color333,
                                        fontWeight: FontWeight.normal,
                                        decoration: TextDecoration.none),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 26.0),
                                child: ClickOvalButton(
                                  "立即体验",
                                  () {
                                    _launch(updateEntity);
                                  },
                                  width: 200,
                                  height: 38,
                                  fontSize: 16,
                                ),
                              )
                            ],
                          ),
                        ),
                        // if (updateEntity.forceUpdate != 1)
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(17.0),
                            child: Image.asset(
                              "res/drawable/ic_dialog_close.png",
                              width: 30,
                              height: 30,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Image.asset(
                      "res/drawable/ic_update_dialog_top_image.png",
                      width: 227,
                      height: 138,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _launch(UpdateEntity versionModel) async {
    Navigator.maybePop(context);

    launchUrl(versionModel.downloadUrl);

    if (versionModel.forceUpdate != 1) {
      Navigator.pop(context);
    }
  }
}
