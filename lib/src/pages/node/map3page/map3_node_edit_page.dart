import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/wallet/wallet_setting.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'map3_node_pronounce_page.dart';
import 'map3_node_public_widget.dart';

class Map3NodeEditPage extends StatefulWidget {
  final Map3InfoEntity entity;
  Map3NodeEditPage({this.entity});

  @override
  _Map3NodeEditState createState() => new _Map3NodeEditState();
}

class _Map3NodeEditState extends State<Map3NodeEditPage> with WidgetsBindingObserver {
  Map3InfoEntity _map3InfoEntity = Map3InfoEntity.onlyId(1);

  var _editText = "";
  var _localImagePath = "";
  var _titleList = ["图标", "名称", "节点号", "网址", "安全联系", "描述"];
  List<String> _detailList = ["", "", "", "", "", ""];
  List<String> _hintList = ["请选择节点图标", "请输入节点名称", "请输入节点号", "请输入节点网址", "请输入节点的联系方式", "请输入节点描述"];

  @override
  void initState() {
    _setupData();
    super.initState();
  }

  _setupData() {
    _titleList = [];
    _detailList = [];

    var entity = widget.entity;
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

    if (entity.home?.isNotEmpty ?? false) {
      _titleList.add("网址");
      _detailList.add(entity.home);
    }

    if (entity.contact?.isNotEmpty ?? false) {
      _titleList.add("安全联系");
      _detailList.add(entity.contact);
    }

    if (entity.describe?.isNotEmpty ?? false) {
      _titleList.add("描述");
      _detailList.add(entity.describe);
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: '编辑Map3节点',
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
        Expanded(
          child: BaseGestureDetector(
            context: context,
            child: CustomScrollView(
              slivers: <Widget>[
                _headerWidget(),
                _contentWidget(),
              ],
            ),
          ),
        ),
        _confirmButtonWidget(),
      ],
    );
  }

  Widget _nodeServerWidget() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          //mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Image.asset(
              "res/drawable/ic_map3_node_item_2.png",
              width: 62,
              height: 62,
              fit: BoxFit.cover,
            ),
            SizedBox(
              width: 12,
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Expanded(child: Text("Map3云节点（V1.0）", style: TextStyle(fontWeight: FontWeight.bold))),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          child: Text("详细介绍", style: TextStyle(fontSize: 14, color: HexColor("#1F81FF"))),
                          onTap: () {
                            String webUrl = FluroConvertUtils.fluroCnParamsEncode("http://baidu.com");
                            String webTitle = FluroConvertUtils.fluroCnParamsEncode("详细介绍");
                            Application.router.navigateTo(
                                context, Routes.toolspage_webview_page + '?initUrl=$webUrl&title=$webTitle');
                          },
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("启动所需100万  ", style: TextStyles.textC99000000S13, maxLines: 1, softWrap: true),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(" (HYN) ", style: TextStyle(fontSize: 10, color: HexColor("#999999"))),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child:
                              Text("  |  ", style: TextStyle(fontSize: 12, color: HexColor("000000").withOpacity(0.2))),
                        ),
                        Text(S.of(context).n_day("180"), style: TextStyles.textC99000000S13)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerWidget() {
    var divider = Container(
      color: HexColor("#F4F4F4"),
      height: 8,
    );

    return SliverToBoxAdapter(
      child: Container(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _nodeServerWidget(),
          divider,
        ]),
      ),
    );
  }

  Widget _contentWidget() {
    return SliverToBoxAdapter(
      child: ListView.separated(
        itemBuilder: (context, index) {
          var subTitle = index < 3 ? "" : "（选填）";
          var title = _titleList[index];
          var detail = _detailList[index];
          var hint = _hintList[index];
          var keyboardType = TextInputType.text;

          switch (index) {
            case 3:
              keyboardType = TextInputType.url;
              break;

            case 4:
              keyboardType = TextInputType.phone;
              break;

            case 5:
              break;
          }

          return editInfoItem(context, index, title, hint, detail, ({String value}){
            if (index == 0) {
              setState(() {
                _localImagePath = value;
              });
            } else {
              setState(() {
                _detailList[index] = value;
              });
            }
          }, keyboardType: keyboardType, subtitle: subTitle, hasSubtitle: false);
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
          if (_localImagePath.isEmpty) {
            Fluttertoast.showToast(msg: _hintList[0]);
            return;
          }

          if (_detailList[1].isEmpty) {
            Fluttertoast.showToast(msg: _hintList[1]);
            return;
          }

          if (_detailList[2].isEmpty) {
            Fluttertoast.showToast(msg: _hintList[2]);
            return;
          }

          for (var index = 0; index < _titleList.length; index++) {
            var title = _titleList[index];
            if (title == "图标") {
              _map3InfoEntity.pic = _localImagePath;
            } else if (title == "名称") {
              _map3InfoEntity.name = _detailList[1];
            } else if (title == "节点号") {
              _map3InfoEntity.nodeId = _detailList[2];
            } else if (title == "网址") {
              _map3InfoEntity.home = _detailList[3];
            } else if (title == "安全联系") {
              _map3InfoEntity.contact = _detailList[4];
            } else if (title == "描述") {
              _map3InfoEntity.describe = _detailList[5];
            }
          }
          var encodeEntity = FluroConvertUtils.object2string(_map3InfoEntity.toJson());
          Application.router.navigateTo(context, Routes.map3node_create_confirm_page + "?entity=$encodeEntity");
        },
        height: 46,
        width: MediaQuery.of(context).size.width - 37 * 2,
        fontSize: 18,
      ),
    );
  }
}
