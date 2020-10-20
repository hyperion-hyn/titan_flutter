import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';

class AtlasNodeDetailItem extends StatelessWidget {
  final AtlasInfoEntity _atlasInfo;

  AtlasNodeDetailItem(this._atlasInfo);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      child: InkWell(
        onTap: () async {
          Application.router.navigateTo(context, Routes.atlas_detail_page);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[200],
                blurRadius: 15.0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Image.asset(
                      "res/drawable/map3_node_default_avatar.png",
                      width: 42,
                      height: 42,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text.rich(TextSpan(children: [
                          TextSpan(
                              text: _atlasInfo.name ?? 'node name',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              )),
                          TextSpan(text: "", style: TextStyles.textC333S14bold),
                        ])),
                        Container(
                          height: 4,
                        ),
//                        Row(
//                          children: <Widget>[
//                            Text(
//                              '${S.of(context).atlas_node_rank}: ',
//                              style: TextStyles.textC9b9b9bS12,
//                            ),
//                            Text(
//                              '${1}',
//                              style: TextStyles.textC333S11,
//                            ),
//                          ],
//                        )
                      ],
                    ),
                    Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            '节点号：${_atlasInfo.nodeId}',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Container(
                          height: 4,
                        ),
                        Container(
                          color: HexColor("#1FB9C7").withOpacity(0.08),
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text('${getAtlasNodeType(_atlasInfo.type)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: HexColor("#5C4304"),
                              )),
                        ),
                      ],
                    )
                  ],
                ),
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Text.rich(TextSpan(children: [
                              TextSpan(
                                  text: '${S.of(context).atlas_reward_rate}: ',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                              TextSpan(text: ' '),
                              TextSpan(
                                  text: _atlasInfo.rewardRate,
                                  style: TextStyle(
                                    fontSize: 12,
                                  ))
                            ])),
                          ),
                          Expanded(
                            child: Text.rich(TextSpan(children: [
                              TextSpan(
                                  text:
                                      '${S.of(context).atlas_total_staking}: ',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                              TextSpan(text: ' '),
                              TextSpan(
                                  text: _atlasInfo.staking,
                                  style: TextStyle(
                                    fontSize: 12,
                                  ))
                            ])),
                          )
                        ],
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text.rich(TextSpan(children: [
                            TextSpan(
                                text: '${S.of(context).atlas_fee_rate}: ',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                            TextSpan(text: ' '),
                            TextSpan(
                                text: _atlasInfo.feeRate,
                                style: TextStyle(
                                  fontSize: 12,
                                ))
                          ])),
                        ),
                        Expanded(
                          child: Text.rich(TextSpan(children: [
                            TextSpan(
                                text: '状态: ',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                            TextSpan(text: ' '),
                            TextSpan(
                                text: '正常',
                                style: TextStyle(
                                  fontSize: 12,
                                ))
                          ])),
                        )
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 8.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
