import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/widget/wallet_widget.dart';

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
          Application.router.navigateTo(
            context,
            Routes.atlas_detail_page +
                '?atlasNodeId=${FluroConvertUtils.fluroCnParamsEncode(_atlasInfo.nodeId)}&atlasNodeAddress=${FluroConvertUtils.fluroCnParamsEncode(_atlasInfo.address)}',
          );
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
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    iconAtlasWidget(_atlasInfo),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text.rich(TextSpan(children: [
                            TextSpan(
                                text: _atlasInfo.name ?? 'node name',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                )),
                            TextSpan(
                                text: "", style: TextStyles.textC333S14bold),
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
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            S.of(context).node_num_and_node_id(_atlasInfo.nodeId),
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Container(
                          height: 8,
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
                                  text:
                                      '${double.parse(_atlasInfo.rewardRate ?? '0') == 0 ? '--' : FormatUtil.formatPercent(double.parse(_atlasInfo.rewardRate ?? '0'))}',
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
                                  text:
                                      '${FormatUtil.stringFormatCoinNum(_atlasInfo.getTotalStaking())}',
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
                                text:
                                    '${FormatUtil.formatPercent(double.parse(_atlasInfo.getFeeRate() ?? '0'))}',
                                style: TextStyle(
                                  fontSize: 12,
                                ))
                          ])),
                        ),
//                        Expanded(
//                          child: Text.rich(TextSpan(children: [
//                            TextSpan(
//                                text: '状态: ',
//                                style: TextStyle(
//                                    color: Colors.grey, fontSize: 12)),
//                            TextSpan(text: ' '),
//                            TextSpan(
//                                text: '正常',
//                                style: TextStyle(
//                                  fontSize: 12,
//                                ))
//                          ])),
//                        )
                      ],
                    )
                  ],
                ),
                Row(children: [
                  Spacer(),
                  Container(
                    margin: EdgeInsets.symmetric(
                      vertical: 0.0,
                      horizontal: 8.0,
                    ),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: HexColor('#FF00E4A1'),
                      borderRadius: BorderRadius.circular(
                        16.0,
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
