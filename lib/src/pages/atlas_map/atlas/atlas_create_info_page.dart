import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_create_confirm_page.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_message.dart';
import 'package:titan/src/pages/atlas_map/entity/create_atlas_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/pages/atlas_map/entity/test_entity.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_confirm_page.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/round_border_textfield.dart';

typedef TextChangeCallback = void Function(String text);

class AtlasCreateInfoPage extends StatefulWidget {
  final CreateAtlasPayload _createAtlasPayload;

  AtlasCreateInfoPage(
    this._createAtlasPayload,
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
      appBar: BaseAppBar(
        baseTitle: '确认创建节点',
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            'Lance的Map3节点',
            style: TextStyle(
              fontSize: 14,
            ),
          ),
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: Image.asset(
                    widget._createAtlasPayload.pic,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                )
              ],
            ),
          ),
          _optionItem(
            '名称',
            widget._createAtlasPayload.name,
          ),
          _optionItem(
            '节点号',
            widget._createAtlasPayload.nodeId,
          ),
          _optionItem(
            '最大抵押量',
            '${widget._createAtlasPayload.maxStaking}',
          ),
          _optionItem(
            '网址',
            widget._createAtlasPayload.home,
          ),
          _optionItem(
            '安全联系',
            widget._createAtlasPayload.contact,
          ),
          _optionItem(
            '描述',
            widget._createAtlasPayload.describe,
          ),
          _divider(),
          _optionItem(
            '费率',
            '${widget._createAtlasPayload.feeRate} %',
          ),
          _optionItem(
            '最大费率',
            '${widget._createAtlasPayload.feeRateMax} %',
          ),
          _optionItem(
            '费率幅度',
            '${widget._createAtlasPayload.feeRateTrim} %',
          ),
          _divider(),
          _optionItem(
            'bls key',
            widget._createAtlasPayload.blsAddKey,
          ),
          _optionItem(
            'bls 签名',
            widget._createAtlasPayload.blsAddSign,
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
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
      child: ClickOvalButton(
        S.of(context).submit,
        () {
          CreateAtlasEntity createAtlasEntity = CreateAtlasEntity.onlyType(
            AtlasActionType.CREATE_ATLAS_NODE,
          )..payload = widget._createAtlasPayload;

          AtlasMessage message = ConfirmCreateAtlasNodeMessage(
            entity: createAtlasEntity,
          );

          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Map3NodeConfirmPage(
                  message: message,
                ),
              ));

//          Application.router.navigateTo(
//            context,
//            Routes.atlas_create_node_confirm_page +
//                '?createAtlasPayload=${FluroConvertUtils.object2string(widget._createAtlasPayload)}',
//          );
        },
        width: 300,
        height: 46,
        fontSize: 18,
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
