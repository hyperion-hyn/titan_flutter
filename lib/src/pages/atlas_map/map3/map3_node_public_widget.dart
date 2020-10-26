import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:image_pickers/UIConfig.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_home_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_introduce_entity.dart';
import 'package:titan/src/pages/wallet/api/hyn_api.dart';
import 'package:titan/src/pages/wallet/model/hyn_transfer_history.dart';
import 'package:titan/src/pages/wallet/model/transtion_detail_vo.dart';
import 'package:titan/src/pages/wallet/wallet_show_account_info_page.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/round_border_textfield.dart';
import 'package:titan/src/widget/wallet_widget.dart';
import 'map3_node_pronounce_page.dart';

Widget iconEmptyDefault() {
  return ClipRRect(
    borderRadius: BorderRadius.circular(4.0),
    child: FadeInImage.assetNetwork(
      image: "",
      placeholder: 'res/drawable/img_placeholder.jpg',
      width: 42,
      height: 42,
      fit: BoxFit.cover,
    ),
  );
}

Widget iconAtlasHomeNodeWidget(AtlasHomeNode atlasHomeNode) {
  if (atlasHomeNode == null) {
    return iconEmptyDefault();
  }
  return iconWidget(atlasHomeNode.pic, atlasHomeNode.name, atlasHomeNode.address);
}

Widget iconAtlasWidget(AtlasInfoEntity infoEntity, {bool isCircle = false}) {
  if (infoEntity == null) {
    return iconEmptyDefault();
  }
  return iconWidget(infoEntity.pic, infoEntity.name, infoEntity.address, isCircle: isCircle);
}

Widget iconMap3Widget(Map3InfoEntity infoEntity, {bool isCircle = false}) {
  if (infoEntity == null) {
    return iconEmptyDefault();
  }
  return iconWidget(infoEntity.pic, infoEntity.name, infoEntity.address, isCircle: isCircle);
}

Widget iconWidget(String picture, String name, String address, {bool isCircle = false}) {
  if (picture.isNotEmpty) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4.0),
      child: FadeInImage.assetNetwork(
        image: picture,
        placeholder: 'res/drawable/img_placeholder.jpg',
        width: 42,
        height: 42,
        fit: BoxFit.cover,
      ),
    );
  }

  return SizedBox(
    width: 42,
    height: 42,
    child: walletHeaderWidget(
      name,
      isShowShape: true,
      address: address,
      isCircle: isCircle,
    ),
  );
}

Widget getMap3NodeWaitItem(BuildContext context, Map3InfoEntity infoEntity, Map3IntroduceEntity map3introduceEntity,
    {bool canCheck = true, int currentEpoch = 0}) {
  if (infoEntity == null) return Container();

  var state = Map3InfoStatus.values[infoEntity?.status ?? 0];
  var isNotFull = true;
  var fullDesc = "";
  var dateDesc = "";

  var startMin = double.parse(map3introduceEntity?.startMin ?? "0");
  var staking = double.parse(infoEntity?.getStaking() ?? "0");
  var remain = startMin - staking;
  var remainDelegation = FormatUtil.formatPrice(remain);
  isNotFull = remain > 0;

  switch (state) {
    case Map3InfoStatus.CREATE_SUBMIT_ING:
    case Map3InfoStatus.FUNDRAISING_NO_CANCEL:
      dateDesc =
          S.of(context).left + FormatUtil.timeStringSimple(context, double.parse(infoEntity?.atlas?.staking ?? "0"));
      dateDesc = S.of(context).active + dateDesc;
      fullDesc = !isNotFull ? S.of(context).delegation_amount_full : "";
      break;

    case Map3InfoStatus.CONTRACT_HAS_STARTED:
      dateDesc =
          S.of(context).left + FormatUtil.timeStringSimple(context, double.parse(infoEntity?.atlas?.staking ?? "0"));
      dateDesc = S.of(context).expired + dateDesc;
      break;

    case Map3InfoStatus.CONTRACT_IS_END:
      dateDesc = S.of(context).contract_had_expired;
      break;

    case Map3InfoStatus.CREATE_FAIL:
      dateDesc = S.of(context).launch_fail;
      break;

    case Map3InfoStatus.CANCEL_NODE_SUCCESS:
      dateDesc = S.of(context).contract_had_stop;
      break;

    default:
      break;
  }

  var nodeName = infoEntity?.name ?? "";
  var nodeAddress = "${UiUtil.shortEthAddress(infoEntity?.address ?? "", limitLength: 8)}";
  var nodeIdPre = "节点号";
  var nodeId = " ${infoEntity.nodeId ?? ""}";
  var feeRatePre = "管理费：";
  var feeRate = FormatUtil.formatPercent(double.parse(infoEntity?.getFeeRate() ?? "0"));
  var descPre = "描   述：";
  var desc = (infoEntity?.describe ?? "").isEmpty ? "大家快来参与我的节点吧，收益高高，收益真的很高，" : infoEntity.describe;
  var date = FormatUtil.formatUTCDateStr(infoEntity?.createdAt ?? "0", isSecond: true);

  if (infoEntity.status == Map3InfoStatus.FUNDRAISING_NO_CANCEL.index) {
    date = "创建于 ${FormatUtil.formatDate(infoEntity?.createTime, isSecond: true)}";

  } else if (infoEntity.status == Map3InfoStatus.CONTRACT_HAS_STARTED.index){
    print("currentEpoch:$currentEpoch, endEpoch:${infoEntity?.endEpoch??0}");

    var remainEpoch = (infoEntity?.endEpoch??0) - currentEpoch;
    date = "剩余 ${remainEpoch>0?remainEpoch:0}纪元 ${FormatUtil.formatDate(infoEntity?.endTime, isSecond: true)}";
  }

  return InkWell(
    onTap: () async {
      if (!canCheck) return;

      Application.router.navigateTo(
        context,
        Routes.map3node_contract_detail_page + '?info=${FluroConvertUtils.object2string(infoEntity)}',
      );
    },
    child: Container(
      decoration: BoxDecoration(
        color: canCheck ? Colors.white : HexColor("#F2F2F2"),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8.0,
//            color: HexColor("#000000").withOpacity(0.08),
//            blurRadius: 16.0,
          ),
        ],
      ),
      margin: const EdgeInsets.only(left: 15.0, right: 15, bottom: 9, top: 20),
      child: Padding(
        padding: const EdgeInsets.only(left: 12.0, right: 12, bottom: 16, top: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    right: 12,
                  ),
                  child: iconMap3Widget(infoEntity),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width - 108,
                      child: Row(
                        children: <Widget>[
                          Expanded(child: Padding(
                            padding: const EdgeInsets.only(right: 16,),
                            child: Text(
                              //shortName(nodeName, limitCharsLength: 8),
                              nodeName,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              softWrap: true,
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                          ),),
                          RichText(
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                                text: nodeIdPre,
                                style: TextStyle(
                                  color: HexColor("#999999"),
                                  fontSize: 12,
                                ),
                                children: [
                                  TextSpan(
                                      text: "$nodeId",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: HexColor("#333333"),
                                      ))
                                ]),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 4,
                      ),
                      child: Text(nodeAddress, style: TextStyles.textC9b9b9bS12),
                    ),
                  ],
                ),
                //Spacer(),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    feeRatePre,
                    style: TextStyle(fontSize: 10, color: HexColor("#999999")),
                  ),
                  Text(
                    feeRate,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: HexColor("#333333")),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    descPre,
                    style: TextStyle(fontSize: 10, color: HexColor("#999999")),
                  ),
                  Flexible(
                    child: Text(
                      desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: HexColor("#333333")),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              child: Divider(height: 1, color: Color(0x2277869e)),
            ),
            Row(
              children: <Widget>[
                isNotFull
                    ? RichText(
                        text:
                            TextSpan(text: S.of(context).remain, style: TextStyles.textC9b9b9bS12, children: <TextSpan>[
                          TextSpan(text: remainDelegation, style: TextStyles.textC7c5b00S12),
                          TextSpan(text: "HYN", style: TextStyles.textC9b9b9bS12),
                        ]),
                      )
                    : RichText(
                        text: TextSpan(
                          text: fullDesc,
                          style: TextStyles.textC9b9b9bS12,
                          children: <TextSpan>[],
                        ),
                      ),
                Spacer(),
                Text(
                  date,
                  style: TextStyle(fontSize: 12, color: HexColor("#9B9B9B")),
                ),
              ],
            )
          ],
        ),
      ),
    ),
  );
}

Widget managerSpendWidget(BuildContext buildContext, TextEditingController _rateCoinController,
    {Function reduceFunc, Function addFunc}) {
  return Container(
    color: Colors.white,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: RichText(
            text: TextSpan(
                text: "管理费设置",
                style: TextStyle(fontSize: 16, color: HexColor("#333333"), fontWeight: FontWeight.normal),
                children: [
                  TextSpan(
                    text: "（10%-20%）",
                    style: TextStyle(fontSize: 12, color: HexColor("#999999"), fontWeight: FontWeight.normal),
                  )
                ]),
          ),
        ),
        Spacer(),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              InkWell(
                onTap: () {
                  reduceFunc();
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    child: Text(
                      "-",
                      style: TextStyle(fontSize: 16, color: HexColor("#333333")),
                    ),
                    decoration: BoxDecoration(
                      color: HexColor("#F2F2F2"),
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                  ),
                ),
              ),
              Container(
                width: 60,
                height: 34,
                child: RoundBorderTextField(
                  controller: _rateCoinController,
                  keyboardType: TextInputType.number,
                  bgColor: HexColor("#ffffff"),
                  maxLength: 3,
                  validator: (textStr) {

                    if (textStr.length == 0) {
                      return "请输入合适的管理费";
                    } else if (int.parse(textStr??"0") < 10) {
                      return "管理费不能小于10%";
                    } else if (Decimal.parse(textStr) >
                        Decimal.parse("20")) {
                      return "管理费不能大于20%";
                    } else {
                      return null;
                    }

                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 8.0),
                child: Container(
                  child: Text(
                    "%",
                    style: TextStyle(fontSize: 16, color: HexColor("#333333")),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  addFunc();
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Container(
                    height: 22,
                    width: 22,
                    alignment: Alignment.center,
                    child: Text(
                      "+",
                      style: TextStyle(fontSize: 16, color: HexColor("#333333")),
                    ),
                    decoration: BoxDecoration(
                      color: HexColor("#F2F2F2"),
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    ),
  );
}

Widget getHoldInNum(
  BuildContext context,
  Map3InfoEntity contractNodeItem,
  GlobalKey<FormState> formKey,
  TextEditingController textEditingController,
  String endProfit,
  String spendManager, {
  bool isJoin = false,
  bool isMyself = false,
  FocusNode focusNode,
  List<String> suggestList,
  Map3IntroduceEntity map3introduceEntity,
}) {
  double minTotal = double.parse(isJoin ? map3introduceEntity?.delegateMin : map3introduceEntity?.createMin);

  var wallet = WalletInheritedModel.of(
    context,
    aspect: WalletAspect.activatedWallet,
  );
  var activatedWallet = wallet.activatedWallet;

  var walletName = activatedWallet?.wallet?.keystore?.name??"";

  var coinVo = wallet.getCoinVoBySymbol('HYN');

  return Container(
    color: Colors.white,
    padding: EdgeInsets.only(top: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8, right: 8),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child:
                    Text(S.of(context).mortgage_hyn_num, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              ),
              Expanded(
                child: Text(S.of(context).mortgage_wallet_balance(walletName,FormatUtil.coinBalanceHumanReadFormat(coinVo)),
                    style: TextStyle(
                      color: Colors.grey[600],
                    )),
              ),
            ],
          ),
        ),
        Container(
            padding: const EdgeInsets.only(left: 16.0, right: 36, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 12,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "HYN",
                      style: TextStyle(fontSize: 18, color: HexColor("#35393E")),
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Flexible(
                      flex: 1,
                      child: Form(
                        key: formKey,
                        child: RoundBorderTextField(
                          focusNode: focusNode,
                          controller: textEditingController,
                          keyboardType: TextInputType.number,
                          hint: S.of(context).mintotal_buy(FormatUtil.formatNumDecimal(minTotal)),
                          validator: (textStr) {

                            if (textStr.length == 0) {
                              return S.of(context).please_input_hyn_count;
                            }

                            var inputValue = Decimal.tryParse(textStr);
                            if (inputValue == null) {
                              return '请正确的输入数据';
                            }

                            if (int.parse(textStr) < minTotal) {
                              return S.of(context).mintotal_hyn(FormatUtil.formatNumDecimal(minTotal));
                            } else if (Decimal.parse(textStr) >
                                Decimal.parse(FormatUtil.coinBalanceHumanRead(coinVo))) {
                              return S.of(context).hyn_balance_no_enough;
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                if (!isJoin && suggestList.length == 3)
                  Padding(
                    padding: const EdgeInsets.only(left: 49.0, bottom: 18),
                    child: Row(
                      children: [0, 0.5, 1, 0.5, 2].map((value) {
                        if (value == 0.5) {
                          return SizedBox(width: 16);
                        }
                        return InkWell(
                          child: Container(
                            color: HexColor("#1FB9C7").withOpacity(0.08),
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Text(suggestList[value], style: TextStyle(fontSize: 12, color: HexColor("#5C4304"))),
                          ),
                          onTap: () {
                            textEditingController.text = suggestList[value];
                          },
                        );
                      }).toList(),
                    ),
                  ),
              ],
            )),
      ],
    ),
  );
}

typedef NodePublicCallback = void Function({String value});

Widget editInfoItem(
    BuildContext context, int index, String title, String hint, String detail, NodePublicCallback callback,
    {String subtitle = "", bool hasSubtitle = true, TextInputType keyboardType = TextInputType.text}) {
  return Material(
    child: Ink(
      child: InkWell(
        splashColor: Colors.blue,
        onTap: () async {
          /* if (index == 0) {
            editIconSheet(context, (path) {
              callback(value: path);
            });
            return;
          }*/

          String text = await Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => Map3NodePronouncePage(
                    title: title,
                    hint: hint,
                    text: detail,
                    keyboardType: keyboardType,
                  )));
          if (text?.isNotEmpty ?? false) {
            callback(value: text);
          }
        },
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: detail.isNotEmpty ? 18 : 14, horizontal: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(color: HexColor("#333333"), fontSize: 16),
                ),
                if (hasSubtitle)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: subtitle.isEmpty
                        ? Text(
                            ' * ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: HexColor("#FFFF4C3B"),
                              fontSize: 16,
                            ),
                          )
                        : Text(
                            subtitle,
                            style: TextStyle(color: HexColor("#999999"), fontSize: 12),
                          ),
                  ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      detail.isEmpty ? hint : detail,
                      textAlign: TextAlign.start,
                      style: TextStyle(color: detail.isEmpty ? HexColor("#999999") : HexColor("#333333"), fontSize: 14),
                    ),
                  ),
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
}

Widget rowTipsItem(String title, {double top = 8, String subTitle = "", GestureTapCallback onTap}) {
  var _nodeWidget = Padding(
    padding: const EdgeInsets.only(right: 10, top: 10),
    child: Container(
      width: 3,
      height: 3,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: DefaultColors.color999,
          border: Border.all(color: DefaultColors.color999, width: 1.0)),
    ),
  );

  return Padding(
    padding: EdgeInsets.only(top: top),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _nodeWidget,
        Expanded(
            child: InkWell(
          onTap: onTap,
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: subTitle,
                  style: TextStyle(color: HexColor("#1F81FF"), fontSize: 12),
                )
              ],
              text: title,
              style: TextStyle(height: 1.8, color: DefaultColors.color999, fontSize: 12),
            ),
          ),
        )),
      ],
    ),
  );
}

Widget profitListWidget(List<Map> list) {
  Widget _buildColumn({String title, String detail}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(detail, style: TextStyle(fontSize: 16, color: HexColor("#333333"), fontWeight: FontWeight.normal)),
        Container(
          height: 4,
        ),
        Text(title, style: TextStyle(fontSize: 12, color: HexColor("#999999"), fontWeight: FontWeight.normal)),
      ],
    );
  }

  return _profitListWidget(list, horizontal: 30, func: _buildColumn);
}

Widget profitListBigWidget(List<Map> list) {
  Widget _buildColumn({String title, String detail}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(detail, style: TextStyle(fontSize: 14, color: HexColor("#333333"), fontWeight: FontWeight.normal)),
          Container(
            height: 4,
          ),
          Text(title, style: TextStyle(fontSize: 10, color: HexColor("#999999"), fontWeight: FontWeight.normal)),
        ],
      ),
    );
  }

  return _profitListWidget(list, func: _buildColumn);
}

Widget profitListLightWidget(List<Map> list) {
  Widget _buildColumn({String title, String detail}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(detail, style: TextStyle(fontSize: 16, color: HexColor("#333333"), fontWeight: FontWeight.normal)),
          Container(
            height: 4,
          ),
          Text(title, style: TextStyle(fontSize: 10, color: HexColor("#333333"), fontWeight: FontWeight.normal)),
        ],
      ),
    );
  }

  return _profitListWidget(list, func: _buildColumn);
}

Widget profitListBigLightWidget(List<Map> list) {
  Widget _buildColumn({String title, String detail}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(detail, style: TextStyle(fontSize: 18, color: HexColor("#333333"), fontWeight: FontWeight.w600)),
        Container(
          height: 5,
        ),
        Text(title, style: TextStyle(fontSize: 11, color: HexColor("#333333"), fontWeight: FontWeight.normal)),
      ],
    );
  }

  return _profitListWidget(list, horizontal: 30, func: _buildColumn);
}

typedef ProfitBuildFunc = Widget Function({String title, String detail});

Widget _profitListWidget(List<Map> list, {double horizontal = 10, ProfitBuildFunc func}) {
  _buildLine() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal),
      child: Container(
        height: 15,
        width: 0.5,
        color: HexColor("#000000").withOpacity(0.2),
      ),
    );
  }

  List<Widget> children = [];
  for (int index = 0; index < list.length; index++) {
    var map = list[index];
    var title = map.keys.first;
    var detail = map.values.first;
    var column = func(title: title, detail: detail);
    children.add(column);
    if (index != (list.length - 1)) {
      var line = _buildLine();
      children.add(line);
    }
  }

  MainAxisAlignment mainAxisAlignment = list.length == 2 ? MainAxisAlignment.start : MainAxisAlignment.center;
  return Row(
    mainAxisAlignment: mainAxisAlignment,
    children: children,
  );
}

typedef EditIconCallback = void Function(String path);

Future editIconSheet(BuildContext context, EditIconCallback callback) async {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
      ),
    ),
    builder: (BuildContext dialogContext) {
      return Container(
        height: 199,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 54,
              child: ListTile(
                title: Text(
                  "拍照",
                  textAlign: TextAlign.center,
                  style: TextStyles.textC333S18,
                ),
                onTap: () async {
                  Future.delayed(Duration(milliseconds: 500), () {
                    Navigator.pop(dialogContext);
                  });

                  var tempListImagePaths = await ImagePickers.openCamera(
                    compressSize: 500,
                  );
                  if (tempListImagePaths != null) {
                    callback(tempListImagePaths.path);
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10),
              child: Divider(height: 1, color: DefaultColors.colorf2f2f2),
            ),
            SizedBox(
              height: 54,
              child: ListTile(
                title: Text("从相册选择", textAlign: TextAlign.center, style: TextStyles.textC333S18),
                onTap: () async {
                  Future.delayed(Duration(milliseconds: 500), () {
                    Navigator.pop(dialogContext);
                  });

                  var tempListImagePaths = await ImagePickers.pickerPaths(
                    galleryMode: GalleryMode.image,
                    selectCount: 1,
                    showCamera: true,
                    cropConfig: null,
                    compressSize: 500,
                    uiConfig: UIConfig(uiThemeColor: Color(0xff0f95b0)),
                  );
                  if (tempListImagePaths != null && tempListImagePaths.length == 1) {
                    callback(tempListImagePaths[0].path);
                  }
                },
              ),
            ),
            Container(
              height: 10,
              color: DefaultColors.colorf4f4f4,
            ),
            ListTile(
              title: Text(S.of(context).cancel, textAlign: TextAlign.center, style: TextStyles.textC333S18),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Expanded(
                child: Container(
              color: DefaultColors.colorf4f4f4,
            )),
          ],
        ),
      );
    },
  );
}

Widget emptyListWidget({String title = "", bool isAdapter = true}) {
  var containerWidget = Container(
    padding: const EdgeInsets.symmetric(vertical: 24),
    color: Colors.white,
    child: Column(
      children: <Widget>[
        Image.asset(
          'res/drawable/ic_empty_contract.png',
          width: 80,
          height: 80,
        ),
        SizedBox(height: 16),
        SizedBox(
          child: Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          //width: 200,
        ),
      ],
    ),
  );

  return isAdapter
      ? SliverToBoxAdapter(
          child: containerWidget,
        )
      : containerWidget;
}

Widget delegateRecordItemWidget(HynTransferHistory item, {bool isAtlasDetail = false, String map3CreatorAddress = ""}) {
  var isPending = item.status == 0 || item.status == 1;
  // type 0一般转账；1创建atlas节点；2修改atlas节点/重新激活Atlas；3参与atlas节点抵押；4撤销atlas节点抵押；5领取atlas奖励；6创建map3节点；7编辑map3节点；8撤销map3节点；9参与map3抵押；10撤销map3抵押；11领取map3奖励；12续期map3;13裂变map3节点；

  var amountValue = ConvertTokenUnit.weiToEther(weiBigInt: BigInt.parse(item?.dataDecoded?.amount ?? "0")).toDouble();
  var amount = FormatUtil.formatPrice(amountValue);
  var detail = HYNApi.getValueByHynType(item.type, getTypeStr: true);
  detail = detail + " ${HYNApi.getValueByHynType(item.type, transactionDetail: TransactionDetailVo.fromHynTransferHistory(item, item.type, "HYN"), getAmountStr: true)}";

  WalletVo _activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
  var walletAddress = _activatedWallet?.wallet?.getAtlasAccount()?.address?.toLowerCase() ?? "";
  var isYou = item.from.toLowerCase() == walletAddress;
  var isCreator = map3CreatorAddress.toLowerCase() == walletAddress;
  var recordName = isAtlasDetail
      ? " ${isYou ? "(你)" : ""}"
      : "${isCreator && !isYou ? " (创建者)" : ""}${!isCreator && isYou ? " (你)" : ""}${isCreator && isYou ? " (创建者)" : ""}";

  return Container(
    color: Colors.white,
    child: Stack(
      children: <Widget>[
        InkWell(
          onTap: () {
            _pushTransactionDetailAction(item);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 40,
                  width: 40,
                  child: iconWidget("", item.name, item.from, isCircle: true),
                ),
                Flexible(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Flexible(
                              flex: 2,
                              child: RichText(
                                text: TextSpan(
                                  text: item.name,
                                  style: TextStyle(fontSize: 14, color: HexColor("#000000"), fontWeight: FontWeight.w500),
                                  children: [
                                    TextSpan(
                                      text: recordName,
                                      style: TextStyle(
                                          fontSize: 14, color: HexColor("#999999"), fontWeight: FontWeight.w500),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[

                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: Text(
                                     detail,
                                    style: TextStyle(
                                        fontSize: 14, color: HexColor("#333333"), fontWeight: FontWeight.bold),
                                  ),
                                ),
                                _billStateWidget(item)
                              ],
                            ),
                          ],
                        ),
                        Container(
                          height: 8.0,
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              shortBlockChainAddress("${WalletUtil.ethAddressToBech32Address(item.from)}", limitCharsLength: 8),
                              style: TextStyle(fontSize: 12, color: HexColor("#999999")),
                            ),
                            Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(FormatUtil.formatDate(item.timestamp, isSecond: true),
                                    style: TextStyle(fontSize: 10, color: HexColor("#999999"))),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 40,
          right: 8,
          child: Container(
            height: 0.5,
            color: DefaultColors.colorf5f5f5,
          ),
        ),
      ],
    ),
  );
}

void _pushTransactionDetailAction(HynTransferHistory item) {
  TransactionDetailVo transactionDetail = TransactionDetailVo(
    id: item.id,
    contractAddress: item.contractAddress,
    state: 1,
    //1 success, 0 pending, -1 failed
    amount: ConvertTokenUnit.weiToEther(weiBigInt: BigInt.parse(item?.dataDecoded?.amount ?? "0")).toDouble(),
    symbol: "HYN",
    fromAddress: item.from,
    toAddress: item.to,
    time: item.timestamp,
    nonce: item.nonce.toString(),
    gasPrice: item.gasPrice,
    gas: item.gasLimit.toString(),
    gasUsed: item.gasUsed.toString(),
    describe: item?.dataDecoded?.description?.details ?? "",
    data: item?.data ?? "很棒",
    dataDecoded: item.dataDecoded,
    blockHash: item.blockHash,
    blockNum: item.blockNum,
    epoch: item.epoch,
    transactionIndex: item.transactionIndex,
    type: item.type, //1、转出 2、转入
  );

  Navigator.push(
    Keys.rootKey.currentContext,
    MaterialPageRoute(builder: (context) => WalletShowAccountInfoPage(transactionDetail)),
  );
}

Widget _billStateWidget(HynTransferHistory item) {
  // status 自定义： 1.pending；2.wait receipt; 3success; 4.fail;5.drop fail see TransactionXXX

  switch (item.status) {
    case 1:
    case 2:
      return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [HexColor("#E0B102"), HexColor("#F3D35D")],
                begin: FractionalOffset(1, 0.5),
                end: FractionalOffset(0, 0.5)),
            borderRadius: BorderRadius.all(Radius.circular(12.0))),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
          child: Text(
            "进行中",
            style: TextStyle(fontSize: 6, color: HexColor("#FFFFFF"), fontWeight: FontWeight.normal),
          ),
        ),
      );
      break;

    case 4:
    case 5:
      return Container(
        decoration: BoxDecoration(color: HexColor("#FF4C3B"), borderRadius: BorderRadius.all(Radius.circular(12.0))),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
          child: Text(
            "失败了",
            style: TextStyle(fontSize: 6, color: HexColor("#FFFFFF"), fontWeight: FontWeight.normal),
          ),
        ),
      );
      break;

    default:
      return Container(
        decoration: BoxDecoration(color: HexColor("#F2F2F2"), borderRadius: BorderRadius.all(Radius.circular(12.0))),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
          child: Text(
            "已完成",
            style: TextStyle(fontSize: 6, color: HexColor("#999999"), fontWeight: FontWeight.normal),
          ),
        ),
      );

      break;
  }
}
