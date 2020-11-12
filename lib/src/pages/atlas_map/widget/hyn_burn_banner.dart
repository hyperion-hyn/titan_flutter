import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/atlas/atlas_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/atlas/burn_history_page.dart';
import 'package:titan/src/pages/atlas_map/entity/burn_history.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/pages/node/model/map3_node_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/image_util.dart';
import 'package:titan/src/widget/wallet_widget.dart';

class HynBurnBanner extends StatefulWidget {
  HynBurnBanner();

  @override
  State<StatefulWidget> createState() {
    return _HynBurnBannerState();
  }
}

class _HynBurnBannerState extends State<HynBurnBanner> {
  BurnMsg _burnMsg;
  AtlasApi _atlasApi = AtlasApi();

  @override
  void initState() {
    super.initState();
    _getBurnMsg();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getBurnMsg() async {
    try {
      _burnMsg = await _atlasApi.postBurnMsg();
      setState(() {});
    } catch (e) {}
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => BurnHistoryPage(),
        ));
      },
      child: _burnMsg != null
          ? Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Container(
                height: 50,
                child: Stack(
                  children: [
                    Image.asset(
                      'res/drawable/bg_banner_hyn_burn.png',
                      height: 50,
                    ),
                    Container(
                      height: 50,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                          ),
                          Expanded(
                            child: Text(
                              '第${_burnMsg.latestBurnHistory?.epoch}纪元 HYN燃烧完成',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Image.asset(
                              'res/drawable/ic_rounded_arrow.png',
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Container(),
    );
  }
}
