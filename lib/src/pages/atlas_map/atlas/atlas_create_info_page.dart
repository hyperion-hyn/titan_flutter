import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_create_confirm_page.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/click_oval_button.dart';
import 'package:titan/src/widget/round_border_textfield.dart';

typedef TextChangeCallback = void Function(String text);

class AtlasCreateInfoPage extends StatefulWidget {
  AtlasCreateInfoPage();

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
          '确认创建Atlas节点',
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
                Container(
                  width: 40,
                  height: 40,
                  color: Colors.greenAccent,
                )
              ],
            ),
          ),
          _optionItem(
            '名称',
            'Lance的Atlas节点',
          ),
          _optionItem(
            '节点号',
            '123123123131',
          ),
          _optionItem(
            '最大抵押量',
            '10000000000000',
          ),
          _optionItem(
            '网址',
            'http://hyn.space',
          ),
          _optionItem(
            '安全联系',
            '1231314',
          ),
          _optionItem(
            '描述',
            '快来加入我的节点吧',
          ),
          _divider(),
          _optionItem(
            '费率',
            '20%',
          ),
          _optionItem(
            '最大费率',
            '40%',
          ),
          _optionItem(
            '费率幅度',
            '5%',
          ),
          _divider(),
          _optionItem(
            'bls key',
            'afagangrgragjksarghsajrghsakjgsrk',
          ),
          _optionItem(
            'bls 签名',
            'skdajvaneruhcalrvanivawpeofjarvuasdfsdfsdfdsfsfsdfsfsfs',
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
              child: Text(content),
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
        width: 100,
        height: 40,
      ),
    );
  }

  _divider() {
    return Container(
      height: 8,
      color: Colors.grey[200],
    );
  }
}
