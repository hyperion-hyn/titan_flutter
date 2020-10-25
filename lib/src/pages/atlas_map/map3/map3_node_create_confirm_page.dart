import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_message.dart';
import 'package:titan/src/pages/atlas_map/entity/create_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'map3_node_confirm_page.dart';

class Map3NodeCreateConfirmPage extends StatefulWidget {
  final CreateMap3Payload payload;

  Map3NodeCreateConfirmPage({this.payload});

  @override
  _Map3NodeCreateConfirmState createState() =>
      new _Map3NodeCreateConfirmState();
}

class _Map3NodeCreateConfirmState extends State<Map3NodeCreateConfirmPage> {
  List<String> _titleList = [
    "图标",
    "名称",
    "节点号",
    "首次抵押",
    "管理费",
    "网址",
    "安全联系",
    "描述",
    "云服务商",
    "节点地址"
  ];
  List<String> _detailList = [
    "",
    "派大星",
    "PB2020",
    "200,000 HYN",
    "20%",
    "www.hyn.space",
    "12345678901",
    "欢迎参加我的合约，前10名参与者返10%管理。",
    "亚马逊云",
    "美国东部（弗吉尼亚北部）"
  ];
  AtlasApi _atlasApi = AtlasApi();

  @override
  void initState() {
    _setupData();
    super.initState();
  }

  _setupData() {
    _titleList = [];
    _detailList = [];

    var entity = widget.payload;
    if (entity.pic?.isNotEmpty ?? false) {
      _titleList.add("图标");
      _detailList.add(entity.pic);
    }

    if (entity.name?.isNotEmpty ?? false) {
      _titleList.add("名称");
      _detailList.add(entity.name);
    }

    if (entity.nodeId?.isNotEmpty ?? false) {
      _titleList.add("节点号");
      _detailList.add(entity.nodeId);
    }

    if (entity.staking?.isNotEmpty ?? false) {
      _titleList.add("首次抵押");
      _detailList.add(entity.staking);
    }

    if (entity.feeRate?.isNotEmpty ?? false) {
      _titleList.add("管理费");
      _detailList.add(entity.feeRate + "%");
    }

    if (entity.home?.isNotEmpty ?? false) {
      _titleList.add("网址");
      _detailList.add(entity.home);
    }

    if (entity.connect?.isNotEmpty ?? false) {
      _titleList.add("安全联系");
      _detailList.add(entity.connect);
    }

    if (entity.describe?.isNotEmpty ?? false) {
      _titleList.add("描述");
      _detailList.add(entity.describe);
    }

    if (entity.providerName?.isNotEmpty ?? false) {
      _titleList.add("云服务商");
      _detailList.add(entity.providerName);
    }

    if (entity.regionName?.isNotEmpty ?? false) {
      _titleList.add("节点选址");
      _detailList.add(entity.regionName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: widget.payload.isEdit ? '确认编辑节点' : '确认创建节点',
      ),
      backgroundColor: Colors.white,
      body: _pageView(context),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _pageView(BuildContext context) {
    return Column(
      children: <Widget>[
        _headerWidget(),
        Expanded(
          child: CustomScrollView(
            slivers: <Widget>[
              _contentWidget(),
            ],
          ),
        ),
        _confirmButtonWidget(),
      ],
    );
  }

  Widget _headerWidget() {
    return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              "你即将要${widget.payload.isEdit ? "编辑" : "创建"}如下Map3节点",
              style: TextStyle(
                color: HexColor("#333333"),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ));
  }

  Widget _contentWidget() {
    return SliverToBoxAdapter(
      child: ListView.separated(
        itemBuilder: (context, index) {
          var title = _titleList[index];
          var detail = _detailList[index];

          return Container(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: detail.isNotEmpty ? 18 : 14, horizontal: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 100,
                    child: Text(
                      title,
                      style:
                          TextStyle(color: HexColor("#999999"), fontSize: 14),
                    ),
                  ),
                  title != "图标"
                      ? Expanded(
                          child: Text(
                            detail,
                            style: TextStyle(
                                color: HexColor("#333333"), fontSize: 14),
                          ),
                        )
                      : Image.asset(
                          detail ?? "res/drawable/ic_map3_node_item_2.png",
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                        ),

                  //Spacer(),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return Divider(
            height: 0.5,
            color: HexColor("#F2F2F2"),
          );
        },
        itemCount: _detailList.length,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
      ),
    );
  }

  Widget _confirmButtonWidget() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 37, vertical: 18),
      child: ClickOvalButton(
        S.of(context).submit,
        () async {
          /*
          // 1.上传图片 ---> 获取url
          String result = await _atlasApi.postUploadImageFile(widget.entity.pic,
              (count, total) {
            print("[object] ---> count:$count, total:$total");
          });
          print("[object] ---> result:$result");
        */

          // 2.编辑创建节点需要的基本信息
          AtlasMessage message;
          if (!widget.payload.isEdit) {
            CreateMap3Entity map3entity =
                CreateMap3Entity.onlyType(AtlasActionType.CREATE_MAP3_NODE);
            map3entity.payload = widget.payload;
            map3entity.amount = widget.payload.staking;
            message = ConfirmCreateMap3NodeMessage(entity: map3entity);
          } else {
            CreateMap3Entity map3entity =
                CreateMap3Entity.onlyType(AtlasActionType.EDIT_MAP3_NODE);
            map3entity.payload = widget.payload;
            message = ConfirmEditMap3NodeMessage(
                entity: map3entity, map3NodeAddress: "");
          }

          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Map3NodeConfirmPage(
                  message: message,
                ),
              ));
        },
        height: 46,
        width: MediaQuery.of(context).size.width - 37 * 2,
        fontSize: 18,
      ),
    );
  }
}
