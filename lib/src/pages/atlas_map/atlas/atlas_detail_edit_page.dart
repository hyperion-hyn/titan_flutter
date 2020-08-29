import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_stake_select_page.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_info_entity.dart';
import 'package:titan/src/pages/node/map3page/map3_node_pronounce_page.dart';
import 'package:titan/src/pages/node/map3page/map3_node_public_widget.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/pages/wallet/wallet_setting.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/round_border_textfield.dart';

class AtlasDetailEditPage extends StatefulWidget {
  final AtlasInfoEntity _atlasInfoEntity;

  AtlasDetailEditPage(this._atlasInfoEntity);

  @override
  State<StatefulWidget> createState() {
    return _AtlasDetailEditPageState();
  }
}

class _AtlasDetailEditPageState extends State<AtlasDetailEditPage> {
  var _editText = "";
  var _localImagePath = "";
  List<String> _detailList = [];
  var _titleList = [];
  List<dynamic> _hintList = ["请选择节点图标", "请输入节点名称", "请输入节点号", "请输入节点网址", "请输入节点的联系方式", "请输入节点描述"];

  TextEditingController _rateCoinController = new TextEditingController();
  int _managerSpendCount = 20;

  TextEditingController _blsKeyTextController = TextEditingController();
  TextEditingController _blsSignTextController = TextEditingController();

  @override
  void initState() {
    _refreshData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(baseTitle: ""),
      body: _pageWidget(context),
    );
  }

  Widget _pageWidget(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              // hide keyboard when touch other widgets
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                    child: Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: stakeHeaderInfo(context, widget._atlasInfoEntity),
                )),
                _contentWidget(),
                settingFees(),
                settingBLS(),
              ],
            ),
          ),
        ),
        _confirmButtonWidget(),
      ],
    );
  }

  _refreshData() async {
    var entity = widget._atlasInfoEntity;
    _titleList.add("图标");
    _detailList.add(entity.pic);
    _titleList.add("名称");
    _detailList.add(entity.name);
    _titleList.add("节点号");
    _detailList.add(entity.nodeId);
    _titleList.add("网址");
    _detailList.add(entity.home);
    _titleList.add("安全联系");
    _detailList.add(entity.contact);
    _titleList.add("描述");
    _detailList.add(entity.describe);
  }

  Widget _contentWidget() {
    return SliverToBoxAdapter(
      child: ListView.separated(
        itemBuilder: (context, index) {
          var subTitle = index < 3 ? "" : "（选填）";
          var title = _titleList[index];
          var detail = _detailList[index].isEmpty ? _hintList[index] : _detailList[index];
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

          return Material(
            child: Ink(
              child: InkWell(
                splashColor: Colors.blue,
                onTap: () async {
                  if (index == 0) {
                    EditIconSheet(context, (path) {
                      setState(() {
                        _localImagePath = path;
                      });
                    });
                    return;
                  }

                  String text = await Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => Map3NodePronouncePage(
                            title: title,
                            hint: hint,
                            text: _detailList[index],
                            keyboardType: keyboardType,
                          )));
                  if (text?.isNotEmpty ?? false) {
                    setState(() {
                      _detailList[index] = text;
                    });
                    print("[Pronounce] _editText:${_editText}");
                  }
                },
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: detail.isNotEmpty ? 18 : 14, horizontal: 14),
                    child: Row(
                      children: <Widget>[
                        Text(
                          title,
                          style: TextStyle(color: HexColor("#333333"), fontSize: 16),
                        ),
                        Spacer(),
                        title != "图标"
                            ? Text(
                                detail,
                                style: TextStyle(color: HexColor("#999999"), fontSize: 14),
                              )
                            : _localImagePath.isEmpty
                                ? Image.network(
                                    widget._atlasInfoEntity.pic,
                                    width: 36,
                                    height: 36,
                                  )
                                : Image.asset(
                                    _localImagePath ?? "res/drawable/ic_map3_node_item_2.png",
                                    width: 36,
                                    height: 36,
                                    fit: BoxFit.cover,
                                  ),
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Icon(
                            Icons.chevron_right,
                            color: DefaultColors.color999,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
          if (_localImagePath.isEmpty) {
            _localImagePath = widget._atlasInfoEntity.pic;
          }

          if (_detailList[1].isEmpty) {
            _detailList[1] = widget._atlasInfoEntity.name;
          }

          if (_detailList[2].isEmpty) {
            _detailList[2] = widget._atlasInfoEntity.nodeId;
          }

          var _atlasInfoEntity = widget._atlasInfoEntity;
          for (var index = 0; index < _titleList.length; index++) {
            var title = _titleList[index];
            if (title == "图标") {
              _atlasInfoEntity.pic = _localImagePath;
            } else if (title == "名称") {
              _atlasInfoEntity.name = _detailList[1];
            } else if (title == "节点号") {
              _atlasInfoEntity.nodeId = _detailList[2];
            } else if (title == "网址") {
              _atlasInfoEntity.home = _detailList[3];
            } else if (title == "安全联系") {
              _atlasInfoEntity.contact = _detailList[4];
            } else if (title == "描述") {
              _atlasInfoEntity.describe = _detailList[5];
            }
          }
          var encodeEntity = FluroConvertUtils.object2string(_atlasInfoEntity.toJson());
          Application.router.navigateTo(
              context, Routes.map3node_formal_confirm_page + "?actionEvent=${Map3NodeActionEvent.EDIT_ATLAS.index}");
        },
        height: 46,
        width: MediaQuery.of(context).size.width - 37 * 2,
        fontSize: 18,
      ),
    );
  }

  Widget settingFees() {
    return SliverToBoxAdapter(
      child: Column(
        children: <Widget>[
          Container(
            height: 10,
            color: DefaultColors.colorf2f2f2,
          ),
          managerSpendWidget(context, _rateCoinController, () {
            setState(() {
              _managerSpendCount--;
              if (_managerSpendCount < 1) {
                _managerSpendCount = 1;
              }

              _rateCoinController.text = "$_managerSpendCount";
            });
          }, () {
            setState(() {
              _managerSpendCount++;
              if (_managerSpendCount > 20) {
                _managerSpendCount = 20;
              }
              _rateCoinController.text = "$_managerSpendCount";
            });
          }),
          Container(
            height: 10,
            color: DefaultColors.colorf2f2f2,
          ),
        ],
      ),
    );
  }

  Widget settingBLS() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 16, left: 14, right: 14, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('bls key'),
            SizedBox(
              height: 16,
            ),
            RoundBorderTextField(
              onChanged: (text) {
                setState(() {
                  widget._atlasInfoEntity.blsKey = text;
                });
              },
              controller: _blsKeyTextController,
              isDense: false,
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              children: <Widget>[
                Text('bls签名'),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            RoundBorderTextField(
              onChanged: (text) {
                setState(() {
                  widget._atlasInfoEntity.blsSign = text;
                });
              },
              controller: _blsSignTextController,
              isDense: false,
            ),
          ],
        ),
      ),
    );
  }
}
