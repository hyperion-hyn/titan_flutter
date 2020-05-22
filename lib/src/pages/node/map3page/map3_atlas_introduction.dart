import 'package:flutter/material.dart';
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
      color: Color(0xfff5f5f5),
      //color: Color(0xffFDFAFF),
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
                Text("Atlas共识节点", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),),
                SizedBox(height: 2,),
                Text("为海伯利安生态提供公式保证", style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.white),),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _atlasIndroductionItem() {
    var instroduction = '''
    Atlas是以空间共识和弹性空间分片为主要特征的高性能地图区块链，可解决空间分片，账户资产转移，资产确认等与空间相关的服务需求。具有抗审查、开放参与、高容错等特点。未来待Atlas链搭建完成，将支持海伯利安成为服务100亿人的去中心化全球地图经济体系。

Atlas将在技术上实现高可伸缩性、低延迟性、低成本、隐私保护、可扩展性和交互性，支持全球体量巨大的地图定位请求和位置搜索请求。未来主网上线之时，用户将能成为Atlas节点，参与提升区块链网络的安全、性能等，并获得HYN奖励。Atlas节点的奖励细则还有待确认，但将与Map3网络的边缘节点以及核心节点关联统一。
    ''';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 18, bottom: 8),
            child: Text("关于Atlas共识节点", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: HexColor("#333333")),),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Text(instroduction, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: HexColor("#333333")),),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 18, bottom: 16),
            child: Text("敬请期待！", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: HexColor("#333333")),),
          ),
        ],
      ),
    );
  }
}
