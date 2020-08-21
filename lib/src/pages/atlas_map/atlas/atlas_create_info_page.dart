import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_create_confirm_page.dart';
import 'package:titan/src/pages/atlas_map/entity/test_entity.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/round_border_textfield.dart';

typedef TextChangeCallback = void Function(String text);

class AtlasCreateInfoPage extends StatefulWidget {
  final AtlasNode _atlasNode;

  AtlasCreateInfoPage(
    this._atlasNode,
  );

  @override
  State<StatefulWidget> createState() {
    return _AtlasCreateInfoPageState();
  }
}

class _AtlasCreateInfoPageState extends State<AtlasCreateInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          '确认创建节点',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ),
      body: _nodeSetupInfo(),
    );
  }

  _nodeSetupInfo() {
    return Container(
      color: Colors.white,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '你即将要创建如下Atlas节点',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _divider(),
          ),
          SliverToBoxAdapter(
            child: _map3Info(),
          ),
          SliverToBoxAdapter(
            child: _divider(),
          ),
          SliverToBoxAdapter(
            child: _nodeOptions(),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 32,
            ),
          ),
          SliverToBoxAdapter(
            child: _confirm(),
          )
        ],
      ),
    );
  }

  _map3Info() {
    return Row(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '复抵押的map3节点',
            style: TextStyle(
              color: DefaultColors.color999,
            ),
          ),
        ),
        Expanded(
          child: Text('Lance的Map3节点'),
        )
      ],
    );
  }

  _nodeOptions() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 100,
                  child: Text(
                    '图标',
                    style: TextStyle(
                      color: DefaultColors.color999,
                    ),
                  ),
                ),
                Image.asset(
                  widget._atlasNode.logoPath,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
              ],
            ),
          ),
          _optionItem(
            '名称',
            widget._atlasNode.name,
          ),
          _optionItem(
            '节点号',
            widget._atlasNode.identifier,
          ),
          _optionItem(
            '最大抵押量',
            widget._atlasNode.maxStakingAmount,
          ),
          _optionItem(
            '网址',
            widget._atlasNode.website,
          ),
          _optionItem(
            '安全联系',
            widget._atlasNode.contact,
          ),
          _optionItem(
            '描述',
            widget._atlasNode.description,
          ),
          _divider(),
          _optionItem(
            '费率',
            '${widget._atlasNode.fee} %',
          ),
          _optionItem(
            '最大费率',
            '${widget._atlasNode.maxFee} %',
          ),
          _optionItem(
            '费率幅度',
            '${widget._atlasNode.maxFee} %',
          ),
          _divider(),
          _optionItem(
            'bls key',
            widget._atlasNode.blsKey,
          ),
          _optionItem(
            'bls 签名',
            widget._atlasNode.blsSign,
          ),
        ],
      ),
    );
  }

  _optionItem(
    String name,
    String content,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 100,
            child: Text(
              name,
              style: TextStyle(
                color: DefaultColors.color999,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                content ?? '无',
              ),
            ),
          ),
        ],
      ),
    );
  }

  _confirm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ClickOvalButton(
        '提交',
        () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AtlasNodeCreateConfirmPage(),
              ));
        },
        width: 300,
        height: 46,
      ),
    );
  }

  _divider() {
    return Container(
      height: 8,
      color: HexColor('#FFF2F2F2'),
    );
  }
}
