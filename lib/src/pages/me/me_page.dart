import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/quotes/bloc/bloc.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/extends_icon_font.dart';
import 'package:titan/src/pages/contribution/signal_scan/vo/check_in_model.dart';
import 'package:titan/src/pages/me/components/account/account_component.dart';
import 'package:titan/src/pages/me/grade_page.dart';
import 'package:titan/src/pages/me/model/user_info.dart';
import 'package:titan/src/pages/me/my_contract_record_page.dart';
import 'package:titan/src/pages/me/my_hash_rate_page.dart';
import 'package:titan/src/pages/me/my_node_mortgage_page.dart';
import 'package:titan/src/pages/me/node_mortgage/node_mortgage_page_v2.dart';
import 'package:titan/src/pages/me/personal_settings_page.dart';
import 'package:titan/src/pages/me/service/user_service.dart';
import 'package:titan/src/pages/me/util/me_util.dart';
import 'package:titan/src/pages/mine/about_me_page.dart';
import 'package:titan/src/pages/mine/me_setting_page.dart';
import 'package:titan/src/pages/mine/my_encrypted_addr_page.dart';
import 'package:titan/src/pages/node/map3page/my_map3_contracts_page.dart';
import 'package:titan/src/pages/webview/inappwebview.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';
import '../../../config.dart';
import 'contract/buy_hash_rate_page_v2.dart';
import 'my_asset_page.dart';
import 'my_promote_page.dart';
import 'me_checkin_history_page.dart';

class MePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MeState();
  }
}

class _MeState extends BaseState<MePage> with RouteAware {
//  int checkInCount = 0;
  String _pubKey = "";

  @override
  void onCreated() {
    UserService.syncUserInfo(context);
    _updateCheckInCount();

    _loadData();

    super.onCreated();
  }


  Future _loadData() async {
    _pubKey = await TitanPlugin.getPublicKey();
    setState(() {});

    //update quotes
    BlocProvider.of<QuotesCmpBloc>(context).add(UpdateQuotesEvent(isForceUpdate: true));
    //update all coin balance
    BlocProvider.of<WalletCmpBloc>(context).add(UpdateActivatedWalletBalanceEvent());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Application.routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void didPopNext() {
    Future.delayed(Duration(milliseconds: 500)).then((_) {
      if (mounted) {
        UserService.syncUserInfo();
        _updateCheckInCount();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildHeaderSection(),
            _buildPohNodeSection(),
            _dividerView(isBottom: true),
//            Divider(
//              height: 0,
//            ),
//            _buildWalletSection(),
            // todo: test_jison_0424
//            _dividerView(isBottom: true),
            _buildContractSection(),

            _dividerView(isBottom: true),
            _buildSettingSection(),
            _dividerView(),
            _buildDMapSection(),
            _dividerView(isBottom: true),
          ],
        ),
      ),
    );
  }

  Widget _dividerView({bool isBottom = false}) {
    if (isBottom) {
      return Column(
        children: <Widget>[
          Divider(
            height: 0,
          ),
          SizedBox(
            height: 16 * 1.0,
          ),
        ],
      );
    }

    return Column(
      children: <Widget>[
        SizedBox(
          height: 16,
        ),
        Divider(
          height: 0,
        ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    UserInfo userInfo = AccountInheritedModel.of(context, aspect: AccountAspect.userInfo).userInfo;
    CheckInModel checkInModel = AccountInheritedModel.of(context, aspect: AccountAspect.checkInModel).checkInModel;

    return Stack(
      children: <Widget>[
        Container(
          height: 234,
          decoration: BoxDecoration(
              gradient: LinearGradient(
            colors: [HexColor('#CC941E'), HexColor('#E4B042'), HexColor('#FBE6BD')],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 20,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  GestureDetector(
                    child: Stack(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white,
                          backgroundImage: AssetImage("res/drawable/default_avator.png"),
                        ),
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Image.asset(
                            'res/drawable/ic_me_page_use_edit.png',
                            width: 12,
                            height: 12,
                            color: Colors.yellow,
                          ),
                        )
                      ],
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PersonalSettingsPage()));
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "${shortEmail(userInfo?.email)}",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 7,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => GradePage()));
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: HexColor("#DADFE4")),
                                  shape: BoxShape.rectangle),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                child: Text(
                                  userInfo?.level ?? S.of(context).no_level,
                                  style: TextStyle(fontSize: 10, color: HexColor("#F9F9F9")),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      InkWell(
                          onTap: () async {
                            String scanStr = await BarcodeScanner.scan();
                            print("indexInt= $scanStr");
                            if (scanStr == null) {
                              return;
                            } else if (scanStr.contains("share?id=")) {
                              int indexInt = scanStr.indexOf("=");
                              String contractId = scanStr.substring(indexInt + 1, indexInt + 2);
                              Application.router.navigateTo(
                                  context, Routes.map3node_contract_detail_page + "?contractId=$contractId");
                            } else if (scanStr.contains("http") || scanStr.contains("https")) {
                              scanStr = FluroConvertUtils.fluroCnParamsEncode(scanStr);
                              Application.router
                                  .navigateTo(context, Routes.toolspage_webview_page + "?initUrl=$scanStr");
                            } else {
                              Application.router
                                  .navigateTo(context, Routes.toolspage_qrcode_page + "?qrCodeStr=$scanStr");
                            }
                          },
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
                                  "扫一扫",
                                  style: TextStyle(fontSize: 14, color: Colors.white),
                                ),
                              )
                            ],
                          )),
                      SizedBox(
                        height: 7,
                      ),
                      Row(
                        children: <Widget>[
                          GestureDetector(
                            child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: HexColor('#F2C345'),
                                    borderRadius: BorderRadius.circular(16),
                                    //border: Border.all(color: Theme.of(context).primaryColor),
                                    shape: BoxShape.rectangle),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        ExtendsIconFont.checkbox_outline,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                      Text(
                                        (checkInModel?.finishTaskNum ?? 0) >= 3
                                            ? S.of(context).check_in_completed
                                            : S.of(context).task,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                            onTap: _doTask,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              "${checkInModel?.finishTaskNum ?? 0}/3",
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          )
                        ],
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 24,
              ),
              Container(
                padding: EdgeInsets.fromLTRB(8, 12, 8, 8),
                margin: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [HexColor('#AC823A'), HexColor('#EDC67B'), HexColor('#CBAA69')],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _buildHeaderSectionItem(S.of(context).my_account_with_unit, userInfo?.balance, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MyAssetPage()));
                    }),
                    //显示算力，一定要要做转换显示  Utils.powerForShow
                    _buildHeaderSectionItem(
                        S.of(context).my_power_with_unit, MeUtils.powerForShow(userInfo?.totalPower ?? 0), () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              settings: RouteSettings(name: '/MyHashRatePage'),
                              builder: (context) => MyHashRatePage()));
                    }),
                    _buildHeaderSectionItem(S.of(context).node_mortgage_with_unit, userInfo?.mortgageNodes, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MyNodeMortgagePage()));
                    }),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildHeaderSectionItem(String title, dynamic count, void Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            "${WalletUtil.formatPrice(count ?? 0)}",
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 3,
          ),
          Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPohNodeSection() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildCenterBigButton(S.of(context).get_power, "res/drawable/get_power.png", () {
//                createWalletPopUtilName = "/BuyHashRatePageV2";
                Navigator.push(
                    context,
                    MaterialPageRoute(
//                        settings: RouteSettings(name: '/BuyHashRatePageV2'),
                        builder: (context) => BuyHashRatePageV2()));
              }),
              Padding(
                padding: const EdgeInsets.only(top: 18),
                child: VerticalDivider(
                  width: 0.5,
                  color: HexColor('#E9E9E9'),
                ),
              ),
              _buildCenterBigButton(S.of(context).node_mortgage, "res/drawable/node_mortgage.png", () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => NodeMortgagePageV2()));
              }),
            ],
          ),
        ),
      ),
    );
  }

  /*Widget _buildWalletSection() {
    var wallet = WalletInheritedModel.of(context, aspect: WalletAspect.activatedWallet).activatedWallet;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 16, right: 8, top: 4, bottom: 4),
      child: _buildMemuBar(S.of(context).wallet, 'ic_wallet', () {
        Application.router.navigateTo(context, Routes.wallet_manager);
      }, wallet?.wallet?.keystore?.name ?? S.of(context).wallet_manage),
    );
  }*/

  Widget _buildContractSection() {
    var _wallet = WalletInheritedModel.of(context, aspect: WalletAspect.activatedWallet).activatedWallet;
    return Container(
      padding: EdgeInsets.only(left: 16, right: 8),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: HexColor("#E9E9E9"), width: 0)),
      child: Column(
        children: <Widget>[
          _buildMemuBar(S.of(context).my_contract, "ic_map3_node_item_contract", () {
            if (_wallet != null) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MyContractsPage()));
            } else {
              var tips = FluroConvertUtils.fluroCnParamsEncode('你需要先创建/导入钱包账户，才能查看你的钱包账户相关合约数据。');
              Application.router.navigateTo(context, Routes.wallet_manager + '?tips=$tips');
            }
          }, _wallet == null ? '请先创建/导入钱包' : null),
        ],
      ),
    );
  }

  Widget _buildSettingSection() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 8),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: HexColor("#E9E9E9"), width: 0)),
      child: Column(
        children: <Widget>[
          _buildMemuBar(S.of(context).contract_record, "ic_bill", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MyContractRecordPage()));
          }),
          Divider(
            height: 2,
          ),
          _buildMemuBar(S.of(context).task_record, "ic_me_page_task_record", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MeCheckInHistory()));
          }),
          Divider(
            height: 2,
          ),
          _buildMemuBar(S.of(context).invite_share, "ic_me_page_invite_share", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MyPromotePage()));
          }),
          Divider(
            height: 2,
          ),
          _buildMemuBar(S.of(context).use_guide, "ic_me_page_use_guide", () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => InAppWebViewContainer(
                          initUrl: S.of(context).maprich_intro_url(Config.MAP_RICH_DOMAIN_WEBSITE),
                          title: S.of(context).use_guide,
                        )));
          }),
          Divider(
            height: 2,
          ),
          _buildMemuBar(S.of(context).setting, "ic_me_page_setting", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MeSettingPage()));
          }),
          Divider(
            height: 2,
          ),
          _buildMemuBar(S.of(context).about_us, "ic_me_page_about_us", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AboutMePage()));
          }),
        ],
      ),
    );
  }

  Widget _buildDMapSection() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 0, bottom: 16),
            child: Text(
              S.of(context).dmap_setting,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          _buildDappItem('ic_me_page_use_location', S.of(context).private_sharing,
              S.of(context).private_share_receive_address(UiUtil.shortEthAddress(_pubKey)), () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MyEncryptedAddrPage()));
          }),
        ],
      ),
    );
  }

  Widget _buildCenterBigButton(String title, String imageAsset, Function ontap) {
    return InkWell(
      onTap: ontap,
      child: Container(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.only(top: 48, bottom: 29),
          child: Row(
            children: <Widget>[
              Image.asset(
                imageAsset,
                width: 42,
                height: 42,
                //color: Theme.of(context).primaryColor,
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  title,
                  style: TextStyle(color: HexColor("#333333"), fontWeight: FontWeight.w500),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemuBar(String title, String iconData, Function onTap, [String subText]) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: <Widget>[
            Container(
              width: 20,
              height: 20,
              child: Image.asset(
                "res/drawable/$iconData.png",
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
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
    );
  }

  Widget _buildDappItem(String iconData, String title, String description, Function ontap) {
    return InkWell(
      onTap: ontap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            //color: Colors.blue,
            margin: EdgeInsets.only(top: 8, bottom: 8, right: 16),
            width: 19,
            height: 27,
            child: Image.asset(
              "res/drawable/$iconData.png",
              fit: BoxFit.contain,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                Container(
                  //padding: EdgeInsets.fromLTRB(0, 2, 4, 30),
                  //color: Colors.red,
                  child: Text(
                    description,
                    //maxLines: 2,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          //Spacer(),
          Icon(
            Icons.chevron_right,
            color: Colors.black54,
          )
        ],
      ),
    );
  }

  Future _doTask() async {
    Application.router.navigateTo(context, Routes.contribute_tasks_list);
//    await Navigator.push(
//        context,
//        MaterialPageRoute(
//            /*settings: RouteSettings(name: '/data_contribution_page'),*/
//            builder: (context) => ContributionTasksPage()));
//    _finishCheckIn();
  }

  Future _updateCheckInCount() async {
    UserService.syncCheckInData();
  }

  void _managerWallet() {}

  @override
  void dispose() {
    super.dispose();
    Application.routeObserver.unsubscribe(this);
  }
}
