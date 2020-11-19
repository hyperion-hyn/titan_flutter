import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/atlas/burn_history_page.dart';
import 'package:titan/src/pages/atlas_map/entity/burn_history.dart';

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
    var round = _burnMsg?.latestBurnHistory?.id;
    var msg = round != null ? '第$round轮 HYN燃烧完成' : '';
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => BurnHistoryPage(),
        ));
      },
      child: Padding(
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
                height: 60,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                    ),
                    Expanded(
                      child: Text(
                        msg,
                        style: TextStyle(
                          fontSize: 13,
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
      ),
    );
  }
}
