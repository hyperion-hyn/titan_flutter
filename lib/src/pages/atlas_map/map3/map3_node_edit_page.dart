import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_message.dart';
import 'package:titan/src/pages/atlas_map/entity/create_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'map3_node_confirm_page.dart';
import 'map3_node_public_widget.dart';

class Map3NodeEditPage extends StatefulWidget {
  final Map3InfoEntity entity;

  Map3NodeEditPage({this.entity});

  @override
  _Map3NodeEditState createState() => new _Map3NodeEditState();
}


class _Map3NodeEditState extends State<Map3NodeEditPage> with WidgetsBindingObserver {
  CreateMap3Payload _payload;


  var _localImagePath = "";
  var _titleList = [
    S.of(Keys.rootKey.currentContext).name,
    S.of(Keys.rootKey.currentContext).node_num,
    S.of(Keys.rootKey.currentContext).website,
    S.of(Keys.rootKey.currentContext).contact,
    S.of(Keys.rootKey.currentContext).description,
  ];
  List<String> _detailList = ["", "", "", "", ""];
  List<String> _hintList = [
    S.of(Keys.rootKey.currentContext).please_enter_node_name,
    S.of(Keys.rootKey.currentContext).please_input_node_num,
    S.of(Keys.rootKey.currentContext).please_enter_node_address,
    S.of(Keys.rootKey.currentContext).please_input_node_contact,
    S.of(Keys.rootKey.currentContext).please_enter_node_description
  ];

  @override
  void initState() {
    _setupData();
    _setupPayload();
    super.initState();
  }

  _setupPayload() async {
    var blsKeySignEntity = await AtlasApi().getMap3Bls();
    print("[dd0] payload.toJson():${widget.entity.toJson()}");

    var payload = CreateMap3Payload.onlyNodeId(widget.entity.nodeId);
    payload.name = widget.entity.name;
    payload.nodeId = widget.entity.nodeId;
    payload.home = widget.entity.home;
    payload.connect = widget.entity.contact;
    payload.describe = widget.entity.describe;
    payload.isEdit = true;
    payload.nodeId = null;

    print("[dd1] payload.toJson():${payload.toJson()}");

    //payload.blsRemoveKey = widget?.entity?.blsKey ?? "";
    payload.blsRemoveKey = null;
    payload.blsAddSign = blsKeySignEntity?.blsSign ?? "";
    payload.blsAddKey = blsKeySignEntity?.blsKey ?? "";
    print("[dd2] payload.toJson():${payload.toJson()}");

    _payload = payload;

  }

  _setupData() {
    var entity = widget.entity;

    if (entity.name?.isNotEmpty ?? false) {
      _detailList[0] = entity.name;
    }

    if (entity.nodeId?.isNotEmpty ?? false) {
      _detailList[1] = entity.nodeId;
    }

    if (entity.home?.isNotEmpty ?? false) {
      _detailList[2] = entity.home;
    }

    if (entity.contact?.isNotEmpty ?? false) {
      _detailList[3] = entity.contact;
    }

    if (entity.describe?.isNotEmpty ?? false) {
      _detailList[4] = entity.describe;
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
        baseTitle: S.of(context).edit_map3,
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
                      Expanded(
                          child: Text("${AtlasApi.map3introduceEntity.name}",
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          child: Text(S.of(context).detailed_introduction,
                              style: TextStyle(
                                  fontSize: 14, color: HexColor("#1F81FF"))),
                          onTap: () {
                            AtlasApi.goToAtlasMap3HelpPage(context);
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

                        Text(S.of(context).activate_need_1m,
                            style: TextStyles.textC99000000S13,
                            maxLines: 1,
                            softWrap: true),

                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(" (HYN) ",
                              style: TextStyle(
                                  fontSize: 10, color: HexColor("#999999"))),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text("  |  ",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: HexColor("000000").withOpacity(0.2))),
                        ),
                        Text(S.of(context).n_day(AtlasApi.map3introduceEntity.days), style: TextStyles.textC99000000S13)

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
          var subTitle = index < 2 ? "" : "（${S.of(context).optional_input}）";
          var title = _titleList[index];
          var detail = _detailList[index];
          var hint = _hintList[index];
          var keyboardType = TextInputType.text;

          switch (index) {
            case 2:
              keyboardType = TextInputType.url;
              break;

            case 3:
              keyboardType = TextInputType.phone;
              break;

            case 4:
              break;
          }

          return editInfoItem(
            context,
            index,
            title,
            hint,
            detail,
            ({String value}) {
              if (index == 0) {
                setState(() {
                  _localImagePath = value;
                  _detailList[index] = value;
                });
              } else {
                setState(() {
                  _detailList[index] = value;
                });
              }
            },
            keyboardType: keyboardType,
            subtitle: subTitle,
            hasSubtitle: false,
            canEdit: title != "节点号",
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
          if (_detailList[0].isEmpty) {
            Fluttertoast.showToast(msg: _hintList[0]);
            return;
          }

          if (_detailList[1].isEmpty) {
            Fluttertoast.showToast(msg: _hintList[1]);
            return;
          }

          var map3NodeAddress = widget?.entity?.address ?? "";
          if (map3NodeAddress.isEmpty) {
            return;
          }

          for (var index = 0; index < _titleList.length; index++) {
            var title = _titleList[index];
            if (title == S.of(Keys.rootKey.currentContext).name) {
              _payload.name = _detailList[0];

            } else if (title == S.of(Keys.rootKey.currentContext).node_num) {
              //_payload.nodeId = _detailList[1];
            } else if (title == S.of(Keys.rootKey.currentContext).website) {

              _payload.home = _detailList[2];
            } else if (title == S.of(Keys.rootKey.currentContext).contact) {
              _payload.connect = _detailList[3];
            } else if (title == S.of(Keys.rootKey.currentContext).description) {
              _payload.describe = _detailList[4];
            }
          }

          _payload.isEdit = true;

          CreateMap3Entity map3entity =
              CreateMap3Entity.onlyType(AtlasActionType.EDIT_MAP3_NODE);
          map3entity.payload = _payload;

          var message = ConfirmEditMap3NodeMessage(entity: map3entity, map3NodeAddress: map3NodeAddress);


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
