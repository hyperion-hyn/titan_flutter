import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';

class Map3AtlasIntroductionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Map3AtlasIntroductionState();
  }
}

class _Map3AtlasIntroductionState extends State<Map3AtlasIntroductionPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Color(0xfff5f5f5),
      color: Colors.white,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(child: _atlasLogoItem()),
          SliverToBoxAdapter(child: _atlasIndroductionItem()),
        ],
      ),
    );
  }

  Widget _atlasLogoItem() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      child: Stack(
        children: <Widget>[
          Image.asset("res/drawable/atlas_logo.png"),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(S.of(context).atlas_consensus_node, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),),
                SizedBox(height: 2,),
                Text(S.of(context).consensus_guarantee_for_hyberion, style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.white),),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _atlasIndroductionItem() {
    var instroduction = S.of(context).home_atlas_description;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 18, bottom: 8),
            child: Text(S.of(context).about_atlas_node, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: HexColor("#333333")),),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Text(instroduction, style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: HexColor("#999999"), height: 2)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Text(S.of(context).stay_tuned, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: HexColor("#333333")),),
          ),
        ],
      ),
    );
  }
}
