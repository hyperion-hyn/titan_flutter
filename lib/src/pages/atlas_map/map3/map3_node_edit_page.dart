import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_message.dart';
import 'package:titan/src/pages/atlas_map/entity/create_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_introduce_entity.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'map3_node_confirm_page.dart';
import 'map3_node_public_widget.dart';

class Map3NodeEditPage extends StatefulWidget {
  final Map3InfoEntity map3InfoEntity;

  Map3NodeEditPage({this.map3InfoEntity});

  @override
  _Map3NodeEditState createState() => _Map3NodeEditState();
}

class _Map3NodeEditState extends State<Map3NodeEditPage> with WidgetsBindingObserver {
  var _titleList = [
    S.of(Keys.rootKey.currentContext).node_num,
    S.of(Keys.rootKey.currentContext).name,
    S.of(Keys.rootKey.currentContext).contact,
    S.of(Keys.rootKey.currentContext).website,
    S.of(Keys.rootKey.currentContext).description,
  ];
  List<String> _detailList = ["", "", "", "", ""];
  List<String> _hintList = [
    S.of(Keys.rootKey.currentContext).please_input_node_num,
    S.of(Keys.rootKey.currentContext).please_enter_node_name,
    S.of(Keys.rootKey.currentContext).please_input_node_contact,
    S.of(Keys.rootKey.currentContext).please_enter_node_address,
    S.of(Keys.rootKey.currentContext).please_enter_node_description
  ];

  Map3IntroduceEntity _map3introduceEntity;
  CreateMap3Payload _payload = CreateMap3Payload.onlyEditType(editType: 1);

  @override
  void initState() {
    _setupData();

    super.initState();
  }

  /*
  _setupPayload() async {
    print("[dd0] payload.toJson():${widget.map3InfoEntity.toJson()}");
    
    // payload.name = widget.entity.name;
    // payload.nodeId = widget.entity.nodeId;
    // payload.home = widget.entity.home;
    // payload.connect = widget.entity.contact;
    // payload.describe = widget.entity.describe;
    // payload.isEdit = true;

    //print("[dd1] payload.toJson():${payload.toJson()}");

    var blsKeySignEntity = await AtlasApi().getMap3Bls();
    _payload.blsRemoveKey = widget?.map3InfoEntity?.blsKey;
    _payload.blsAddSign = blsKeySignEntity?.blsSign ?? "";
    _payload.blsAddKey = blsKeySignEntity?.blsKey ?? "";
    print("[dd2] payload.toJson():${_payload.toJson()}");
  }
  */

  _setupData() async {
    var entity = widget.map3InfoEntity;

    if (entity.nodeId?.isNotEmpty ?? false) {
      _detailList[0] = entity.nodeId;
    }

    if (entity.name?.isNotEmpty ?? false) {
      _detailList[1] = entity.name;
    }

    if (entity.contact?.isNotEmpty ?? false) {
      _detailList[2] = entity.contact;
    }

    if (entity.home?.isNotEmpty ?? false) {
      _detailList[3] = entity.home;
    }

    if (entity.describe?.isNotEmpty ?? false) {
      _detailList[4] = entity.describe;
    }

    _map3introduceEntity = await AtlasApi.getIntroduceEntity();
    setState(() {});
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
                          child: Text("${_map3introduceEntity?.name ?? ''}",
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          child: Text(S.of(context).detailed_introduction,
                              style: TextStyle(fontSize: 14, color: HexColor("#1F81FF"))),
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
                        Text(
                            S.of(context).active_still_need +
                                " ${FormatUtil.formatTenThousandNoUnit(_map3introduceEntity?.startMin?.toString() ?? "0")}" +
                                S.of(context).ten_thousand,
                            style: TextStyles.textC99000000S13,
                            maxLines: 1,
                            softWrap: true),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(" (HYN) ", style: TextStyle(fontSize: 10, color: HexColor("#999999"))),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child:
                              Text("  |  ", style: TextStyle(fontSize: 12, color: HexColor("000000").withOpacity(0.2))),
                        ),
                        Text(S.of(context).n_day(_map3introduceEntity?.days ?? '180'),
                            style: TextStyles.textC99000000S13)
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
          var subTitle = index < 3 ? "" : "（${S.of(context).optional_input}）";
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
              var last = _detailList[index];
              if (last != value && value.isNotEmpty) {
                setState(() {
                  _detailList[index] = value;
                });
              }
            },
            keyboardType: keyboardType,
            subtitle: subTitle,
            hasSubtitle: false,
            canEdit: title != _titleList[0],
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

          if (_detailList[2].isEmpty) {
            Fluttertoast.showToast(msg: _hintList[2]);
            return;
          }

          var map3NodeAddress = widget?.map3InfoEntity?.address ?? "";
          print("map3NodeAddress: $map3NodeAddress");

          if (map3NodeAddress.isEmpty) {
            Fluttertoast.showToast(msg: '新创建的节点暂时不支持修改');
            return;
          }


          var isEdit = false;
          for (var index = 0; index < _titleList.length; index++) {
            var title = _titleList[index];

            if (title == S.of(Keys.rootKey.currentContext).node_num) {
              var last = widget.map3InfoEntity.nodeId;
              var edit = _detailList[0];
              if (last != edit) {
                _payload.nodeId = edit;

                if (!isEdit) {
                  isEdit = true;
                }
              }
            } else if (title == S.of(Keys.rootKey.currentContext).name) {
              var last = widget.map3InfoEntity.name;
              var edit = _detailList[1];
              if (last != edit) {
                _payload.name = edit;

                if (!isEdit) {
                  isEdit = true;
                }
              }
            } else if (title == S.of(Keys.rootKey.currentContext).contact) {
              var last = widget.map3InfoEntity.contact;
              var edit = _detailList[2];
              if (last != edit) {
                _payload.connect = edit;

                if (!isEdit) {
                  isEdit = true;
                }
              }
            } else if (title == S.of(Keys.rootKey.currentContext).website) {
              var last = widget.map3InfoEntity.home;
              var edit = _detailList[3];
              if (last != edit) {
                _payload.home = edit;

                if (!isEdit) {
                  isEdit = true;
                }
              }
            } else if (title == S.of(Keys.rootKey.currentContext).description) {
              var last = widget.map3InfoEntity.describe;
              var edit = _detailList[4];
              if (last != edit) {
                _payload.describe = edit;

                if (!isEdit) {
                  isEdit = true;
                }
              }
            }
          }

          if (!isEdit) {
            Fluttertoast.showToast(msg: '未修改节点信息');
            return;
          }

          print("[_payload] --->map3NodeAddress:$map3NodeAddress, payload: ${_payload.toJson()}");

          CreateMap3Entity map3entity = CreateMap3Entity.onlyType(AtlasActionType.EDIT_MAP3_NODE);
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
