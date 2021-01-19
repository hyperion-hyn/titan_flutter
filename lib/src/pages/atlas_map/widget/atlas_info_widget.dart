import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:glitters/glitters.dart';
import 'package:shimmer/shimmer.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/atlas/atlas_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/atlas/burn_history_page.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_reward_tabs_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_create_wallet_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/pages/node/model/map3_node_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/image_util.dart';
import 'package:titan/src/widget/wallet_widget.dart';

class AtlasInfoWidget extends StatefulWidget {
  AtlasInfoWidget();

  @override
  State<StatefulWidget> createState() {
    return _AtlasInfoWidgetState();
  }
}

class _AtlasInfoWidgetState extends State<AtlasInfoWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 32,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              InkWell(
                child: Row(
                  children: [
                    Image.asset(
                      'res/drawable/ic_burn.png',
                      width: 15,
                      height: 15,
                      color: HexColor('#FFFF5151'),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      S.of(context).hyn_burning,
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    )
                  ],
                ),
                onTap: () {
                  Application.router.navigateTo(context, Routes.map3node_burn_history_page);
                },
              ),
              Spacer(),
              InkWell(
                onTap: () {
                  var activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext)?.activatedWallet;
                  var _address = activatedWallet?.wallet?.getEthAccount()?.address ?? "";
                  if (_address.isEmpty) {
                    Application.router.navigateTo(
                        context,
                        Routes.map3node_create_wallet +
                            "?pageType=${Map3NodeCreateWalletPage.CREATE_WALLET_PAGE_TYPE_JOIN}");
                    return;
                  }

                  Application.router.navigateTo(context, Routes.map3node_my_page_reward_new);
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        Center(
                          child: Image.asset(
                            'res/drawable/ic_hyn_coin.png',
                            width: 17,
                            height: 17,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0, top: 4),
                          child: Container(
                            width: 10,
                            height: 10,
                            child: Glitters(
                              duration: Duration(
                                milliseconds: 600,
                              ),
                              maxOpacity: 0.5,
                              color: HexColor('#FFE4D17E'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 4.0),
                      child: Text(
                        S.of(context).my_reward,
                        style: TextStyle(
                          color: HexColor('#FFE4D17E'),
                          fontSize: 11,
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(
                      S.of(context).atlas_node,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      '${AtlasInheritedModel.of(context).committeeInfo?.candidate?.toString() ?? '---'}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 20,
                width: 1,
                color: DefaultColors.color999,
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(
                      S.of(context).map3_node,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      '${AtlasInheritedModel.of(context).atlasHomeEntity?.map3Count?.toString() ?? '---'}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 20,
                width: 1,
                color: DefaultColors.color999,
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(
                      S.of(context).block_height,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    InkWell(
                      child: Shimmer.fromColors(
                        period: Duration(milliseconds: 3000),
                        baseColor: Colors.white,
                        highlightColor: HexColor('#3D444A'),
                        child: Text(
                          '${AtlasInheritedModel.of(context).committeeInfo?.blockNum?.toString() ?? '---'}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            //color: Colors.blue,
                            //decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              Container(
                height: 20,
                width: 1,
                color: DefaultColors.color999,
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(
                      S.of(context).atlas_current_age,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      '${AtlasInheritedModel.of(context).committeeInfo?.epoch?.toString() ?? '---'}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
