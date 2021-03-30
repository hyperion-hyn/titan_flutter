import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/scaffold_map/bloc/bloc.dart';
import 'package:titan/src/components/scaffold_map/map.dart';
import 'package:titan/src/components/setting/model.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/config/extends_icon_font.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_create_wallet_page.dart';
import 'package:titan/src/pages/discover/bloc/bloc.dart';
import 'package:titan/src/pages/discover/dmap_define.dart';
import 'package:titan/src/pages/global_data/global_data.dart';
import 'package:titan/src/pages/mine/my_encrypted_addr_page.dart';
import 'package:titan/src/pages/mine/promote_qr_code_page.dart';
import 'package:titan/src/pages/red_pocket/rp_friend_invite_page.dart';
import 'package:titan/src/pages/red_pocket/rp_share_get_dialog_page.dart';
import 'package:titan/src/pages/webview/webview.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/custom_click_oval_button.dart';
import 'package:titan/src/widget/drag_tick.dart';


class HomePanel extends StatefulWidget {
  final ScrollController scrollController;

  HomePanel({this.scrollController});

  @override
  State<StatefulWidget> createState() {
    return HomePanelState();
  }
}

class HomePanelState extends State<HomePanel> {
  static const int DAPP_HECO_INDEX = 1;
  static const int DAPP_ETH_INDEX = 2;
  static const int DAPP_ATLAS_INDEX = 3;
  var selectDappIndex = DAPP_HECO_INDEX;
  bool showMoreEthDapp = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        color: Colors.white,
      ),
      child: CustomScrollView(
        controller: widget.scrollController,
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 14, bottom: 10),
                  child: DragTick(),
                ),
              ],
            ),
          ),
          //搜索
          SliverToBoxAdapter(
            child: _search(),
          ),
          SliverToBoxAdapter(
            child: _category(),
          ),
          SliverToBoxAdapter(
            child: _focusArea(context),
          ),
          SliverToBoxAdapter(
            child: _dappView(),
          ),
          SliverToBoxAdapter(
            child: _dMap(),
          ),
        ],
      ),
    );
  }

  Widget _focusArea(context) {
    return Container(
      margin: const EdgeInsets.only(
        top: 6,
        bottom: 20,
        left: 14,
        right: 14,
      ),
      padding: const EdgeInsets.only(
        top: 13,
        bottom: 13,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: DefaultColors.colorf2f2f2),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => GlobalDataPage()));
              },
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 8,
                ),
                child: Row(
                  children: [
                    Image.asset(
                      "res/drawable/ic_home_panel_data_display.png",
                      width: 18,
                      height: 18,
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    Text(S.of(context).global_nodes),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                Application.router.navigateTo(context, Routes.contribute_tasks_list);
              },
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 4,
                  right: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Image.asset(
                      "res/drawable/ic_home_panel_data_contribution.png",
                      width: 18,
                      height: 18,
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    Text(S.of(context).data_contribute),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WebViewContainer(
                              initUrl: S.of(context).hyperion_project_intro_url,
                              title: S.of(context).Hyperion,
                            )));
              },
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Image.asset(
                      "res/drawable/ic_home_panel_hyperion.png",
                      width: 18,
                      height: 18,
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    Text(S.of(context).Hyperion),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _focusAreaOld(context) {
    var colors = SupportedTheme.defaultBtnColors(context);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      //margin: EdgeInsets.only(top: 16),
      height: 190,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    onTap: () {
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => GlobalDataPage()));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        gradient: LinearGradient(
                          colors: colors,
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                      ),
                      child: Stack(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0, left: 16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  S.of(context).global_nodes,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: SupportedTheme.textColorBlack),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0, right: 4),
                                  child: Text(
                                    S.of(context).global_map_server_nodes,
                                    style: TextStyle(
                                        color: SupportedTheme.textColorBlack.withOpacity(0.8),
                                        fontSize: 12),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Positioned(
                              top: 12,
                              right: 12,
                              child: Image.asset(
                                'res/drawable/global.png',
                                width: 32,
                                height: 32,
                                color: SupportedTheme.textColorBlack,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WebViewContainer(
                                    initUrl: S.of(context).hyperion_project_intro_url,
                                    title: S.of(context).Hyperion,
                                  )));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        gradient: LinearGradient(
                          colors: colors,
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                      ),
                      child: Stack(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Row(
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      width: 100,
                                      child: Text(
                                        S.of(context).Hyperion,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: SupportedTheme.textColorBlack,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        S.of(context).project_introduction,
                                        style: TextStyle(
                                            color: SupportedTheme.textColorBlack.withOpacity(0.8),
                                            fontSize: 12),
                                      ),
                                    )
                                  ],
                                ),
                                Spacer(),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset(
                                    'res/drawable/ic_hyperion.png',
                                    width: 40,
                                    height: 40,
                                    color: SupportedTheme.textColorBlack,
                                  ),
                                )
                              ],
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
          SizedBox(
            width: 12,
          ),
          Expanded(
            flex: 15,
            child: InkWell(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              onTap: () {
                Application.router.navigateTo(context, Routes.contribute_tasks_list);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  gradient: LinearGradient(
                    colors: colors,
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            S.of(context).data_contribute,
                            style: TextStyle(
                                fontWeight: FontWeight.w600, color: SupportedTheme.textColorBlack),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              S.of(context).data_contribute_reward,
                              style: TextStyle(
                                  color: SupportedTheme.textColorBlack.withOpacity(0.8),
                                  fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                        top: 36,
                        right: 16,
                        child: Image.asset(
                          'res/drawable/data.png',
                          width: 32,
                          height: 32,
                          color: SupportedTheme.textColorBlack,
                        )),
                    /*
                    if ((userInfo?.effectiveAcceleration ?? 0) > 0)
                      Positioned(
                          top: 16,
                          left: 16,
                          child: Image.asset(
                            'res/drawable/contributions_leap.png',
                            width: 20,
                            height: 20,
                            color: Colors.white,
                          )),
                    */
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /*
  Widget _buildDiscoverPage(BuildContext context, Widget child) {
    return BlocBuilder<DiscoverBloc, DiscoverState>(
      bloc: BlocProvider.of<DiscoverBloc>(context),
      builder: (context, state) {
        if (state is ActiveDMapState) {
          DMapCreationModel model = DMapDefine.kMapList[state.name];
          if (model != null) {
            return model.createDAppWidgetFunction(context);
          }
        } else if (state is LoadedFocusState) {
          //focusImages = state.focusImages;
        }
        return Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          body: Container(
            color: Colors.red,
            child: child,
          ),
        );
      },
    );
  }*/

  Widget _dappView() {
    var activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext)?.activatedWallet;
    var _address = activatedWallet?.wallet?.getEthAccount()?.address ?? "";
    return Padding(
      padding: const EdgeInsets.only(left: 14.0, right: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "DApp",
                style: TextStyles.textC333S16bold,
              ),
              Spacer(),
              InkWell(
                  onTap: () {
                    AtlasApi.goToAtlasMap3HelpPage(context);
                  },
                  child: Text(
                    S.of(context).redeem_tutorial,
                    style: TextStyles.textC999S12,
                  )),
            ],
          ),
          Row(
            children: [
              _dappSelectTab("HECO", DAPP_HECO_INDEX),
              Padding(
                padding: const EdgeInsets.only(left: 35.0, right: 35),
                child: _dappSelectTab("ETH", DAPP_ETH_INDEX),
              ),
              _dappSelectTab("ATLAS", DAPP_ATLAS_INDEX),
            ],
          ),
          if (selectDappIndex == DAPP_HECO_INDEX)
            getDappItemWidget(
                _address,
                'https://ht.mdex.com/#/swap',
                CoinType.HB_HT,
                "MDEX",
                HexColor("#140d25b9"),
                null,
                "res/drawable/ic_home_panel_dapp_heco.png",
                "MDEX",
                S.of(context).mdex_desc),
          if (selectDappIndex == DAPP_ETH_INDEX) ...[
            getDappItemWidget(
                _address,
                'http://uniswap.defiplot.com/#/swap',
                CoinType.ETHEREUM,
                "Uniswap",
                null,
                [
                  HexColor("#FCF1FE"),
                  HexColor("#FFF2F9"),
                ],
                "res/drawable/ic_home_panel_dapp_uniswap.png",
                "Uniswap",
                S.of(context).decent_transac_protocol),
            getDappItemWidget(
                _address,
                'https://app.sushi.com',
                CoinType.ETHEREUM,
                "SushiSwap",
                null,
                [
                  HexColor("#EFF9FD"),
                  HexColor("#FFF2F8"),
                ],
                "res/drawable/ic_home_panel_dapp_sushiswap.png",
                "SushiSwap",
                "去中心化交易所"),
            getDappItemWidget(
                _address,
                'https://opensea.io',
                CoinType.ETHEREUM,
                "OpenSea",
                null,
                [
                  HexColor("#EFFAF9"),
                  HexColor("#EFF6FC"),
                ],
                "res/drawable/ic_home_panel_dapp_opensea.png",
                "OpenSea",
                "全球知名加密收藏品交易平台"),
            if (!showMoreEthDapp) ...[
              InkWell(
                onTap: () {
                  setState(() {
                    showMoreEthDapp = true;
                  });
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "查看全部",
                      style: TextStyles.textC999S14,
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    Image.asset(
                      "res/drawable/ic_arrow_down.png",
                      width: 13,
                    )
                  ],
                ),
              ),
            ] else ...[
              /*getDappItemWidget(
                  _address,
                  'http://uniswap.defiplot.com/#/swap',
                  CoinType.ETHEREUM,
                  "DoDo",
                  HexColor("#1ffff600"),
                  null,
                  "res/drawable/ic_home_panel_dapp_dodo.png",
                  "DoDo",
                  "基于 PMM 算法的去中心化交易平台"),*/
              getDappItemWidget(
                  _address,
                  'https://balancer.exchange/#/swap',
                  CoinType.ETHEREUM,
                  "Balancer Exchange",
                  HexColor("#8000000"),
                  null,
                  "res/drawable/ic_home_panel_dapp_balancer.png",
                  "Balancer Exchange",
                  "非托管投资组合管理，提供流动性与价格信息"),
              getDappItemWidget(
                  _address,
                  'https://curve.fi',
                  CoinType.ETHEREUM,
                  "Curve",
                  HexColor("#1aa5a4ce"),
                  null,
                  "res/drawable/ic_home_panel_dapp_curve.png",
                  "Curve",
                  "稳定币优化的链上算法做市商，为你带来更好的交易深度"),
              getDappItemWidget(
                  _address,
                  'https://dfi.money/#/vault',
                  CoinType.ETHEREUM,
                  "DFI.money (YFII)",
                  HexColor("#f001659"),
                  null,
                  "res/drawable/ic_home_panel_dapp_dfi.png",
                  "DFI.money (YFII)",
                  "去中心化被动投资平台"),
              getDappItemWidget(
                  _address,
                  'https://www.chainzarena.com/',
                  CoinType.ETHEREUM,
                  "ChainZ Arena",
                  HexColor("#f4e4435"),
                  null,
                  "res/drawable/ic_home_panel_dapp_chainz.png",
                  "ChainZ Arena",
                  "首款可跨链 RPG 游戏"),
              getDappItemWidget(
                  _address,
                  'https://play.cardmaker.io',
                  CoinType.ETHEREUM,
                  "卡牌制造者",
                  HexColor("#f654ee4"),
                  null,
                  "res/drawable/ic_home_panel_dapp_card_creater.png",
                  "卡牌制造者",
                  "像玩游戏一样制作你的游戏"),
              getDappItemWidget(
                  _address,
                  'https://blockchaincuties.com',
                  CoinType.ETHEREUM,
                  "区块链萌宠",
                  HexColor("#142c8dde"),
                  null,
                  "res/drawable/ic_home_panel_dapp_block_pet.png",
                  "区块链萌宠",
                  "数字宠物收藏品冒险游戏"),
            ],
          ],
          if (selectDappIndex == DAPP_ATLAS_INDEX)
            getDappItemWidget(
                null,
                null,
                null,
                null,
                HexColor('#fff001b'),
                null,
                'res/drawable/ic_wallet_image_rp_hrc30.png',
                S.of(context).red_pocket,
                S.of(context).share_more_airdrop_rewards, inkWellCallback: () {
              if (_address?.isEmpty ?? true) {
                _pushWalletManagerAction();
                return;
              }

              var entryRouteName = Uri.encodeComponent(Routes.red_pocket_page);

              Application.router
                  .navigateTo(context, Routes.red_pocket_page + "?entryRouteName=$entryRouteName");
            }),
        ],
      ),
    );
  }

  Widget getDappItemWidget(String address, String dappUrl, int coinType, String webTitle,
      Color color, List<Color> colorList, String iconPath, String dappTitle, String dappDesc,
      {Function inkWellCallback}) {
    return InkWell(
      onTap: () {
        if (inkWellCallback != null) {
          inkWellCallback();
          return;
        }
        if (address?.isEmpty ?? true) {
          _pushWalletManagerAction();
          return;
        }

        var scanStr = FluroConvertUtils.fluroCnParamsEncode(dappUrl);
        var webTitleStr = FluroConvertUtils.fluroCnParamsEncode(webTitle);
        Application.router.navigateTo(
            context,
            Routes.toolspage_dapp_webview_page +
                "?initUrl=$scanStr&defaultCoin=${coinType.toString()}&title=$webTitleStr");
      },
      child: Container(
        padding: const EdgeInsets.only(left: 16.0, right: 16, top: 15, bottom: 15),
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
            color: color != null ? color : null,
            gradient: colorList != null ? LinearGradient(colors: colorList) : null,
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: Row(
          children: [
            Image.asset(
              iconPath,
              width: 40,
              height: 40,
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dappTitle,
                    style: TextStyles.textC333S14bold,
                  ),
                  Text(dappDesc, style: TextStyles.textC999S12),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _pushWalletManagerAction() {
    Application.router.navigateTo(
        context,
        Routes.map3node_create_wallet +
            "?pageType=${Map3NodeCreateWalletPage.CREATE_WALLET_PAGE_TYPE_NORMAL}");
  }

  Widget _dappSelectTab(String title, int selectIndex) {
    return InkWell(
      onTap: () {
        selectDappIndex = selectIndex;
        if(selectIndex != DAPP_ETH_INDEX) {
          showMoreEthDapp = false;
        }
        setState(() {});
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, bottom: 20),
        child: Column(
          children: [
            Text(
              title,
              style: selectDappIndex == selectIndex
                  ? TextStyles.textC333S14bold
                  : TextStyles.textC999S14,
            ),
            SizedBox(
              height: 6,
            ),
            if (selectDappIndex == selectIndex)
              Container(
                height: 2,
                width: 20,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  HexColor("#E7C01A"),
                  HexColor("#F7D33D"),
                ])),
              )
          ],
        ),
      ),
    );
  }

  Widget _dMap() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
      //padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 16),
            child: Text(
              S.of(context).map_dmap,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),
          Text(S.of(context).dmap_tools, style: TextStyle(color: Colors.grey)),
          SizedBox(
            height: 16,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: HexColor('#FFFCE4'),
              // todo:
              // color: HexColor('#FFEDFCFF'),
            ),
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Image.asset('res/drawable/ic_dmap_location_share.png', width: 32, height: 32),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              S.of(context).private_sharing,
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                S.of(context).private_sharing_text,
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16.0,
                ),
                Row(
                  children: <Widget>[
                    Spacer(),
                    CustomClickOvalButton(
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.lock_open,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(
                            width: 4.0,
                          ),
                          Text(
                            S.of(context).send,
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w400, fontSize: 13.0),
                          )
                        ],
                      ),
                      () async {
                        await activeDMap('encryptShare');
                        var mapboxController =
                            (Keys.mapContainerKey.currentState as MapContainerState)
                                ?.mapboxMapController;

                        var lastLocation = await mapboxController?.lastKnownLocation();
                        if (lastLocation != null) {
                          Future.delayed(Duration(milliseconds: 500)).then((value) {
                            mapboxController
                                ?.animateCamera(CameraUpdate.newLatLngZoom(lastLocation, 17));
                          });
                        }
                      },
                      width: 100,
                      height: 35,
                    ),
                    Spacer(),
                    CustomClickOvalButton(
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            'res/drawable/ic_qrcode.png',
                            width: 15,
                            height: 15,
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            S.of(context).receiver,
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w400, fontSize: 13.0),
                          )
                        ],
                      ),
                      () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => MyEncryptedAddrPage()));
                      },
                      width: 100,
                      height: 35,
                    ),
                    Spacer()
                  ],
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Text(S.of(context).dmap_life, style: TextStyle(color: Colors.grey)),
          ),
          SizedBox(
            height: 16,
          ),
          SizedBox(
            height: 80,
            child: Row(
              children: <Widget>[
                //全球大使馆
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    onTap: () {
                      activeDMap('embassy');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: HexColor("#FFFCE4"),
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: Row(
                        children: <Widget>[
                          Image.asset(
                            'res/drawable/ic_dmap_mbassy.png',
                            width: 28,
                            height: 28,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 2.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    S.of(context).embassy_guide,
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            S.of(context).global_embassies,
                                            style: TextStyle(color: Colors.grey, fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                //警察服务站
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    onTap: () {
                      activeDMap('policeStation');
                    },
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 6, 8),
                      decoration: BoxDecoration(
                          color: HexColor("#FFFCE4"),
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: Row(
                        children: <Widget>[
                          Image.asset(
                            'res/drawable/ic_dmap_police.png',
                            width: 28,
                            height: 28,
                          ),
                          Flexible(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    S.of(context).police_security_station,
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                                  ),
                                  Flexible(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        S.of(context).police_station_text,
                                        style: TextStyle(color: Colors.grey, fontSize: 12),
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
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Align(
                alignment: Alignment.center,
                child: Text(
                  S.of(context).more_dmap,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                )),
          )
        ],
      ),
      /*
      Column(
                children: <Widget>[
                  poiRow1(context),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: poiRow2(context),
                  ),
                ],
              ),
      */
    );
  }

  Widget _search() {
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Color(0xfff2f2f2),
          borderRadius: BorderRadius.all(Radius.circular(44)),
          /*boxShadow: [
            BoxShadow(
              color: HexColor("#000000").withOpacity(0.08),
              offset: Offset(0, 2),
              blurRadius: 12.0,
            ),
          ],*/
        ),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 8),
              child: Icon(
                Icons.search,
                color: Color(0xff777777),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: onSearch,
                child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  child: Text(
                    S.of(context).search_or_decode,
                    style: TextStyle(
                      fontSize: 17,
                      color: Color(0xff777777),
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                UiUtil.showScanImagePickerSheet(context, callback: (String text) {
                  _parseText(text);
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24),
                child: Icon(
                  ExtendsIconFont.qrcode_scan,
                  color: Color(0xff777777),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  get list {
    List<SearchTextModel> list = [];
    List<String> avatars = [
      "food",
      "hotel",
      "scenic_spotx",
      "park",
      "gas_station",
      "bank",
      "supermarket",
      "market",
      "cybercafe",
      "wc",
      "cafe",
      "hospital"
    ];
    List<String> searchTexts = [
      S.of(context).foods,
      S.of(context).hotel,
      S.of(context).attraction,
      S.of(context).parking,
      S.of(context).gas_station,
      S.of(context).bank,
      S.of(context).supermarket,
      S.of(context).mall,
      S.of(context).internet_bar,
      S.of(context).toilet,
      S.of(context).cafe,
      S.of(context).hospital
    ];
    List<String> titles = [
      S.of(context).foods,
      S.of(context).hotel,
      S.of(context).attraction,
      S.of(context).parking,
      S.of(context).gas_station,
      S.of(context).bank,
      S.of(context).supermarket,
      S.of(context).mall,
      S.of(context).internet_bar,
      S.of(context).toilet,
      S.of(context).cafe,
      S.of(context).hospital
    ];

    bool isChinaMainland =
        SettingInheritedModel.of(context, aspect: SettingAspect.area).areaModel?.isChinaMainland ??
            true;
    List<String> typeOfNearBys = [
      "restaurant",
      "lodging",
      "tourist_attraction",
      "parking",
      "gas_station",
      "bank",
      "grocery_or_supermarket",
      "shopping_mall",
      "cafe",
      "night_club",
      "cafe",
      "hospital"
    ];
    for (String item in avatars) {
      var avatar = "res/drawable/ic_$item.png";
      var index = avatars.indexOf(item);
      var typeOfNearBy = typeOfNearBys[index];
      var gaodeType = index + 1;
      var title = titles[index];
      var searchText = searchTexts[index];
      if (typeOfNearBy == "cafe") {
        gaodeType = 9;
      } else if (typeOfNearBy == "hospital" || typeOfNearBy == "night_club") {
        gaodeType = 10;
      } else {
        //print("[category] --> title:$title, gaodeType:$gaodeType");
      }
      var model = SearchTextModel(title, avatar,
          searchText: searchText,
          center: Application.recentlyLocation,
          gaodeType: gaodeType,
          typeOfNearBy: typeOfNearBy);
      switch (index + 1) {
        case 9:
        case 10:
          if (isChinaMainland) {
            list.add(model);
          }
          break;

        case 11:
        case 12:
          if (!isChinaMainland) {
            list.add(model);
          }
          break;

        default:
          list.add(model);
          break;
      }
    }
    return list;
  }

  Widget _category() {
    return Container(
      padding: const EdgeInsets.only(
        top: 4,
        left: 12,
        right: 12,
      ),
      height: 46,
      //color: Colors.red,
      child: ListView.builder(
        itemBuilder: (context, index) {
          var model = list[index];

          return InkWell(
            onTap: () {
              if (model.center != null) {
                BlocProvider.of<ScaffoldMapBloc>(context).add(SearchTextEvent(
                    isCategorySearch: model.isCategorySearch,
                    gaodeType: model.gaodeType,
                    center: model.center,
                    searchText: model.searchText,
                    typeOfNearBy: model.typeOfNearBy));
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 8,
              ),
              child: Container(
                // height: 20,
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 2),
                decoration: BoxDecoration(
                  border: Border.all(color: HexColor("#dedede")),
                  borderRadius: BorderRadius.circular(20),
                ),
                child:
                    Text(model.title, style: TextStyle(fontSize: 12, color: HexColor("#999999"))),
              ),
            ),
          );
        },
        itemCount: list.length,
        scrollDirection: Axis.horizontal,
      ),
    );
  }

  void onSearch() async {
    Application.eventBus.fire(GoSearchEvent());
  }

  Future _parseText(String scanStr) async {
    print("[扫描结果] scanStr:$scanStr");

    if (scanStr == null) {
      return;
    } else if (scanStr.contains("share?id=")) {
      var andList = scanStr.split("&");
      if (andList.length == 0) {
        return;
      }
      var idList = andList[0].split("id=");
      if (idList.length < 1) {
        return;
      }
      var infoEntity = Map3InfoEntity.onlyNodeId(idList[1]);
      Application.router.navigateTo(
          context,
          Routes.map3node_contract_detail_page +
              '?info=${FluroConvertUtils.object2string(infoEntity.toJson())}');
    } else if (scanStr.contains(RpFriendInvitePage.shareDomain)) {
      var fromArr = scanStr.split("from=");
      if (fromArr[1].length > 0) {
        fromArr = fromArr[1].split("&name=");
        if (fromArr[0].length > 0 && fromArr[1].length > 0) {
          showInviteDialog(context, fromArr[0], fromArr[1]);
        }
      }
    } else if (scanStr.contains(RpShareGetDialogPage.shareDomain)) {
      /*RegExp regExpStr = new RegExp(r"(?<=rpId=).+(?<=&from)");
      String rpId = regExpStr.firstMatch(scanStr).group(0);
      print("!!!!3322 $rpId");*/

      var rpIdArrAfter = scanStr.split("?rpId=");
      if (rpIdArrAfter.length > 0) {
        var rpIdBefore = rpIdArrAfter[1].split("&");
        showShareRpOpenDialog(context, id: rpIdBefore[0]);
      }
    } else if (scanStr.contains(PromoteQrCodePage.downloadDomain)) {
      var fromArr = scanStr.split("from=");
      if (fromArr[1].length > 0) {
        fromArr = fromArr[1].split("&name=");
        if (fromArr[0].length > 0 && fromArr[1].length > 0) {
          showTitanInviteDialog(context, fromArr[0], fromArr[1], '');
        }
      }
    } else if (scanStr.contains("http") || scanStr.contains("https")) {
      scanStr = FluroConvertUtils.fluroCnParamsEncode(scanStr);
      Application.router.navigateTo(context, Routes.toolspage_webview_page + "?initUrl=$scanStr");
    } else {
      Application.router.navigateTo(context, Routes.toolspage_qrcode_page + "?qrCodeStr=$scanStr");
    }
  }

  Future activeDMap(String dMapName) async {
    BlocProvider.of<DiscoverBloc>(context).add(ActiveDMapEvent(name: dMapName));

    var model = DMapDefine.kMapList[dMapName];
    if (model != null) {
      if (model.dMapConfigModel.defaultLocation != null &&
          model.dMapConfigModel.defaultZoom != null) {
        MapContainerState mapState = (Keys.mapContainerKey.currentState as MapContainerState);
        mapState.updateMyLocationTrackingMode(MyLocationTrackingMode.None);
        await Future.delayed(Duration(milliseconds: 300));

        mapState?.mapboxMapController?.animateCamera(CameraUpdate.newLatLngZoom(
          model.dMapConfigModel.defaultLocation,
          model.dMapConfigModel.defaultZoom,
        ));
      }
    }
  }
}

class SearchTextModel {
  String title;
  String avatar;

  String searchText;
  LatLng center;

  //is category search
  bool isCategorySearch;
  int gaodeType; //only China mainland, type of gaode
  String typeOfNearBy; //only not China mainland, category of type

  SearchTextModel(this.title, this.avatar,
      {this.searchText,
      this.center,
      this.gaodeType,
      this.isCategorySearch = true,
      this.typeOfNearBy});
}
